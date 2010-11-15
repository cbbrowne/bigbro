(* $Header: /net/yquem/devel/caml/repository/bigbro/check_file.mli,v 1.1.1.1 2001/02/13 15:39:34 fpottier Exp $ *)

open Link_info
open Url

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Checking a file URL. This function checks that the file or directory exists, produces an outcome and takes care of
queuing a recursion request if necessary.

Arguments:
- the unmapped URL
- the mapped URL
- whether recursion is desired for this URL

*)

val check: url -> url -> bool -> outcome

