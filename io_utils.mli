(* $Header: /net/yquem/devel/caml/repository/bigbro/io_utils.mli,v 1.1.1.1 2001/02/13 15:39:34 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Read_whole_file reads in a whole file at once. It can raise Sys_error.

*)

val read_whole_file: string -> string
