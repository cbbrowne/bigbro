(* $Header: /net/yquem/devel/caml/repository/bigbro/link_info.mli,v 1.3 2001/03/09 14:49:29 fpottier Exp $ *)

open Http_connection
open Media_type
open Url

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Known (tag, attribute) pairs.

*)

type tag_type =
  | TagInitial
  | TagAHref
  | TagAppletArchive
  | TagAppletCode
  | TagAppletCodebase
  | TagAppletObject
  | TagAreaHref
  | TagBaseHref
  | TagBlockquoteCite
  | TagBodyBackground
  | TagDelCite
  | TagDivHref
  | TagFormAction
  | TagFrameLongdesc
  | TagFrameSrc
  | TagHeadProfile
  | TagIframeLongdesc
  | TagIframeSrc
  | TagImgLongdesc
  | TagImgSrc
  | TagImgUsemap
  | TagInputSrc
  | TagInputUsemap
  | TagInsCite
  | TagLinkHref
  | TagObjectCodebase
  | TagObjectArchive
  | TagObjectClassid
  | TagObjectData
  | TagObjectUsemap
  | TagQCite
  | TagScriptSrc
  | TagSpanHref

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This structure contains all relevant information about one occurrence of a link in a piece of HTML text.

*)

type link_info = {
    link_tag_type: tag_type;				(* What kind of link this is *)
    link_line: int;					(* Link position within source text *)
    link_column: int;
    link_text: string;					(* Link URL, in textual form *)
    link_name: string option				(* Link name, if meaningful *)
  }

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This structure carries all relevant information about a link. What are the differences with the above structure?
First, this one does not assume that the link comes from a piece of HTML text. Second, converting from one to the
other might raise exceptions which cannot be handled inside the HTML skimmer - hence the needs for two separate
structures.

The document source is None if the link is initial, i.e. if it was provided by the user on the command line.

*)

type full_link_info = {
    fli_tag_type: tag_type;				(* What kind of link this is *)
    fli_line: int;					(* Link position within source text *)
    fli_column: int;
    fli_url_text: string;				(* Original, unresolved URL text *)
    fli_url: url;					(* Resolved, unmapped URL *)
    fli_mapped_url: url;				(* Resolved, mapped URL *)
    fli_name: string option;				(* Link name, if meaningful *)
    fli_source: document_source option			(* Information about the document, None if initial link *)
  } 

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Describing a document.

*)

and document_source = {
  source_url: url;					(* Document URL *)
  mutable source_charset: charset			(* Document character set *)
}

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Describing the outcome of a check.

*)

type early_error =
  | EarlyInvalidURL of string (* explanation *)
  | EarlyInvalidMappedURL of string * string * string (* resolved URL, mapped URL, explanation *)
  | EarlyBaseNotAbsolute

type outcome =
  | OutcomeLocalFailure of local_failure
  | OutcomeLocalSuccess
  | OutcomeRemoteFailure of http_error
  | OutcomeTimeout
  | OutcomeRemoteSuccess
  | OutcomeMoved of bool * string
  | OutcomeServerFailure of int
  | OutcomeFragmentFailure of string
  | OutcomeIllegalFragment
  | OutcomeIgnored

and local_failure =
  | LFailNoSuchFile
  | LFailNoTrailingSlash
  | LFailUnreadable

val is_successful: outcome -> bool

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

These functions are called by the link checking engine whenever a check is complete. They print a description of the
result on standard output.

*)

val got_early_error: link_info -> document_source option -> early_error -> unit
val got_check_result: full_link_info -> outcome -> unit

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

These functions are to be called at the end, to emit some final data before closing the raw/HTML channels.

*)

val raw_postamble: unit -> unit
val html_postamble: unit -> unit
