open Nottui
open Notty
open Hackernews_api

(*
$#S1
open Nottui
open Notty
open Hackernews_api

let main_ui =
   W.vbox[
    W.string "hello world"|>Lwd.pure
  ]
$#E1
*)

(* We can make a heper function to render a post *)
(*$#S2*)
let post_ui ({ title; url; score; comments; _ } : Hackernews_api.post) : ui Lwd.t =
  let website = List.nth (String.split_on_char '/' url) 2 in
  Ui.vcat
    [ Ui.hcat
        [ W.string ~attr:A.(st bold) title; W.printf ~attr:A.(st italic) "(%s)" website ]
    ; Ui.hcat 
        [ W.printf ~attr:A.(st italic) "%d points" score
        ; W.printf ~attr:A.(st italic) "%d comments" comments
        ]
    ]
  |> Lwd.pure
  |> W.Box.focusable
;;
(*$#E2*)

(*Generate some posts and render them using our post_renderer*)
let main_ui : ui Lwd.t =
  let posts = Hackernews_api.fake_posts () in
  posts |> List.map post_ui |> W.vbox
;;

(*Start the nottui process with our built up ui*)
let () = Nottui.Ui_loop.run ~quit_on_escape:false main_ui
