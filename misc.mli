(* $Header: /net/yquem/devel/caml/repository/bigbro/misc.mli,v 1.2 2001/07/16 15:04:03 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Extracting a value out of an option type, doing something with it, and doing nothing if it's absent.

*)

val do_option: 'a option -> ('a -> unit) -> unit

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Trying an action and doing nothing if Not_found is raised.

*)

val do_if_found: (unit -> unit) -> unit

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Extracting a port number out of a server name. Returns the machine name and the port number if both are present, the
machine name and the default port number otherwise. Raises InvalidPort if the port isn't a number.

Arguments:
- the default port number
- the combined machine/port spec

*)

exception InvalidPort of string

val name_and_port: int -> string -> string * int

