(* $Header: /net/yquem/devel/caml/repository/bigbro/link_info.ml,v 1.6 2001/07/17 08:46:24 fpottier Exp $ *)

open Http_connection
open Linear_connection
open Media_type
open Stats
open Url

#load "./pcreg.cmo";;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Mirror type declarations.

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

type link_info = {
    link_tag_type : tag_type;
    link_line: int;
    link_column: int;
    link_text: string;
    link_name: string option
  }

type full_link_info = {
    fli_tag_type: tag_type;
    fli_line: int;
    fli_column: int;
    fli_url_text: string;
    fli_url: url;
    fli_mapped_url: url;
    fli_name: string option;
    fli_source: document_source option
  } 

and document_source = {
  source_url: url;
  mutable source_charset: charset
}

type early_error =
  | EarlyInvalidURL of string
  | EarlyInvalidMappedURL of string * string * string
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

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Determining whether an outcome is successful.

*)

let is_successful = function
  | OutcomeRemoteSuccess
  | OutcomeLocalSuccess
  | OutcomeIgnored -> true
  | _ -> false
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

A bunch of printing functions, basically one per data type.

*)

let print_tag_type = function
  | TagInitial -> "Initial"
  | TagAHref -> "AHref"
  | TagAppletArchive -> "AppletArchive"
  | TagAppletCode -> "AppletCode"
  | TagAppletCodebase -> "AppletCodebase"
  | TagAppletObject -> "AppletObject"
  | TagAreaHref -> "AreaHref"
  | TagBaseHref -> "BaseHref"
  | TagBlockquoteCite -> "BlockquoteCite"
  | TagBodyBackground -> "BodyBackground"
  | TagDelCite -> "DelCite"
  | TagDivHref -> "DivHref"
  | TagFormAction -> "FormAction"
  | TagFrameLongdesc -> "FrameLongdesc"
  | TagFrameSrc -> "FrameSrc"
  | TagHeadProfile -> "HeadProfile"
  | TagIframeLongdesc -> "IframeLongdesc"
  | TagIframeSrc -> "IframeSrc"
  | TagImgLongdesc -> "ImgLongdesc"
  | TagImgSrc -> "ImgSrc"
  | TagImgUsemap -> "ImgUsemap"
  | TagInputSrc -> "InputSrc"
  | TagInputUsemap -> "InputUsemap"
  | TagInsCite -> "InsCite"
  | TagLinkHref -> "LinkHref"
  | TagObjectCodebase -> "ObjectCodebase"
  | TagObjectArchive -> "ObjectArchive"
  | TagObjectClassid -> "ObjectClassid"
  | TagObjectData -> "ObjectData"
  | TagObjectUsemap -> "ObjectUsemap"
  | TagQCite -> "QCite"
  | TagScriptSrc -> "ScriptSrc"
  | TagSpanHref -> "SpanHref"
;;

let print_source_option line column = function

  (* The document source, and the position within the document, make sense only if the link isn't an initial link. *)

  | None -> ""
  | Some source ->
      Printf.sprintf "Source: %s\nLine: %d\nColumn: %d\n" (Url.print true source.source_url) line column
;;

(* If the source is a file, this function prints a header line in a format recognizable by GNU emacs.
   Otherwise, it returns an empty string. *)

let print_source_option_a_la_emacs line column = function
  | None -> ""
  | Some source ->
      try
	extract _, filename
	matching Url.print false source.source_url
        against "file://(.*)$" in
        Printf.sprintf "%s, line %d, char %d:\n" filename line column
      with Not_found ->
	""

let print_link_info info source =

  (* Print the tag type. *)

  let tag_line = Printf.sprintf "Tag: %s\n" (print_tag_type info.link_tag_type) in

  (* Print the URL. *)

  let url_line = Printf.sprintf "URL: %s\n" info.link_text in

  (* The name is printed only if present.
     Because it has been created by Stripper, it is guaranteed not to contain any newline characters.
     If it is too long, we shorten it and insert an ellipsis in its middle. *)

  let name_line = match info.link_name with
  | None -> ""
  | Some name ->
      Printf.sprintf "Name: %s\n" (String_utils.shorten 72 name) in

  (* The document source, and the position within the document, make sense only if the link isn't the
     initial link. *)

  let source_lines = print_source_option info.link_line info.link_column source in

  (* Print the whole thing. *)

  tag_line ^ url_line ^ name_line ^ source_lines
;;

let print_full_link_info info =

  (* Print the tag type. *)

  let tag_line = Printf.sprintf "Tag: %s\n" (print_tag_type info.fli_tag_type) in

  (* We have three URLs to print: the original URL, the resolved URL and the mapped resolved URL.
     If any of them is identical to the one that precedes it, then it isn't printed. *)

  let url1 = info.fli_url_text in
  let url_line1 = Printf.sprintf "URL: %s\n" url1 in

  let url2 = Url.print true info.fli_url in
  let url_line2 = if url2 = url1 then "" else Printf.sprintf "Resolved-URL: %s\n" url2 in

  let url3 = Url.print true info.fli_mapped_url in
  let url_line3 = if url3 = url2 then "" else Printf.sprintf "Mapped-URL: %s\n" url3 in

  let url_lines = url_line1 ^ url_line2 ^ url_line3 in

  (* The name is printed only if present.
     Because it has been created by Stripper, it is guaranteed not to contain any newline characters.
     If it is too long, we shorten it and insert an ellipsis in its middle. *)

  let name_line = match info.fli_name with
  | None -> ""
  | Some name ->
      Printf.sprintf "Name: %s\n" (String_utils.shorten 72 name) in

  (* The document source, and the position within the document, make sense only if the link isn't the
     initial link. *)

  let source_lines = print_source_option info.fli_line info.fli_column info.fli_source in

  (* Print the whole thing. *)

  tag_line ^ url_lines ^ name_line ^ source_lines
;;

let print_local_failure = function
  | LFailNoSuchFile -> "NoSuchFile"
  | LFailNoTrailingSlash -> "NoTrailingSlash"
  | LFailUnreadable -> "Unreadable"
;;

let print_action = function
  | CouldNotCreateSocket -> "CreateSocket"
  | CouldNotResolve -> "Resolve"
  | CouldNotBind -> "Bind"
  | CouldNotConnect -> "Connect"
  | CouldNotSend -> "Send"
  | CouldNotReceive -> "Receive"
  | CouldNotClose -> "Close"
;;

let print_http_error = function
  | HTTPErrorConnection(action, error) ->
      Printf.sprintf "Connection\nAction: %s\nError: %s" (print_action action) (Unix.error_message error)
  | HTTPErrorProtocolViolation -> "ProtocolViolation"
  | HTTPErrorEmptyAnswer -> "EmptyAnswer"
  | HTTPErrorIncompleteData (expected, received) ->
      Printf.sprintf "IncompleteData\nExpected: %d\nReceived: %d" expected received
;;

let print_outcome outcome =
  "Outcome: " ^ (
    match outcome with
    | OutcomeLocalFailure local_failure ->
      	"LocalFailure\nLocalFailure: " ^ (print_local_failure local_failure)
    | OutcomeLocalSuccess ->
      	"LocalSuccess"
    | OutcomeRemoteFailure http_error ->
	"RemoteFailure\nHTTPError: " ^ (print_http_error http_error)
    | OutcomeTimeout ->
	"Timeout"
    | OutcomeRemoteSuccess ->
	"RemoteSuccess"
    | OutcomeMoved (permanent, location) ->
	Printf.sprintf "Moved\nPermanent: %s\nLocation: %s"
	  (if permanent then "Yes" else "No")
	  location
    | OutcomeServerFailure code ->
	Printf.sprintf "ServerFailure\nCode: %d" code
    | OutcomeFragmentFailure fragment ->
	Printf.sprintf "FragmentFailure\nFragment: %s" fragment
    | OutcomeIllegalFragment ->
	"IllegalFragment"
    | OutcomeIgnored ->
	"Ignored"
  ) ^ "\n"
;;

let print_early_error error =
  "EarlyError: " ^ (
    match error with
      EarlyInvalidURL explanation ->
      	"InvalidURL\nExplanation: " ^ explanation
    | EarlyInvalidMappedURL (resolved, mapped, explanation) ->
      	Printf.sprintf "InvalidMappedURL\nResolved-URL: %s\nMapped-URL: %s\nExplanation: %s"
	  resolved
	  mapped
	  explanation
    | EarlyBaseNotAbsolute ->
      	"BaseNotAbsolute"
  ) ^ "\n"
;;

let raw_postamble() =
  Settings.RawOutput.print (fun () ->
    Printf.sprintf "*** Stats\nTotal: %d\nSuccesses: %d\nFailures: %d\nFileHead: %d\nFileGet: %d\nFileGetKBytes: %d\nHttpHead: %d\nHttpGet: %d\nHttpGetKBytes: %d\n"
      stats.total stats.successes stats.failures
      stats.file_head stats.file_get (stats.file_get_bytes / 1024)
      stats.http_head stats.http_get (stats.http_get_bytes / 1024)
  )
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

HTML output functions.

*)

let html_preamble =
  Settings.HtmlOutput.print (fun () ->
    Printf.sprintf
     "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"\n\
      \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n\n\
      <html>\n\
      <head>\n\
      <title>Big Brother Report</title>\n\
      <meta http-equiv=\"Content-Type\" content=\"text/html; \
       charset=ISO-8859-1\">\n\
      <meta name=\"GENERATOR\" content=\"bigbro\">\n\
      </head>\n\
      <body bgcolor=\"#FFFFFF\">\n\
      <p>\n%s\n\
      <p>\n%s\n"
      Settings.html_banner
      "Some statistics are gathered at the <a href=\"#stats\">end</a> \
       of this document.\n<p>\n<hr>\n"
  )
;;

let html_postamble() =
  Settings.HtmlOutput.print (fun () ->
    Printf.sprintf
     "<hr>\n\
      <a name=\"stats\">%d links were checked, \
      of which %d succeeded and %d failed</a>.\n\
      <p>\n%s%s\n\
      <p>Thank you for using Big Brother!\n\
      </body>\n\
      </html>\n"
     stats.total stats.successes stats.failures
     (if Settings.local then
	 Printf.sprintf
          "This involved checking the existence of %d files, \
           and actually reading %d kilobytes in %d files.\n"
          stats.file_head (stats.file_get_bytes / 1024) stats.file_get
      else "")
     (if Settings.remote then
	 Printf.sprintf
          "Big Brother %schecked the existence of %d remote documents, \
           and actually downloaded %d of them, representing %d kilobytes.\n"
          (if Settings.local then "also " else "")
	  stats.http_head stats.http_get (stats.http_get_bytes / 1024)
      else "")
  )
;;

let htmlize_source_option line column = function
  | None ->
      "Big Brother was run on the following link."
  | Some source ->
      Printf.sprintf "Link found in <a href=\"%s\">%s</a> at line %d, column %d."
	(Url.export true source.source_url)
	(Url.basename source.source_url)
	line column
;;

let htmlize_link_info info source =
  Printf.sprintf "%s\nThe link points to <tt>%s</tt>%s."
    (htmlize_source_option info.link_line info.link_column source)
    info.link_text
    (match info.link_name with
     | None -> ""
     | Some name ->
         Printf.sprintf " and reads <i>%s</i>" (String_utils.shorten 72 name))

;;

let htmlize_full_link_info info =
  Printf.sprintf "%s\nThe link points to <a href=\"%s\">%s</a>%s."
    (htmlize_source_option info.fli_line info.fli_column info.fli_source)
    (Url.export true info.fli_mapped_url)
    info.fli_url_text
    (match info.fli_name with
     | None -> ""
     | Some name ->
         Printf.sprintf " and reads <i>%s</i>" (String_utils.shorten 72 name))

;;

let htmlize_local_failure = function
  | LFailNoSuchFile -> "The file does not exist."
  | LFailNoTrailingSlash ->
      "It is a link to a directory, so the URL should end with a slash."
  | LFailUnreadable -> "The file exists but cannot be read."
;;

let htmlize_action = function
  | CouldNotCreateSocket -> "Creating a socket failed."
  | CouldNotResolve ->
      "Unable to convert the server's name to a numeric address."
  | CouldNotBind -> "Binding the socket failed."
  | CouldNotConnect -> "Unable to connect to the remote server."
  | CouldNotSend -> "Sending the request failed."
  | CouldNotReceive -> "An error occurred while receiving the server's answer."
  | CouldNotClose -> "Closing the socket failed."
;;

let htmlize_http_error = function
  | HTTPErrorConnection(action, error) ->
      (htmlize_action action) ^ " " ^ (Unix.error_message error) ^ "."
  | HTTPErrorProtocolViolation ->
      "The remote server does not conform to the HTTP protocol."
  | HTTPErrorEmptyAnswer -> "The server closed the connection before replying."
  | HTTPErrorIncompleteData (expected, received) ->
      Printf.sprintf
        "The connection was broken before all data was received \
         (%d bytes expected, %d bytes received)."
      	expected
	received
;;

let htmlize_server_failure = function
  | 400 -> "The server reports a bad request."
  | 401 -> "This document is password-protected. \
            You supplied either no password or a wrong one."
  | 403 -> "The document exists, but the server refuses to deliver it."
  | 404 -> "The document doesn't exist."
  | 405 -> "The server does not allow checking whether the document exists."
  | 410 -> "The document no longer exists; it has been intentionally removed."
  | 500 -> "The server reports an internal error."
  | 501 -> "The server does not support checking whether the document exists."
  | 502 -> "The proxy received an invalid response from the upstream server."
  | 503 -> "The document is temporarily unavailable, \
            due to overload or maintenance of the server."
  | 504 -> "The proxy reports a timeout while accessing the upstream server."
  | code -> Printf.sprintf "The server reports an unknown error: %d." code
;;

let htmlize_outcome outcome =
  match outcome with
  | OutcomeLocalFailure local_failure ->
      "This is an invalid local link. " ^ (htmlize_local_failure local_failure)
  | OutcomeLocalSuccess ->
      "It is a valid local link."
  | OutcomeRemoteFailure http_error ->
      htmlize_http_error http_error
  | OutcomeTimeout ->
      "The connection timed out."
  | OutcomeRemoteSuccess ->
      "It is a valid remote link."
  | OutcomeMoved (permanent, location) ->
      Printf.sprintf "The link has %s moved to <a href=\"%s\">%s</a>."
	(if permanent then "permanently" else "temporarily")
	location
	location
  | OutcomeServerFailure code ->
      htmlize_server_failure code
  | OutcomeFragmentFailure fragment ->
      Printf.sprintf
        "The document exists, but contains no fragment named <tt>%s</tt>."
        fragment
  | OutcomeIllegalFragment ->
      "The document exists, but is not an HTML document, \
       so you cannot specify a fragment."
  | OutcomeIgnored ->
      "This link was ignored."
;;

let htmlize_early_error error =
  match error with
  | EarlyInvalidURL explanation ->
      "This URL is invalid: " ^ explanation
  | EarlyInvalidMappedURL (resolved, mapped, explanation) ->
      Printf.sprintf
        "After going through the specified mappings, \
         this URL becomes <tt>%s</tt>, which is invalid: %s"
	mapped
	explanation
  | EarlyBaseNotAbsolute ->
      "It is an error, because a base URL must be absolute."
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

These functions are called by the link checking engine whenever a check is complete. They turn the check information
into a textual description, to be read by the user or by a user interface process.

According to Xavier, no lock is necessary for output.

*)

let got_check_result info outcome =
  let successful = is_successful outcome in

  Stats.got_check_outcome successful;

  if not (Settings.failures && successful) then begin
    Settings.RawOutput.print
     (fun () ->
	Printf.sprintf "%s*** Result\n%s%s\n"
	  (print_source_option_a_la_emacs info.fli_line info.fli_column info.fli_source)
          (print_full_link_info info)
          (print_outcome outcome));
    Settings.HtmlOutput.print
     (fun () ->
	Printf.sprintf "%s\n%s<p>\n"
	  (htmlize_full_link_info info)
	  (htmlize_outcome outcome))
  end
;;

let got_early_error info source error =

  Stats.got_check_outcome false;

  Settings.RawOutput.print
   (fun () ->
      Printf.sprintf "%s*** EarlyError\n%s%s\n"
        (print_source_option_a_la_emacs info.link_line info.link_column source)
        (print_link_info info source)
        (print_early_error error));
  Settings.HtmlOutput.print
   (fun () ->
      Printf.sprintf "%s\n%s<p>\n"
	(htmlize_link_info info source)
	(htmlize_early_error error))
;;

