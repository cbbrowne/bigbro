(* $Header: /net/yquem/devel/caml/repository/bigbro/url.mli,v 1.1.1.1 2001/02/13 15:39:35 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A module to deal with URLs in an abstract way.

*)

type url

(* Creating a URL from a string representation. If the URL is absolute, it must have a known scheme (currently "file"
   or "http", else UnknownScheme is raised. The function can also raise Url_syntax.Malformed. *)

exception UnknownScheme

val create: string -> url

(* Note that URLs can be compared using O'Caml's builtin comparison and hashing functions. *)

(* Printing a URL to a string.
   Arguments:
   - a flag telling whether the fragment should be printed.
   - the URL to be printed.
   Export works the same way but creates a string that will be understood by a browser, and which I regard as
   non-compliant.
*)

val print: bool -> url -> string
val export: bool -> url -> string

(* Determining whether a URL ends with a slash. *)

val is_directory: url -> bool

(* Determining whether a URL is absolute. *)

val is_absolute: url -> bool

(* Resolving a relative URL with respect to an absolute URL.
   Arguments:
   - the base URL, which must be absolute. Exception NotAbsolute is thrown if it isn't.
   - the relative URL.
*)

exception NotAbsolute

val resolve: url -> url -> url

(* Dropping/obtaining a URL's fragment. *)

val drop_fragment: url -> url
val get_fragment: url -> string option

(* Creating an HTTP request for an absolute http URL.
   Arguments:
   - a flag telling whether the request should be a HEAD or a GET request.
   - a flag telling whether the request is intended for a proxy server or for a regular server.
   - the URL to be requested. Exception NotAbsolute is raised if it isn't absolute.
   Returns:
   - the text of the request.
   - the name of the proxy/server it should be sent to.
   - the port number of the proxy/server it should be sent to.

   If the URL has a fragment, it is omitted from the request. *)

type http_request_type =
    HEAD
  | GET

val create_http_request: http_request_type -> url -> string * string * int

(* Dispatching according to a URL's protocol.
   Arguments:
   - a function to be called for "file" URLs.
   - a function to be called for "http" URLs.
   - the absolute URL, which must be absolute (NotAbsolute is raised otherwise). *)

val dispatch_scheme: (unit -> 'a) -> (unit -> 'a) -> url -> 'a

(* Converting an absolute "file" URL to a full file name. *)

val filename: url -> string

(* Creating an absolute "file" URL for the current directory. *)

val of_cwd: unit -> url

(* Getting a URL's basename. *)

val basename: url -> string

