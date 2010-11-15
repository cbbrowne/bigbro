(* $Header: /net/yquem/devel/caml/repository/bigbro/timer.mli,v 1.1.1.1 2001/02/13 15:39:35 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This module allows crude scheduling of tasks to be executed in the future.

The delay between the moment a task is queued and the moment it is actually run is constant (and obtained from the
Settings). This hypothesis is rather strict, but it allows a more efficient implementation based on a FIFO queue.
Furthermore, if the Settings specify that no timeouts should be used, then all operations provided by this module
become no-ops.

The code whose execution is being requested *cannot* make calls to this module. (This is because it is executed while
the lock is acquired; this guarantees that if a call to cancel raises Not_found, then the task has been fully run.)

*)

type task = Task of (unit -> unit)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Schedule queues a request to execute a task in the future.

Cancel dequeues a previous request. Physical comparison is used on requests. Not_found is raised if the request can't
be found. In that case, the request is guaranteed to have been fully executed.

*)

val schedule: task -> unit
val cancel: task -> unit

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This function provides the heartbeat of the timer; it must be called as often as possible.

*)

val beat: unit -> unit

