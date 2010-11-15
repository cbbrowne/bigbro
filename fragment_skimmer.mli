(* $Header: /net/yquem/devel/caml/repository/bigbro/fragment_skimmer.mli,v 1.1.1.1 2001/02/13 15:39:36 fpottier Exp $ *)

open Url

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This module parses pieces of HTML text and keeps track of the sets of fragment identifiers defined in them.

Analyze parses the supplied document, extracts its fragment identifiers and stores them internally with the specified
URL as key. (If the URL carries a fragment, it is ignored.)

Analyzed tells whether a specific document has been analyzed already. (This feature is important; it allows
downloading a document only once, even when several fragment-carrying URLs point to it.)

Exists checks whether the specified fragment identifier exists within the specified document. (If the URL carries
a fragment, it is ignored.) If the document hasn't been analyzed before, Not_found is raised. This means that the
file wasn't an HTML document (it would otherwise have been analyzed).

*)

val analyze: url -> string -> unit
val analyzed: url -> bool
val exists: url -> string -> bool

