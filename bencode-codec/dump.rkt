#lang racket/base

(module+ main
  (require "main.rkt")
  (require racket/pretty)

  (let loop ()
    (define term (bencode-read (current-input-port)))
    (when (not (eof-object? term))
      (pretty-print term)
      (loop))))
