(* $Header: /net/yquem/devel/caml/repository/bigbro/stats.mli,v 1.1.1.1 2001/02/13 15:39:36 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A single record holds our statistics.

*)

type stats = {

  (* Checks. *)

  mutable total: int;				(* Total number of links checked. *)
  mutable successes: int;			(* Total number of links found successful. *)
  mutable failures: int;			(* Total number of links found incorrect. *)

  (* Tasks. *)

  mutable file_head: int;			(* Number of files whose existence was checked. *)
  mutable file_get: int;			(* Number of files read. *)
  mutable file_get_bytes: int;			(* Total size of files read. *)
  mutable http_head: int;			(* Number of remote documents whose existence was checked. *)
  mutable http_get: int;			(* Number of remote documents downloaded. *)
  mutable http_get_bytes: int			(* Total size of documents downloaded. *)

}

val stats: stats

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Functions used to update the stats.

*)

val got_check_outcome: bool -> unit

val did_file_head: unit -> unit
val did_file_get: unit -> unit
val file_size_was: int -> unit
val did_http_head: unit -> unit
val did_http_get: unit -> unit
val http_size_was: int -> unit
