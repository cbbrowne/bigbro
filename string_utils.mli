(* $Header: /net/yquem/devel/caml/repository/bigbro/string_utils.mli,v 1.1.1.1 2001/02/13 15:39:35 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Substring implements a subset of module String's interface. It is designed to allow working with substrings of
a fixed, immutable string. The advantage is that 'sub' no longer involves copying.

*)

module Substring : sig

  type t

  val length: t -> int
  val get: t -> int -> char
  val sub: t -> int -> int -> t
  val blit: t -> int -> string -> int -> int -> unit

  val of_string: string -> t
  val to_string: t -> string

end

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

The following utilities make sense for strings and for substrings as described above. As a result, we have
parameterized them.

*)

module type CommonSig = sig

  (* t stands for string or Substring.t *)

  type t

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

split splits the specified (sub)string at the specified offset. It can raise Invalid_argument.

*)

  val split: t -> int -> t * t

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

chop looks for the first character which satisfies the given predicate. If none exists, it raises Not_found.
Otherwise, it returns the first part of the (sub)string, the character itself, and the second part of the (sub)string.

filter cuts the (sub)string in two parts: the characters which verify the predicate, and those which follow. It does
not raise any exception.

*)

  val chop: (char -> bool) -> t -> t * char * t
  val filter: (char -> bool) -> t -> t * t

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

iter iterates the supplied function on each character of the supplied (sub)string.
fold does the same, but maintains an accumulator.

*)

  val iter: (char -> unit) -> t -> unit
  val fold: ('a -> char -> 'a) -> 'a -> t -> 'a

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

flatten converts a list of (sub)strings to a string, in linear time.

*)

  val flatten: t list -> string

end

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Now, the actual implementations, one for strings and for substrings.

*)

module StringOp : CommonSig with type t = string
module SubstringOp: CommonSig with type t = Substring.t

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Shorten returns its parameter unchanged if it is shorter than the specified limit; otherwise, it removes its middle
portion and put an ellipsis in its place. The limit must be 3 at least.

*)

val shorten: int -> string -> string

