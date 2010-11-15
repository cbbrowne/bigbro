(* $Header: /net/yquem/devel/caml/repository/bigbro/media_type.mli,v 1.1.1.1 2001/02/13 15:39:34 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This type describes a media type field, as defined by the HTTP/1.1 protocol.

*)

type media_type

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Exceptions.

*)

exception ParseError

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Create parses a media type string.

*)

val create: string -> media_type

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A list of known character sets.

*)

type charset =
    CharsetISO_8859_1
  | CharsetISO_2022_JP
  | CharsetEUC_JP
  | CharsetSJIS

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

The first function determines whether this media type is text/html (with possible additional parameters).

The second one returns the character set specified by this media type. It should only be called if the main type
is text. If the media type doesn't explicitly specify a charset, or if it specifies an unknown one,
ISO-8859-1 is assumed.

*)

val is_text_html: media_type -> bool
val charset: media_type -> charset

