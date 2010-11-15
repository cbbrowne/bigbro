(* $Header: /net/yquem/devel/caml/repository/bigbro/link_skimmer.mli,v 1.1.1.1 2001/02/13 15:39:36 fpottier Exp $ *)

open Link_info

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

These are the hooks to be supplied by the caller. The first one is called whenever a link is found. The second one
is called when a content type specification is found.

The first argument to found_link is a local base URL, i.e. a URL which should be considered as a base URL when
resolving the URL contained in the link_info structure. The local base URL might itself be relative with respect
to the document's base URL.

A record is used, rather than a functor, because it allows creating the callbacks dynamically (i.e. possibly by
partial application), rather than statically (i.e. requiring named toplevel functions).

*)

type callbacks = {
  found_link: string option -> link_info -> unit;
  found_content_type: string -> unit
} 

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Skim parses a piece of HTML text and calls the above hooks when necessary.

*)

val skim: callbacks -> string -> unit

