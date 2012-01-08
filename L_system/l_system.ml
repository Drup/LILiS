open Graphic_order ;;
open Lsys_engine
open Type ;;
open Syntaxe ;;


let bank_ls = lsystem_from_chanel (open_in "L_system/bank_lsystem") in
print_int (List.length bank_ls) ; print_newline() ;
let lsys = List.hd bank_ls in


let time = ref (Unix.gettimeofday ()) in


print_endline "Generating graphic_order list" ;
let lstream = eval_lsys 3 lsys in

print_endline "Executing graphic orders" ;
let graphiclist = lstream_to_graphiclist lstream in
print_float (Unix.gettimeofday () -. !time) ; print_newline();


print_endline "I'm drawing !" ;

let expose area ev =
	let time = ref (Unix.gettimeofday ()) in
	let turtle = new Crayon.turtle (Crayon.Gtk area) in
	let n = draw turtle graphiclist in
	turtle#draw () ;
	print_string "Draw finished : " ; print_int n ; print_endline " element" ;
	print_float (Unix.gettimeofday () -. !time) ; print_newline();
	true
in

(*let window = GWindow.window ~width:500 ~height:500 ~title:"L-system" () in*)
(*ignore (window#connect#destroy GMain.quit);*)
(*let area = GMisc.drawing_area ~packing:window#add () in*)
(*area#misc#set_double_buffered false;*)
(*ignore(area#event#connect#expose (expose area));*)

(*window#show ();*)
(*print_float (Unix.gettimeofday () -. !time) ; print_newline();*)
(*GMain.main () ;*)

let turtle = new Crayon.turtle (Crayon.Picture (400.,400.)) in
turtle#fill() ;
let n = draw turtle graphiclist in
turtle#draw() ;
turtle#write "test.png" ;
print_string "Draw finished : " ; print_int n ; print_endline " element" ;
print_float (Unix.gettimeofday () -. !time) ; print_newline();
