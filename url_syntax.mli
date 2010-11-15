(* $Header: /net/yquem/devel/caml/repository/bigbro/url_syntax.mli,v 1.1.1.1 2001/02/13 15:39:35 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Each of these functions makes sure that the specified string contains only valid characters and normalizes it with
respect to escape sequences.

*)

exception Malformed of string

val normalize_scheme: string -> string
val normalize_net_loc: string -> string
val normalize_query: string -> string
val normalize_fragment: string -> string
val normalize_param: string -> string
val normalize_segment: string -> string

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This function takes a raw string, and escapes all characters which are invalid in a segment.

*)

val escape_segment: string -> string

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This function takes a string and converts all escape sequences back to raw characters.

*)

val raw: string -> string

