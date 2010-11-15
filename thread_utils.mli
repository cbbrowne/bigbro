(* $Header: /net/yquem/devel/caml/repository/bigbro/thread_utils.mli,v 1.1.1.1 2001/02/13 15:39:35 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A utility which protects an operation with a mutex.

*)

val protect: Mutex.t -> ('a -> 'b) -> 'a -> 'b
