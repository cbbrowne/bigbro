(* $Header: /net/yquem/devel/caml/repository/bigbro/base64.mli,v 1.1.1.1 2001/02/13 15:39:33 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This exception is raised by the decoder iff the input stream is ill-formed.

*)

exception Malformed

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Base64 coding/decoding, conforming to RFC 2045, except for white space - the encoder does not break lines at 76
characters, and the decoder does not accept white space.

*)

val encode : string -> string
val decode : string -> string
