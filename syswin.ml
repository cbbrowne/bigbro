(* $Header: /net/yquem/devel/caml/repository/bigbro/syswin.ml,v 1.5 2001/07/17 08:46:24 fpottier Exp $ *)

(* This module contains miscellaneous utilities, which are to be compiled only into the Windows version. *)

#load "./pcreg.cmo";;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This utility takes an absolute directory name (as returned by Sys.getcwd) and turns it into a drive specification
(in lowercase) plus a path (i.e. a list of segments). Under Windows, the drive string is of the form a:, b:, c:,
and so on.

*)

let rec drive_rev_path dirname =
  try
    extract _ matching dirname against "^[A-Za-z]:$" in
    dirname, []
  with Not_found ->
    let upperdirname = Filename.dirname dirname in
    let drive, path = drive_rev_path upperdirname in
    drive, (Filename.basename dirname) :: path
;;

let drive_path dirname =

  (* Extract the drive and all of the path segments, in reverse order. *)

  let drive, path = drive_rev_path dirname in

  (* Add an empty one at the end (for the trailing slash) and put them back in the right order. *)

  let path = List.rev ("" :: path) in

  (* Convert the drive to lowercase, because it shall become the "server" part of the file: URL. *)

  let drive = String.lowercase drive in

  (* Return the results. *)

  drive, path
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This one does roughly the reverse operation. It takes a drive specification and a path, and turns them to a full
file name.

I don't use Filename.concat, mainly because it doesn't work the way I expect under Windows, and also because this
is a system-specific module, so I can hardcode a backslash and know what's going on.

*)

let filename drive path =
  List.fold_left (fun x y -> x ^ "\\" ^ y) drive path
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Under Windows, Netscape Navigator seems to use URLs of the form file:///C:/ instead of file://C:/
                           and drive specifications of the form C|          instead of C:

We fix these problems and make sure that the URL follows our convention.

*)

let normalize_url text =
  try
    extract _, head, tail matching text against "^file:///?([^/])[:|]/(.*)$" in
    "file://" ^ head ^ ":/" ^ tail
  with Not_found ->
    text
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This function resolves tildes (~) in file names. It does nothing under Windows.

*)

let resolve_home filename =
  filename

