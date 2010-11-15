(* $Header: /net/yquem/devel/caml/repository/bigbro/linear_connection.mli,v 1.1.1.1 2001/02/13 15:39:34 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Exceptions.

*)

type connection_action =
    CouldNotCreateSocket
  | CouldNotResolve
  | CouldNotBind
  | CouldNotConnect
  | CouldNotSend
  | CouldNotReceive
  | CouldNotClose

exception ConnectionError of connection_action * Unix.error

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Request opens a connection to the specified host and port, and sends the supplied request. Then, it reads the answer
until the connection is closed by the other end, and returns the answer to the caller. It blocks the current thread.
It might throw the above exception.

Arguments:
  - the request to be sent
  - the host name
  - the port number
  - a timeout function, to be called by Timer if the timeout fires and the thread handling this request is killed

*)

val request: string -> string -> int -> (unit -> unit) -> string

