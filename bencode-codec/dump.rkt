#lang racket/base

(module+ main
  (require "main.rkt")
  (require racket/pretty)

  (bencode-bytes-limit 1048576)

  (let loop ()
    (define term (bencode-read (current-input-port)))
    (when (not (eof-object? term))
      (pretty-print term)
      (loop))))
