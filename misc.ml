(* $Header: /net/yquem/devel/caml/repository/bigbro/misc.ml,v 1.4 2001/07/17 08:46:24 fpottier Exp $ *)

#load "./pcreg.cmo";;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Extracting a value out of an option type, doing something with it, and doing nothing if it's absent.

*)

let do_option value action =
  match value with
    Some value ->
      action value
  | None ->
      ()
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Trying an action and doing nothing if Not_found is raised.

*)

let do_if_found action =
  try
    action()
  with Not_found ->
    ()
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Extracting a port number out of a server name.

*)

exception InvalidPort of string

let name_and_port default_port combined =
  try
    extract _, server, port matching combined against "^(.*):([0-9]+)$" in
    try
      server, int_of_string port
    with Failure _ ->
      raise (InvalidPort port)
  with Not_found ->
    combined, default_port
;;

