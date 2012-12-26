#lang scribble/manual

@(require planet/scribble
	  scribble/racket
	  scriblib/footnote
	  (for-label racket
		     (this-package-in main)))

@title{racket-bencode}
@author[(author+email "Tony Garnock-Jones" "tonygarnockjones@gmail.com")]

@local-table-of-contents[]

If you find that this library lacks some feature you need, or you have
a suggestion for improving it, please don't hesitate to
@link["mailto:tonygarnockjones@gmail.com"]{get in touch with me}!

@section{Introduction}

This library implements Bencode, "the encoding used by the
peer-to-peer file sharing system BitTorrent for storing and
transmitting loosely structured data." @note{Quote from
@link["http://en.wikipedia.org/wiki/Bencode"]{Wikipedia}.}

@section{References}

Bencode is defined as part of the BitTorrent specifications. Useful
references include:

@itemize[
  @item{@link["http://www.bittorrent.org/beps/bep_0003.html#bencoding"]{BEP 3, The BitTorrent Protocol Specification}; and}
  @item{@link["http://en.wikipedia.org/wiki/Bencode"]{Wikipedia on the subject.}}
]

@section[#:tag "mapping"]{Representation of Terms}

Bencode terms are represented as Racket data structures as follows:

@itemize[
  @item{Bencode lists map to Racket lists}
  @item{Bencode dictionaries map to Racket @racket[equal?]-hashtables}
  @item{Bencode integers map to Racket integers}
  @item{Bencode strings map to Racket byte-vectors (@racket[bytes])}
]

In particular, Racket's @racket[null] value is the representation of
the empty Bencode list.

@section{What to require}

All the functionality below can be accessed with a single
@racket[require]:

@(defmodule/this-package main)

@subsection{Reading Bencoded data}

@defproc[(bencode-read [p input-port?]) (or/c any? eof-object?)]{
Reads and returns a single Bencoded term from the given input-port, or
returns @racket[eof] if the end-of-file is reached before any other
data appears on the input-port. An error is signalled if a syntax
error or unexpected end-of-file is detected.

If a Bencoded string (Racket bytes) value appears on the input-port
and has length in excess of @racket[bencode-bytes-limit]'s current
value, an error is signalled. }

@defproc[(bencode-read-to-end [p input-port?]) list?]{ Reads and
returns as many Bencoded terms as are available on the given input
port. Once end-of-file is reached, returns the terms as a list in the
order they were read from the port. Errors are otherwise signalled as
for @racket[bencode-read]. }

@defproc[(bytes->bencode [bs bytes?]) list?]{ As
@racket[bencode-read-to-end], but takes input from the supplied
byte-vector instead of from an input-port. }

@defproc*[([(bencode-bytes-limit) integer?]
	   [(bencode-bytes-limit [new-limit integer?]) void?])]{
A parameter. Retrieves or sets the current limit on strings read by
any of the other Bencode-reading functions defined in this library. }

@subsection{Writing Bencoded data}

@defproc[(bencode-write [term any?] [p output-port?]) void?]{ Writes a
single term (which must be a Racket datum as specified in
@secref{mapping}) to the given output-port. }

@defproc[(bencode->bytes [terms list?]) bytes?]{ Returns a byte-vector
containing a Bencoded representation of the given list of terms, in
the order they appear in the list. Note that it encodes a list of
terms, not a single term, and so it is roughly an inverse of
@racket[bytes->bencode]. }
