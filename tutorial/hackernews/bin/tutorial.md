## Preliminary setup

First let's just ensure everything works properly: 
We are going to create `hackernews.ml` with this test content:

$#1

Now run `dune exec hackernews.exe` and you should see a happy little greeting 

## First iteration
### Post rendering
This will render our post.

$#2

Lets break it down piece by piece.

Take the url and get just the website domain. We need this for our hackernews post.

$#3

We create two horizontal rows on top of one another  

```ocaml
  Ui.vcat
    [ Ui.hcat
        [(* *)]
    ; Ui.hcat 
        [ (* *)]
    ]
```
The `~attr` param allows us to set stying for text. In this case we set the style to bold.
We would also use `A.fg` to set the foreground colour or `A.bg` to set the background colour.
See: #TODO LINK for details.

```ocaml
W.string ~attr:A.(st bold) title;
```
`Lwd.pure` has the signature `'a->'a Lwd.t`. It is a way for us to take some static ui(or any data really) and give it to a function that supports potentially having a reactive `'a Lwd.t` as it's input. 
You will always have to use this to  get some ui element that doesn't depend on reactive data into the rest of your UI
```ocaml
  |> Lwd.pure
```
Puts a border around our post. Because we use a focusable box it will highlight when focused, which can be changed using `Alt+Up`/`Alt+Down`
```ocaml
  |> W.Box.focusable
```

### main_ui
Now we just need some posts to render. 
We will just use a fake version of the hackernews_api for now.

$#4

Notice that we used `W.vbox` rather than `Ui.vcat` that's because each item is now a `Ui.t Lwd.t` and `Ui.vcat` only accepts `Ui.t`.
Normally you'll use `Ui.*` functions for making small pieces of ui and `W.*` functions for large transformations. eg: `Ui.string` makes a single string, `W.Scoll.area` makes any ui scrollable. 



## Expanding upon it

Now we have an mvp that shows our basic data rending the way we want lets expand it.
In this chapter we will:
1. Make our styling a little nicer  
2. learn about how to handle keybaord input
3. Make selection lists
4. Make popups and move focus around
5. Use all that to make a popup allowing the user to select how they want posts sorted

### Styling changes

$#5 fold New post_ui

The main change here is that we've made our items stretch to fill the entire screen. 
We do this by setting the **stretch width**(`sw`) to something non-zero and also setting our **max width**(`mw`) to something much higher than a screen could ever be. 
by default max_width is the same as the width of the object 

```ocaml
  |> Ui.resize ~sw:1 ~mw:10000
```
There are also some small sytling changes like adding spacing between things and such.


### Sorting

First we are going to setup some variables to store our state, if we wanted to make this more modular we would put these inside a function, but for a simple ui having them in the global scope is simpler.

These variables will be `Lwd.var`s. An lwd var is essentially a `ref` that can be turned into an `Lwd.t` that reacts to the var being set.  

`show_prompt_var`: Defines if the prompt is shown, and if it is, what content to show
`sorting_mode_var`: Stores how we should sort the posts

$#6


$#7 

Making the prompt:

First we will add the overlay onto our main ui and give it the var that controls the prompt. 
We also make it so the body can stretch to give our prompt a little space.

$#8

Next we will process some keyboard inputs.
When 's' is pressed we will set the show_prompt_var to our prompt  

$#9

Notice how we used the `$=` operator here to  assign a value to the `Lwd.var`. This is just an alias to `Lwd.set` that looks a little nicer

```ocaml
          | `Finished sorting -> sorting_mode_var $= sorting
```

A little helper to choose the method of sorting

$#10

We have extended the posts generation to include a sorting step using our selected sorting function.

A little section has been added to the bottom to show the key the user should press to open the sorting prompt


$#11

Notice how we pass the all the other ui into the sorting prompt, this is becasue we want it to popup over everything

$#12

We will make a little status to show the curent sorting mode. 

This is our first use of `let$`! We are finally making a piece of ui that is reactive to changes.
In this case this ui will update whenever `sorting_mode_var` changes.

`let$` is actually syntactic sugar for `Lwd.map`. Just like `List.map` it allows us to apply a transformation function to the contents of the `Lwd.t`. 
We also use `Lwd.get`  to turn our `Lwd.var` into an `Lwd.t` as we described in secion_1

$#15

The equivalent code to `let$` is below:
```ocaml
   Lwd.get sorting_mode_var |>Lwd.map ~f:(fun sort_mode->
  (*..rest...*)
```
Here we see `let$*` which is simmilar to `let$` except that it is `Lwd.bind`, it's necissary when the result of the transformation is itself an `Lwd.t`. You'd likely be fammilar with `Result.bind` which behaves the same. 

$#14

In general `let$*` should be avoided becasue it causes whatever is inside it to have to be fully recomputed when the `Lwd.t` it is binding on changes. However In this case that does make sense becasue our list is going to have to be  fully re-sorted anyway.

In the next chapter you will see a lot more use of both `let$` as well as `let$*`

And that's it! 

$#13 fold full source code




