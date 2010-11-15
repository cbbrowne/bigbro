(* $Header: /net/yquem/devel/caml/repository/bigbro/url.ml,v 1.6 2001/07/17 08:46:24 fpottier Exp $ *)

open Url_syntax
open String_utils

#load "./pcreg.cmo";;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

In a relative_path, the param, query, and fragment are normalized with respect to escape sequences.
The path is a non-empty list of strings. If the URL ends with a slash, there is an empty string at
the end of the list.

*)

type relative_path = {
    param : string option;
    query : string option;
    fragment : string option;
    path: string list
  } 

(*

A net_location is simply a server name, normalized with respect to escape sequences, and converted to lower case.

*)

type net_location = string

(*

A url_scheme is simply a protocol name, converted to lower case. 

*)

type url_scheme = string

type url =
    URLRelativePath of relative_path
  | URLAbsolutePath of relative_path
  | URLNetPath of net_location * relative_path
  | URLAbsoluteURL of url_scheme * net_location * relative_path

exception UnknownScheme

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Creating a URL from a string representation.

*)

let rec create_path text =

  (* Look for a slash. If there is one, what precedes it is the first segment, and what follows it is the rest of
     the path. If there is none, the whole text is the one and only segment. *)

  let segment, remaining_path = try
    let segment, _, rest = SubstringOp.chop (fun c -> c = '/') text in
    segment, create_path rest
  with Not_found ->
    text, [] in
    
  (* Filter the segment, normalize it. *)

  let segment = normalize_segment (Substring.to_string segment) in
    
  segment :: remaining_path
;;

let create_relative_path text =

  (* Define an auxiliary function which shall be used to find the fragment, query and param. *)

  let separate text delimiter normalizer =

    (* Look for the delimiter character. According to RFC 1808, this character isn't allowed anywhere except
       as a delimiter, so we can look for it directly. *)

    try
      let text, _, piece = SubstringOp.chop (fun c -> c = delimiter) text in

      (* Copy it and normalize it. *)

      text, Some (normalizer (Substring.to_string piece))

    with Not_found ->
      text, None in

  (* Separate the fragment, query and param. *)

  let text, fragment = separate text '#' normalize_fragment in
  let text, query = separate text '?' normalize_query in
  let text, param = separate text ';' normalize_param in

  (* Parse whatever remains as a path. If there remains nothing, we get one empty path segment. *)

  let path = create_path text in
  URLRelativePath {
    param = param;
    query = query;
    fragment = fragment;
    path = path
  }
;;

let create_absolute_path text =
  match create_relative_path text with
    URLRelativePath relative_path ->
      URLAbsolutePath relative_path
  | _ ->
      assert false
;;

let create_net_path text =

  (* Look for the first slash. If there is none, pretend there was one at the end. *)

  let server, _, rest = try
    SubstringOp.chop (fun c -> c = '/') text
  with Not_found ->
    text, '/', Substring.sub text 0 0 in

  (* Normalize it with respect to escape sequences and to case. *)

  let server = String.lowercase (normalize_net_loc (Substring.to_string server)) in

  (* Parse whatever comes after the slash (if any) as an absolute path. *)

  match create_absolute_path rest with
    URLAbsolutePath relative_path ->
      URLNetPath(server, relative_path)
  | _ ->
      assert false
;;

let rec create_absolute_url scheme rest =

  (* Normalize the scheme with respect to case. *)

  let scheme = String.lowercase (Substring.to_string scheme) in

  (* Make sure we have a known scheme. Unknown schemes are reported so that the link checker ignores them.
     This is necessary since other schemes might have different grammars and we don't want to report a parse error. *)

  match scheme with
    "http"
  | "file" -> (

      (* Parse the rest.
	 If the scheme is "http", we expect a net path, because there should be two slahes after the colon.
	 If the scheme is "file", we accept an absolute path, corresponding to only one slash after the colon. *)

      match create rest with
	URLNetPath(net_location, relative_path) ->
	  URLAbsoluteURL(scheme, net_location, relative_path)
      | URLAbsolutePath relative_path when scheme = "file" ->
	  URLAbsoluteURL(scheme, "", relative_path)
      | _ ->
	  raise (Malformed "Double slash expected after the colon.")

    )
  | _ ->
      raise UnknownScheme

and is_scheme_char = function
    '+' | '-' | '.' | ('a'..'z') | ('A'..'Z') | '0'..'9' -> true
  | _ -> false

and create text =

  (* Determine whether this URL starts with a scheme.
     RFC 1808 says: "If the parse string contains a colon ":" after the first character and before any
     characters not allowed as part of a scheme name (i.e., any not an alphanumeric, plus "+",
     period ".", or hyphen "-"), the <scheme> of the URL is the substring of characters up to but not
     including the first colon." *)

  try
    let scheme, separator, rest = SubstringOp.chop (fun c -> not (is_scheme_char c)) text in
    if separator = ':' then begin

      (* We have an absolute URL. *)

      create_absolute_url scheme rest

    end
    else
      raise Not_found
  with Not_found ->

    (* We have a relative URL. Count its leading slashes to see what kind of URL it is. *)

    let length = Substring.length text in

    if (length >= 2) & (Substring.get text 0 = '/') & (Substring.get text 1 = '/') then
      create_net_path (Substring.sub text 2 (length - 2))
    else if (length >= 1) & (Substring.get text 0 = '/') then
      create_absolute_path (Substring.sub text 1 (length - 1))
    else
      create_relative_path text
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

The internal version of create works with an input of type Substring.t. Make one that works on strings.

Additionally, we call a system-dependent hook which allows more lenient syntaxes, in order to support certain
OS/browser combinations.

*)

let create text =
  create (Substring.of_string (Sysmagic.normalize_url text))
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Printing a URL to a string.

*)

let rec print_path = function
    [] ->
      assert false
  | [segment] ->
      segment
  | segment :: more ->
      segment ^ "/" ^ (print_path more)
;;

let append_string_option delimiter base = function
    None ->
      base
  | Some suffix ->
      base ^ delimiter ^ suffix
;;

let rec internal_print slashes print_fragment = function
    URLRelativePath relative_path ->
      let text = (print_path relative_path.path) in
      let text = append_string_option ";" text relative_path.param in
      let text = append_string_option "?" text relative_path.query in
      if print_fragment then
	append_string_option "#" text relative_path.fragment
      else text
  | URLAbsolutePath relative_path ->
      "/" ^ (internal_print slashes print_fragment (URLRelativePath relative_path))
  | URLNetPath (net_location, relative_path) ->
      slashes ^ net_location ^ (internal_print slashes print_fragment (URLAbsolutePath relative_path))
  | URLAbsoluteURL (scheme, net_location, relative_path) ->
      scheme ^ ":" ^ (internal_print slashes print_fragment (URLNetPath (net_location, relative_path)))
;;

let print print_fragment url =
  internal_print "//" print_fragment url
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Determining whether a URL ends with a slash.

*)

let rec path_is_directory = function
    [] ->
      assert false
  | [segment] ->
      String.length segment = 0
  | segment :: more ->
      path_is_directory more
;;

let relative_path_is_directory relative_path =
  path_is_directory relative_path.path
;;

let is_directory = function
    URLRelativePath relative_path ->
      relative_path_is_directory relative_path
  | URLAbsolutePath relative_path ->
      relative_path_is_directory relative_path
  | URLNetPath (_, relative_path) ->
      relative_path_is_directory relative_path
  | URLAbsoluteURL (_, _, relative_path) ->
      relative_path_is_directory relative_path
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Determining whether a URL is absolute.

*)

let is_absolute = function
    URLAbsoluteURL _ ->
      true
  | _ ->
      false
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

path_tack removes the last segment of the supplied path and puts the new path in its place.

*)

let path_tack path new_path =
  let rec work = function
      [] ->
	assert false
    | [segment] ->
	new_path
    | segment :: more ->
	segment :: (work more) in
  work path
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Cleaning up a path. The first function removes all segments whose name is "."; the second one removes pairs of 
consecutive segments where the first segment is not ".." and the second is "..".

Note that these functions might break the property that a path is always non-empty.

*)

let rec clean_dots = function
    [] -> []
  | "." :: rest ->
      clean_dots rest
  | elem :: rest ->
      elem :: (clean_dots rest)
;;

let rec clean_double_dots = function
    segment1 :: ".." :: rest when segment1 <> ".." ->
      clean_double_dots rest
  | segment :: rest -> (
      
      (* Use a recursive call to clean up the rest of the list. Note that doing so might create a new opportunity
	 (e.g. if the list contains A/B/../..). We check for this case after the recursive call. *)

      match clean_double_dots rest with
	".." :: rest when segment <> ".." ->
	  rest
      |	rest ->
	  segment :: rest
    )
  | [] ->
      []
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Resolving a relative URL with respect to an absolute URL.

*)

exception NotAbsolute

let resolve base relative =

  (* Extract the components of the base URL. *)

  match base with
    URLAbsoluteURL (base_scheme, base_location, base_relative_path) -> (

      (* Look at the relative URL. *)

      match relative with
	URLAbsoluteURL _ ->
	  relative
      | URLNetPath (net_location, relative_path) ->
	  URLAbsoluteURL(base_scheme, net_location, relative_path)
      | URLAbsolutePath relative_path ->
	  URLAbsoluteURL(base_scheme, base_location, relative_path)
      | URLRelativePath relative_path ->

	  (* Check whether the relative URL's path is empty. *)

	  if (relative_path.path = [""]) then begin

	    (* If so, then we shall use the base URL's path. As for the param, query and fragment, we use the relative
	       URL's, unless they're absent, in which case we use the base URL's. *)

	    let param, query, fragment = match relative_path.param with
	      None -> (
		match relative_path.query with
		  None -> (
		    match relative_path.fragment with
		      None ->
			base_relative_path.param, base_relative_path.query, base_relative_path.fragment
		    | _ ->
			base_relative_path.param, base_relative_path.query, relative_path.fragment
		)
		| _ ->
		    base_relative_path.param, relative_path.query, relative_path.fragment
	      )
	    | _ ->
		relative_path.param, relative_path.query, relative_path.fragment in

	    URLAbsoluteURL (base_scheme, base_location, {
	      param = param; query = query; fragment = fragment;
	      path = base_relative_path.path
	    })

	  end
	  else begin

	    (* The relative URL's path is non-empty. We take the base URL and tack the new relative path at its end. *)

	    let result_path = path_tack base_relative_path.path relative_path.path in

	    (* Clean up the new path by interpreting . and .. *)

	    let result_path = clean_double_dots (clean_dots result_path) in

	    (* The last two operations might yield an empty path (this happens if the relative URL ends with "."
	       or ".." instead of "./" or "../"). In this case, create an empty path segment. *)

	    let result_path = if result_path = [] then [""] else result_path in

	    (* We're done! *)

	    URLAbsoluteURL (base_scheme, base_location, {
	      param = relative_path.param; query = relative_path.query; fragment = relative_path.fragment;
	      path = result_path
	    })

	  end
    )

  | _ ->
      raise NotAbsolute
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Dropping a URL's fragment. We try to be smart and save memory where there is no fragment already.

*)

exception Nothing

let relative_path_drop_fragment relative_path =
  match relative_path.fragment with
    None ->
      raise Nothing
  | Some _ ->
      {
        param = relative_path.param; query = relative_path.query; fragment = None;
        path = relative_path.path
      }
;;

let drop_fragment url =
  try
    match url with
      URLRelativePath relative_path ->
      	URLRelativePath (relative_path_drop_fragment relative_path)
    | URLAbsolutePath relative_path ->
      	URLAbsolutePath (relative_path_drop_fragment relative_path)
    | URLNetPath (net_location, relative_path) ->
      	URLNetPath (net_location, relative_path_drop_fragment relative_path)
    | URLAbsoluteURL (scheme, net_location, relative_path) ->
      	URLAbsoluteURL (scheme, net_location, relative_path_drop_fragment relative_path)
  with Nothing ->
    url
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Getting a URL's fragment.

*)

let get_fragment = function
    URLRelativePath relative_path ->
      relative_path.fragment
  | URLAbsolutePath relative_path ->
      relative_path.fragment
  | URLNetPath (_, relative_path) ->
      relative_path.fragment
  | URLAbsoluteURL (_, _, relative_path) ->
      relative_path.fragment
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

This utility detects the presence of a user/password combination in the server name and extracts it. It is called
by create_http_request. In all other places, the user/password specification is ignored, i.e. it is considered part
of the server name.

*)

let extract_user_password name =
  try
    extract _, user, password, server matching name against "^([^:]*):([^@]*)@(.*)$" in
    Some(user, password), server
  with Not_found ->
    None, name
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Building a HTTP request and determining who it should be sent to.

*)

type http_request_type =
    HEAD
  | GET

type http_server_type =
    RegularServer
  | ProxyServer

let create_http_request request_type url = 
  match drop_fragment url with

    URLAbsoluteURL(scheme, loc, relative_path) as url ->

      (* First, extract the user/password combination, if there is one. *)

      let authentication, loc = extract_user_password loc in

      (* Then, separate the server name from the server port. This may raise InvalidPort. *)

      let loc_name, loc_port = Misc.name_and_port 80 loc in

      (* Determine whether the request should be directed at a proxy or at the server. *)

      let server_type, server_name, server_port = match Settings.proxy with
	Some (proxy_name, proxy_port) -> (
	  match Settings.noproxy with
	    Some regexp when (Pcre.pmatch ~rex:regexp loc) ->
	      RegularServer, loc_name, loc_port
	  | _ ->
	      ProxyServer, proxy_name, proxy_port
        )
      |	None ->
	  RegularServer, loc_name, loc_port in

      (* The request text starts with HEAD or GET, depending on the value of inIsHead.

	 If this request is to be sent to a proxy server, then we must include the full URL.
	 If it is to be sent to a regular HTTP server, then we must only include the absolute path.

	 The Host field is necessary in the HTTP/1.1 protocol, and some servers seem to require it even though
	 our requests are labeled HTTP/1.0. Users have asked for it. The content of the Host field is the
	 desired host name as found in the original URL, independently of whether a proxy is being used.

	 The Accept field *should* not be necessary (since its absence means anything is accepted, and it isn't
	 part of HTTP/1.0 anyway). However, some HTTP/1.1 servers return a 406 if it's absent. One such server
	 is Microsoft-Internet-Information-Server/1.0 running on images.jsc.nasa.gov (Sun, 22 Sep 1996 22:27:02
	 GMT).

	 The User-Agent field is not necessary but might be useful to make our existence known to webmasters! *)

      let requested_url = match server_type with
    	RegularServer ->
	  URLAbsolutePath relative_path
      | ProxyServer ->
	  url in

      let request = match request_type with
    	HEAD ->
	  "HEAD"
      | GET ->
	  "GET" in

      (* Determine whether authentication is needed, and if so, supply the necessary user and password.
	 Note that a user/password combination specified in the URL itself has priority over any combinations
	 specified using the -realm switch. *)

      let textual_url = print false url in
      let authentication = List.fold_left (fun accu (realm, user, password) ->
	match accu with
	  None ->
            if Pcre.pmatch ~rex:realm textual_url then Some (user, password) else None
        | Some _ ->
	    accu
      ) authentication Settings.realms in

      let authorization = match authentication with
        None ->
          ""
      | Some (user, password) ->
          Printf.sprintf "Authorization: Basic %s\r\n" (Base64.encode (user ^ ":" ^ password)) in

      (* Create the request text. *)

      let text = Printf.sprintf "%s %s HTTP/1.0\r\nHost: %s\r\nAccept: */*\r\n%sUser-Agent: Big Brother (http://pauillac.inria.fr/~fpottier/)\r\n\r\n"
      	request
      	(print false requested_url)
      	loc
        authorization in

      (* Return the results. *)

      text, server_name, server_port

  | _ ->
      raise NotAbsolute
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Dispatching according to a URL's protocol.

*)

let dispatch_scheme file_action http_action url = match url with
  URLAbsoluteURL ("file", _, _) ->
    file_action()
| URLAbsoluteURL ("http", _, _) ->
    http_action()
| URLAbsoluteURL _ ->
    assert false
| _ ->
    raise NotAbsolute
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Converting an absolute file: URL to a full file name.
The "drive" part of the URL is empty under Unix; under Windows, it is the drive spec (A:, B:, C: and so on).

*)

let filename = function
    URLAbsoluteURL ("file", drive, relative_path) ->
      Sysmagic.filename drive (List.map Url_syntax.raw relative_path.path)
  | _ ->
      assert false 
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Export works like print, except that the resulting text is going to be fed to a browser, not re-used by us.
Under Windows, we need to be friendly with Microsoft's brain-dead browser, which does not support a double slash
at the beginning of a file: URL.

When the URL is to a file, we attempt to convert `~' characters to the actual home directory, so that the ``exported''
URL really shows which file Big Brother checked.

*)

let export print_fragment url =
  match Sys.os_type with
  | "Unix" -> (
      match url with
      | URLAbsoluteURL ("file", _, _) ->
	  "file://" ^ (filename url) (* TEMPORARY note fragment is dropped in all cases *)
      |	_ ->
	  print print_fragment url
    )
  | "Win32" ->
      internal_print "/" print_fragment url
  | _ ->
      assert false
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Converting the current directory to an absolute URL.

*)

let of_cwd () =
  let drive, path = Sysmagic.drive_path (Sys.getcwd()) in
  let path = List.map escape_segment path in
  let relative_path = { path = path; fragment = None; query = None; param = None } in
  URLAbsoluteURL ("file", drive, relative_path)
;;

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Obtaining the base name of a URL. This is only supposed to be a short string which hints at the URL's full value.

*)

let rec basename_path = function
    [] ->
      assert false
  | [ "" ] ->
      "/"
  | [ name ] ->
      name
  | [ name; "" ] ->
      name ^ "/"
  | _ :: rest ->
      basename_path rest
;;

let basename_relative_path relative_path =
  basename_path relative_path.path
;;

let basename = function
    URLRelativePath relative_path -> basename_relative_path relative_path
  | URLAbsolutePath relative_path -> basename_relative_path relative_path
  | URLNetPath (_, relative_path) -> basename_relative_path relative_path
  | URLAbsoluteURL (_, _, relative_path) -> basename_relative_path relative_path
;;
