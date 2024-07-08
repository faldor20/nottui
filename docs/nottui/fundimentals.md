## Fundamentals of Lwd as it relates to nottui

Lwd (Lightweight Document) is a library that lets you build values that changes over time and recompute reactively.
Nottui is a library for building TUI(Terminal User Interface) programs that uses Lwd to make its ui react to changes.
Notty is a library for interface with the terminal, displaying symbols, colours etc.

When writing a ui in nottui, you are building a graph of Lwd nodes containing ui elements that each reactively update when their children change. 
Each "tick" Nottui will use Lwd to resolve the current state of the ui, updating any pieces whos dependencies have changed.
If the new ui is different it will render it to the terminal using Notty.

### Core functions and tools

#### Lwd.t and Lwd.var

- `'a Lwd.t`: Represents a value of type `'a` that can change over time.
- `'a Lwd.var`: A mutable variable that can be used as a source for `Lwd.t` values.

#### Basic Operations

- Creating a variable:
    ```ocaml
    let counter_var = Lwd.var 0
   ```
- Reading a variable as a reactive `Lwd.t`:

    ```ocaml
    let counter_value = Lwd.get counter_var
    ```
- Reading a variable instantaneously:
    This reads a variable as it currently is. 
    This should be used in callbacks and in response to events like keybaord input becasue 
    it won't trigger an update when the variable changes  
    ```ocaml
    Ui.keyboard_area (function
        | `Enter ,[]->
            let counter_value = Lwd.peek counter_var
            (*do something with counter*)
            `Handled
        |_-> `Unandled
    )
    ```


- Updating a variable:
    ```ocaml
    counter_var |> Lwd.update(fun counter -> counter + 1)
    ```


#### Transforming Lwd values:

Lwd.map transforms the contents of an `lwd.t` just like `List.map`. 
It will re-run the computation whenevre the input `Lwd.t` changes

```ocaml
let double_counter = Lwd.map (fun x -> x * 2) counter_value
```

```ocaml
let counter_display = Lwd.bind (fun x -> if x>10 then a else b) counter_value
```


#### Lwd infix syntax

`let$` Syntax
Used for binding Lwd values, similar to Lwd.map:
```ocaml
let$ count = Lwd.get counter in
W.printf "Count: %d" count
```


`and$` Syntax
Combines multiple Lwd values:
```ocaml
let$ count = Lwd.get counter
and$ name = Lwd.get name_var in
W.printf "%s: %d" name count
```
`|>$` Syntax
shorthand for `|> Lwd.map  ~f:`
This is particularly useful when running funcs like `Ui.resize` or `Ui.keyboard_area` 
```ocaml
"hi
there"
|>W.string
|>Lwd.pure
|>W.Scroll.v_scroll
|>$ Ui.resize ~sw:1 ~mw:10000
(*
Same as:
|> Lwd.map ~f:(Ui.resize ~sw:1 ~mw:10000)*)
```

`let$*` Syntax
For nested Lwd computations, similar to Lwd.bind:
```ocaml
let$* count = Lwd.get counter in
let$* doubled = Lwd.return (count * 2) in
W.printf "Doubled count: %d" doubled
```

Note: Use `let$*` sparingly as it can lead to inefficient recomputations.

`$=` Operator for Setting Lwd.vars
A convenient way to update Lwd.vars:

```ocaml
let counter=Lwd.var 1 in
counter $= 1
```

This is equivalent to:

```ocaml
Lwd.set counter (1)
```


### Practical Examples

Creating a Counter Button

```ocaml
open Nottui
open Lwd_infix

let make_counter_button () =
  let counter = Lwd.var 0 in
  let$ count = Lwd.get counter in
  Nottui_widgets.button
    (Printf.sprintf "Clicks: %d" count)
    (fun () -> counter $= fun c -> c + 1)
```


Combining Multiple Reactive Elements
```ocaml
let make_ui () =
  let name = Lwd.var "User" in
  let counter = Lwd.var 0 in
  let$ button = make_counter_button ()
  and$ greeting =
    let$ name = Lwd.get name
    and$ count = Lwd.get counter in
    Nottui_widgets.printf "Hello, %s! Count: %d" name count
  in
  Ui.join_y button greeting
```


Using let$* (Cautiously)
```ocaml
let make_dynamic_ui () =
  let threshold = Lwd.var 5 in
  let counter = Lwd.var 0 in
  let$* count = Lwd.get counter in
  if count > 10 then    
    some_complex_ui_lwd_t
  else
    some_other_complex_ui_lwd_t
```


### Best Practices:
- Prefer let$ and and$ for most transformations and combinations.
- Use let$* sparingly, only when necessary for conditional logic or complex transformations.
- Utilize $= for concise Lwd.var updates.
- Structure your UI to minimize unnecessary recomputations.
