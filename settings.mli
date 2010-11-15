(* $Header: /net/yquem/devel/caml/repository/bigbro/settings.mli,v 1.2 2001/07/16 15:04:05 fpottier Exp $ *)

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This module is invoked before main starts running, and is in charge of parsing command line arguments and turning
them into settings.

*)
(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A version banner.

*)

val html_banner: string

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Mappings.

These are used to operate textual substitutions in URLs before checking them; typically, this can be used to map
remote URLs to local ones.

*)

val mappings: (Pcre.regexp * Pcre.substitution) list

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Recursion.
This regular expression, if defined, is used to determine which URLs should be recursively checked.

I have thought about adding a -depth flag to specify how deep links should be followed. However, this is a lot more
difficult than it sounds. The reason is, there might several paths of different lengths that lead to a given node
in the graph. If a node is first found at depth k, then its sub-graph is recursively visited with limit (depth - k).
If, later, we reach the same node at depth less than k, then we have to revisit its sub-graph again, but this time
with a larger limit. It is difficult, in these conditions, to avoid work duplication: a large part of the sub-graph
has to be visited again. To avoid this duplication, we would have to actually store a representation of the graph
in memory, which might be costly in terms of space, and would definitely be bothersome.

*)

val recursion: Pcre.regexp option

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Enabling checking of local or remote links.

*)

val local: bool
val remote: bool

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

The name of the index file.

*)

val index: string

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A regular expression matching local HTML files.

*)

val local_html_files: Pcre.regexp

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Proxy settings.

First, we have the proxy name and port number; then, a regular expression indicating when to bypass the proxy.

*)

val proxy: (string * int) option
val noproxy: Pcre.regexp option

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

The maximum number of concurrent threads.

*)

val max_threads: int

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A list of anonymous arguments. (They are not handled directly in this module in order to avoid a circular dependency.)
A flag indicating whether more should be read from standard input.

*)

val anonymous: string list
val stdin: bool

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A timeout value, in seconds. If None, then the timeout value is infinite.

*)

val timeout: float option

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This is the minimum delay between hits to a given server, in seconds. If None, then requests are sent out as
quickly as possible.

*)

val gentle: float option

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A list of regular expressions (corresponding to realms), each accompanied by user and password strings.
To be used for authentication.

*)

val realms: (Pcre.regexp * string * string) list

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A series of output modules. Each one encapsulates an output channel.

The printer takes a deferred string (i.e. a function which produces a string when called) as argument, rather than
a string, because this allows saving time when nothing needs to be printed.

*)

module type OutputSig = sig

  val print: (unit -> string) -> unit
  val close: unit -> unit

end

module RawOutput : OutputSig
module HtmlOutput : OutputSig
module DebugOutput : OutputSig

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

If this flag is set, only failures are reported. This affects both raw and HTML output.

*)

val failures: bool

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

If this flag is set, fragment identifiers are properly checked. Otherwise, they are ignored.

*)

val fragments: bool

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A list of regexps describing URLs to be ignored.

*)

val ignore: Pcre.regexp list

