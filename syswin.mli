(* $Header: /net/yquem/devel/caml/repository/bigbro/syswin.mli,v 1.2 2001/03/01 17:08:34 fpottier Exp $ *)

(* This module contains miscellaneous utilities, which are to be compiled only into the Windows version. *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This utility takes an absolute directory name (as returned by Sys.getcwd) and turns it into a drive specification
(in lowercase) plus a path (i.e. a list of segments).

*)

val drive_path: string -> string * string list

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This one does roughly the reverse operation. It takes a drive specification and a path, and turns them to a full
file name.

*)

val filename: string -> string list -> string

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Under certain brain-dead operating systems, certain brain-dead browsers use brain-dead conventions for URLs.
The job of this function is to detect these cases and remap the URLs to our own convention.

*)

val normalize_url: string -> string

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This function resolves tildes (~) in file names.

*)

val resolve_home: string -> string

