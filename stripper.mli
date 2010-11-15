(* $Header: /net/yquem/devel/caml/repository/bigbro/stripper.mli,v 1.1.1.1 2001/02/13 15:39:35 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Strip parses a piece of HTML text and removes any tags from it. If requested, it converts any whitespace to actual
spaces. Then, it drops any initial whitespace. If the result string is empty, it returns None; otherwise it returns it.

Arguments:
- a flag telling whether whitespace should be converted.
- the string to be converted.

*)

val strip: bool -> string -> string option
