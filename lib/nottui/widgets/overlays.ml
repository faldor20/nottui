(**Widgets that are designed to overlay some exisiting Ui*)

open Nottui_main
open Shared
open Lwd_infix
open (struct 
module BB=Border_box
module W=Nottui_widgets
end)
open Notty



let dynamic_size ?(w = 10) ~sw ?(h = 10) ~sh f =
  let size = Lwd.var (w, h) in
  let body = f (Lwd.get size) in
  body
  |> Lwd.map ~f:(fun ui ->
    ui
    |> Ui.resize ~w ~sw ~h ~sh
    |> Ui.size_sensor (fun ~w ~h -> if Lwd.peek size <> (w, h) then Lwd.set size (w, h)))
;;

(** Shows the size of the ui provided. Useful for debugging*)
let size_logger ui =
  let size = Lwd.var (-1, -1) in
  W.vbox
    [
      (size |> Lwd.get |>$ fun (w, h) -> W.fmt "w:%d,h:%d" w h)
    ; ui
      |>$ Ui.size_sensor (fun ~w ~h ->
        if Lwd.peek size <> (w, h) then Lwd.set size (w, h))
    ]
;;

(**Sets an attr for anything behind the given area*)
let set_bg ~attr ui =
  let size = Lwd.var (0, 0) in
  W.zbox
    [
      ( size |> Lwd.get |>$ fun (w, h) ->
        I.char attr ' ' w h |> Ui.atom |> Ui.resize ~w:0 ~h:0 )
    ; ui |>$ Ui.size_sensor (fun ~w ~h -> if (w, h) <> Lwd.peek size then size $= (w, h))
    ]
;;

(**Clears anything behind the given area using the width. If you have a dynamic sized element use [set_bg]*)
let set_bg_static ~attr ui =
  let w, h = Ui.layout_width ui, Ui.layout_height ui in
  Ui.zcat [ I.char attr ' ' w h |> Ui.atom |> Ui.resize ~w:0 ~h:0; ui ]
;;

(**Clears anything behind the given area*)
let clear_bg ui = set_bg ~attr:A.empty ui


(**Prompt that will display ontop of anything behind it *)
let prompt ?(focus = Focus.make ()) ?(char_count = false) ~show_prompt_var ui =
  let prompt_input = Lwd.var ("", 0) in
  let prompt_val = Lwd.get prompt_input in
  (*Build the ui so that it is either the prompt or nothing depending on whether show prompt is enabled*)
  let prompt_ui =
    let$* show_prompt_val = Lwd.get show_prompt_var in
    let prompt_ui =
      show_prompt_val
      |> Option.map @@ fun (label, pre_fill, on_exit) ->
         let on_exit result =
           Focus.release_reversable focus;
           show_prompt_var $= None;
           prompt_input $= ("", 0);
           on_exit result
         in
         (*we need focus because the base ui is rendering first and so *)
         Focus.request_reversable focus;
         (*prefill the prompt if we want to *)
         if prompt_input |> Lwd.peek |> fst == ""
         then prompt_input $= (pre_fill, pre_fill |> String.length);
         let prompt_field =
           W.zbox
             [
               W.string ~attr:A.(st underline) "                                       "
               |> Lwd.pure
             ; W.edit_field
                 prompt_val
                 ~on_change:(fun state -> Lwd.set prompt_input state)
                 ~on_submit:(fun (str, _) -> on_exit (`Finished str))
             ]
         in
         let$* prompt_val, _ = prompt_val
         and$ focus_status = focus |> Focus.status in
         let label_bottom =
           if char_count
           then Some (prompt_val |> String.length |> Int.to_string)
           else None
         in
         prompt_field
         |> BB.focusable ~focus ~label_top:label ?label_bottom
         |> clear_bg
         |>$ Ui.event_filter ~focus:focus_status (fun event ->
           match event with
           | `Key (`Escape, _) ->
             on_exit `Closed;
             `Handled
           | _ ->
             `Unhandled)
    in
    prompt_ui |> Option.value ~default:(Ui.empty |> Lwd.pure)
  in
  (*Now that we have the prompt ui we layer it ontop of the normal ui using zbox.
    My hope is that by not directly nesting them this will allow the ui to not re-render when the prompt appears*)
  W.zbox [ ui; prompt_ui |> Lwd.map ~f:(Ui.resize ~pad:neutral_grav) ]
;;



(**This is a simple popup that can show ontop of other ui elements *)
let popup ~show_popup_var ui =
  let popup_ui =
    let$* show_popup = Lwd.get show_popup_var in
    match show_popup with
    | Some (content, label) ->
      let prompt_field = content in
      prompt_field |>$ Ui.resize ~w:5 |> BB.box ~label_top:label |> clear_bg
    | None ->
      Ui.empty |> Lwd.pure
  in
  W.zbox [ ui; popup_ui |>$ Ui.resize ~crop:neutral_grav ~pad:neutral_grav ]
;;

(* TODO remove this *)
let prompt_example =
  let show_prompt_var = Lwd.var None in
  let ui =
    Ui.vcat
      [
        W.string "hi this is my main ui"
      ; W.string "another line"
      ; W.string "another line"
      ; W.string
          "another linanother \
           lineaorsietnaoiresntoiaernstoieanrstoiaernstoiearnostieanroseitnaoriestnoairesntoiaernsotieanrsotienaoriestnoairesntoiearnstoieanrste"
      ; W.string "another line"
      ; W.string
          "another linanother \
           lineaorsietnaoiresntoiaernstoieanrstoiaernstoiearnostieanroseitnaoriestnoairesntoiaernsotieanrsotienaoriestnoairesntoiearnstoieanrste"
      ; W.string "another line"
      ; W.string "another line"
      ; W.string "another line"
      ; W.string "another line"
      ; W.string "another line"
      ; W.string
          "another \
           lineaorsietnaoiresntoiaernstoieanrstoiaernstoiearnostieanroseitnaoriestnoairesntoiaernsotieanrsotienaoriestnoairesntoiearnstoieanrst"
      ]
    |> Ui.keyboard_area (fun x ->
      match x with
      | `ASCII 'p', _ ->
        Lwd.set show_prompt_var @@ Some ("hi prompt", "pre_fill", fun _ -> ());
        `Handled
      | _ ->
        `Unhandled)
    |> Lwd.pure
  in
  let prompt = prompt ~show_prompt_var ui in
  W.h_pane prompt (W.string "other side" |> Lwd.pure)
;;