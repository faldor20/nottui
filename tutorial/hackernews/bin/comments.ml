open! Nottui
open! Notty
open! Hackernews_api
open! Lwd_infix




(*
let rec comment ?(focus = Focus.make ()) ({by; kids; text; id; _} : comment) =
  let show_children = Lwd.var false in
  let children_var = Lwd.var None in
  let comment_content =
    Ui.vcat [W.string text; W.fmt "by: %s" by] |> Lwd.pure
  in
  let children_ui =
    let$* show_children = Lwd.get show_children
    and$ children = Lwd.get children_var in
    if show_children then
      children |> Option.value ~default:[]
      |> List.map (fun x -> W.hbox [W.string "--" |> Lwd.pure; comment x])
      |> W.vbox
    else Ui.empty |> Lwd.pure
  in
  W.vbox
    [ comment_content
      |> Lwd.map2 (focus |> Focus.status) ~f:(fun _focus ui ->
             ui
             |> Ui.keyboard_area  (function
                  | `Enter, [] ->
                      if Lwd.peek show_children == false then (
                        show_children $= true ;
                        if Lwd.peek children_var |> Option.is_none then
                          (* "fetch" the child comments*)
                          children_var
                          $= Some
                               ( kids
                               |> List.map
                                    (Hackernews_api.generate_fake_comment id) )
                        )
                      else show_children $= false ;
                      `Handled
                  | _ ->
                      `Unhandled ) )
      |> W.Box.focusable ~focus
    ; children_ui ]

let comments_view ?(focus = Focus.make ()) (post : post) =
  let comments =
    post.kids |> List.map (Hackernews_api.generate_fake_comment post.id)
  in
  let comment_uis =
    if comments |> List.length > 0 then
      (comments |> List.hd |> comment ~focus)
      :: (comments |> List.tl |> List.map comment)
    else []
  in
  comment_uis |> W.vbox |> W.Box.focusable
*)

(*
TODO
Totally refactor this.
show the parent at the top
show the children below as a selection list
when selecting a comment with childrent show it at the top and it's children in the list. This should fix the challenges of scrolling inside trees
*)
(*
let  make_comment_ui_attr ~(attr) (comment : comment Lwd.t) =
  let comment_content =
  let$ {by; text;_}= comment in 
    Ui.vcat [W.string text; W.fmt "by: %s" by] 
  in
  W.vbox
    [ comment_content
      |> W.Box.with_border_attr attr
   ]
 ;;

let  make_comment_ui ?(focus = Focus.make ()) (comment : comment Lwd.t) =
make_comment_ui_attr ~attr:(focus|>Focus.status|>$(fun focus -> if Focus.has_focus focus then A.(fg blue)else A.empty)) comment
 ;;

let comment_children_view ?(focus = Focus.make ()) (comments_view_state) =
  let parent_ui=
    let$* state= Lwd.get comments_view_state in

    state|>List.hd|>fst|>Option.map (fun x-> make_comment_ui (x|>Lwd.pure))|>Option.value ~default:(Ui.empty |>Lwd.pure)
    in
  let children_ui =
    let items=
      let$ state = Lwd.get comments_view_state in
        state
        |>List.hd
        |>snd 
        |> List.map (fun x -> W.Lists.{data=x;
        ui= W.Lists.selectable_item_lwd (W.hbox [W.string "--"|>Lwd.pure ; make_comment_ui (x|>Lwd.pure)])})
      in
      items|> W.Lists.selection_list_custom ~focus ~custom_handler:(fun item key ->
        match key with 
        |`Enter,[]->
          comments_view_state|>Lwd.update (fun x-> (Some item.data, item.data.kids
                   |> List.map
                        (Hackernews_api.generate_fake_comment item.data.id))::x );
        `Handled
        |_->`Unhandled
      )
  in
  W.vbox[
  parent_ui;
  children_ui;
  ]|> W.Box.focusable ~focus ~on_key:(function
        |`Escape,[]->
          let view_state= Lwd.peek comments_view_state in
          if view_state|>List.length >1 then
            comments_view_state$= (view_state|>List.tl)
          else
            Focus.release_reversable focus;

        `Handled
    |_->`Unhandled
  )
*)


let comments_view ?(focus = Focus.make ()) (post  : post  option Lwd.t) =

  let$ post = post in
  match post with 
  |None-> Ui.empty  |Some post->
  let _=focus in
          let children=( post.kids
                   |> List.map
                        (Hackernews_api.generate_fake_comment post.id) )in


        children|>List.map (fun x->W.string x.text)|>Ui.vcat


