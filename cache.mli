(* $Header: /net/yquem/devel/caml/repository/bigbro/cache.mli,v 1.1.1.1 2001/02/13 15:39:36 fpottier Exp $ *)

open Link_info

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A cache, used to avoid duplicating checks (it also avoid looping while working recursively). Keys are not simply URLs,
but pairs of a URL and a recursion flag, which define a task.

There is also a waiting room, which is used to store information about the various links which are being looked up
at any given point in time. Every time a URL check completes, we use the waiting room to find all checks associated
to this URL, and we can associate an outcome to each of them. Using such a waiting room is faster and cheaper than
spawning a separate thread for each waiting check. Note that this hash table possibly uses several entries for a single
key.

These mutable structures are shared by several threads, so they are protected by a mutual exclusion lock. (Only one
lock is used, for the sake of simplicity. Providing one lock for each structure would not help much.) In general, the
mutual exclusion zone is not a single operation, but a series of operations, like a find/add combination. Because of
this, the lock is made visible to the caller, and it is not automatically handled by this module.

Note that fragments are never taken into account in the cache/waiting room. Tasks stored in these structures represent
reading/downloading a document, *not* the subsequent fragment check. This is necessary to make sure that if we find
several URLs to the same document, but with different fragments, then we only download the document once. (As a 
consequence of this decision, fragment checks are never cached and thus will be done several times for several 
identical URLs, but they're so fast that this isn't a problem.)

*)

type key = Url.url * bool

val lock: Mutex.t

module Cache : sig
  val add: key -> outcome -> unit
  val find: key -> outcome
end

module Room : sig
  val add: key -> full_link_info -> unit
  val find: key -> full_link_info
  val remove: key -> unit
end
