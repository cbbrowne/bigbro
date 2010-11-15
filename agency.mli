(* $Header: /net/yquem/devel/caml/repository/bigbro/agency.mli,v 1.1.1.1 2001/02/13 15:39:35 fpottier Exp $ *)

open Link_info
open Url

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This module implements a "job agency" - i.e. a waiting queue of URLs waiting to be checked.

JobInitial carries:
- an (unmapped) URL to be checked, in textual form

JobNetworkCheck carries:
- an unmapped URL
- a mapped URL, which is the network URL to be checked
- a flag indicating whether recursion is desired

JobRecurse carries:
- a piece of HTML text to be parsed and checked
- the (unmapped) URL associated to this text
- the actual document source (mapped)

*)

type job =
    JobInitial of string
  | JobNetworkCheck of url * url * bool
  | JobRecurse of string * url * document_source

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This function must be called once to initialize the module. Its first parameter specifies what to do with the jobs.
Its second parameters specifies what to do when the last job has been executed (i.e. the thread count drops to 0 and
the queue is empty).

*)

val initialize: (job -> unit) -> (unit -> unit) -> unit

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Adding job descriptions to the queue. They shall be processed, in order, when threads are available.

*)

val add: job -> unit

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This function must be called whenever a spawned thread is terminated abnormally. It is used to keep track
of the number of running threads. (Normal termination, by returning a value or raising an exception, is taken
care of automatically; this function should be called only when explicitly killing a thread.)

*)

val killed: unit -> unit

