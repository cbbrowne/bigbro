(* $Header: /net/yquem/devel/caml/repository/bigbro/check_master.mli,v 1.1.1.1 2001/02/13 15:39:34 fpottier Exp $ *)

open Link_info
open Url

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Checking a piece of HTML text.

Arguments:
- The HTML text.
- The unmapped document URL.
- The document source (which contains the mapped URL).

*)

val check_html: string -> url -> document_source -> unit

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Checking an initial link (one supplied on the command line).

Arguments:
- The URL to be checked, in textual form.

*)

val check_initial_link: string -> unit

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This function should be internal, but has to be published because http link checking is done in a separate thread.

It should be called whenever a check task is complete and its result is available. It assumes that there is at
least one entry for this task in the waiting room.

Arguments:
- The task (unmapped URL and recursion flag).
- The outcome.

*)

val got_task_outcome: (url * bool) -> outcome -> unit

