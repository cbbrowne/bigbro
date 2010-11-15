(* $Header: /net/yquem/devel/caml/repository/bigbro/check_http.mli,v 1.1.1.1 2001/02/13 15:39:34 fpottier Exp $ *)

open Url

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Checking a HTTP URL. This function actually establishes the connection, produces an outcome and reports is. It takes
care of queuing a recursion request if necessary.

Arguments:
- the unmapped URL
- the mapped URL
- whether recursion is desired for this URL

*)

val check: url -> url -> bool -> unit

