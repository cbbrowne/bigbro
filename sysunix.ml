(* $Header: /net/yquem/devel/caml/repository/bigbro/sysunix.ml,v 1.5 2001/07/17 08:46:24 fpottier Exp $ *)

(* This module contains miscellaneous utilities, which are to be compiled only into the Unix version. *)

#load "./pcreg.cmo";;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This utility takes an absolute directory name (as returned by Sys.getcwd) and turns it into a drive specification
(in lowercase) plus a path (i.e. a list of segments). Under Unix, the drive string is always empty.

*)

let rec rev_path dirname =
  let upperdirname = Filename.dirname dirname in
  if upperdirname = dirname then
    []
  else
    (Filename.basename dirname) :: (rev_path upperdirname)
;;

let drive_path dirname =

  (* Extract all of the path segments, in reverse order. *)

  let path = rev_path dirname in

  (* Add an empty one at the end (for the trailing slash) and put them back in the right order. *)

  let path = List.rev ("" :: path) in

  (* Return an empty drive string, plus the path. *)

  "", path
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This one does roughly the reverse operation. It takes a drive specification and a path, and turns them to a full
file name.

*)

let filename _ path =
  List.fold_left Filename.concat "/" path
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Normalizing URLs is a no-op under Unix, since the Unix version of Netscape uses our convention for file: URLs.

*)

let normalize_url text =
  text
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This function resolves tildes (~) in file names. Its argument is a URL in textual form.

The regular expression looks for the right-most `~' character in a string. It will match only if the string begins
with "file://" and if the `~' character is preceded by a `/' character. The second group represents the word
following the `~' character (a word is a sequence which contains no `/' character).

*)

let resolve_home url =
  try
    extract _, _, username, residual matching url against "file://(.*)/~([^/~]*)([^~]*)" in
    let entry = Unix.getpwnam username in
    "file://" ^ entry.Unix.pw_dir ^ "/public_html" ^ residual
  with Not_found -> (* from [extract] or [Unix.getpwnam] *)
    url

