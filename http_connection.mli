(* $Header: /net/yquem/devel/caml/repository/bigbro/http_connection.mli,v 1.1.1.1 2001/02/13 15:39:34 fpottier Exp $ *)

open Url
open Linear_connection
open Media_type

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Exceptions.

HTTPErrorConnection means that a low level error occurred (see Linear_connection).
HTTPErrorProtocolViolation means that the server's answer can't be parsed.
HTTPErrorEmptyAnswer means that the server's answer is empty (connection shut down before replying).
HTTPErrorIncompleteData means that the server's answer is shorter (or longer) than announced. The first parameter
is the number of bytes announced by the Content-Length header, the second one is the number of bytes received.

*)

type http_error =
    HTTPErrorConnection of connection_action * Unix.error
  | HTTPErrorProtocolViolation
  | HTTPErrorEmptyAnswer
  | HTTPErrorIncompleteData of int * int

exception HTTPException of http_error

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Unknown headers are stored in a dictionary which associates strings to strings.

*)

module StringMap: Map.S with type key = string

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

HTTP answers are parsed and stored in the following structure. Here is a description of its contents:
- The HTTP response code.
- The length of the document, as found in the Content-Length header, if supplied by the server.
- The content type of the document, as found in the Content-Type header, if supplied by the server.
- Other headers found in the answer, gathered into a dictionary. Keys are header names, in lowercase.
- The body of the message (i.e. the document itself), if supplied.

If both a content length and a body are supplied, then they are guaranteed to agree.

*)

type http_answer = {
    http_response_code: int;
    
    http_content_length: int option;
    http_content_type: media_type option;
    http_other_headers: string StringMap.t;

    http_body: string option
  } 

(* ----------------------------------------------------------------------------------------------------------------- *)
(*

Request fetches a URL and parses the result.

*)

val request: url -> http_request_type -> (unit -> unit) -> http_answer

