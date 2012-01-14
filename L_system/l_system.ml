open Graphic_order ;;
open Lsys_engine
open Syntaxe ;;
open Type ;;

let get_lsystem file =
	let bank_ls = lsystem_from_chanel (open_in file) in
	BatList.iteri (fun i lsys -> Printf.printf "%N: %s\n" (i+1) (lsys.name)) bank_ls ;
	print_string "Which L-system do you choose ? " ;
	let lsys = List.nth bank_ls (read_int()-1) in
	print_string "Which generation ? " ;
	eval_lsys (read_int()) lsys


let print_time =
	let time = ref (Unix.gettimeofday ()) in
	fun () -> print_float (Unix.gettimeofday () -. !time) ; time := Unix.gettimeofday () ; print_newline()

let bench lstream f =
	print_time () ;
	print_endline "I'm drawing !" ;
	f lstream ;
	print_endline "I'm done !" ; print_time ()


let gtk_main lstream =
	let expose area ev =
		let turtle = new Crayon.turtle (Crayon.Gtk area) in
		draw turtle lstream ;
		turtle#draw () ;
		print_time () ;
		true
	in
	ignore(GMain.init());
	let window = GWindow.window ~width:700 ~height:700 ~title:"L-system" () in
	ignore (window#connect#destroy GMain.quit);

	let	area = GMisc.drawing_area ~packing:window#add () in
	area#misc#set_double_buffered false;
	ignore(area#event#connect#expose (expose area));
	window#show ();
	GMain.main ()


let png_main lstream =
	let turtle = new Crayon.turtle (Crayon.Picture (1000,1000)) in
	turtle#fill() ;
	draw turtle lstream ;
	turtle#draw () ;
	turtle#write "test.png"


let _ = bench (get_lsystem "L_system/bank_lsystem") gtk_main ;;
