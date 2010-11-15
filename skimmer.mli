(* $Header: /net/yquem/devel/caml/repository/bigbro/skimmer.mli,v 1.2 2001/03/09 14:49:30 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This structure contains the information passed to the callback when it is called.

*)

module StringMap: Map.S with type key = string

type attribute_value = (int * int * string) option      (* The attribute's value (if any) and its position. *)

type tag_info = {
  ti_text: string;                                      (* The document's text. *)
  ti_index: int;                                        (* The position of this tag's closing angle bracket. *)
  ti_tag_start: int;                                    (* The start and end positions of the tag's name. *)
  ti_tag_end: int;
  ti_tag_attr: attribute_value StringMap.t              (* The list of the tag's attributes. *)
}

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Skim parses a piece of HTML text and calls the supplied callback whenever a tag is found.

*)

val skim: (tag_info -> unit) -> string -> unit

