#lang racket/base

(require racket/match)
(require racket/port)

(provide bencode-bytes-limit
	 bencode-read
	 bencode-read-to-end
	 bytes->bencode

	 bencode-write
	 bencode->bytes)

;;---------------------------------------------------------------------------
;; Reading

(define bencode-bytes-limit (make-parameter 4096))

(define (read-ascii p)
  (match (read-byte p)
    [(? eof-object?) eof]
    [v (integer->char v)]))

(define (digit-value c)
  (- (char->integer c) (char->integer #\0)))

(define (read-number terminator p [acc 0])
  (let loop ((sign 1) (acc acc))
    (match (read-ascii p)
      [(? eof-object?) (error 'bencode-read "Unexpected EOF")]
      [(== terminator) (* sign acc)]
      [#\- (loop (* -1 sign) acc)]
      [(? char-numeric? c) (loop sign (+ (* acc 10) (digit-value c)))]
      [c (error 'bencode-read "Unexpected character in numeric value: ~v" c)])))

(define (bencode-read* p)
  (match (read-ascii p)
    [(? eof-object?) eof]
    [#\d (read-dictionary p)]
    [#\l (read-list p)]
    [#\i (read-number #\e p)]
    [#\e 'end-marker]
    [(? char-numeric? c) (read-string (read-number #\: p (digit-value c)) p)]
    [c (error 'bencode-read "Unexpected character: ~v" c)]))

(define (bencode-read p)
  (match (bencode-read* p)
    ['end-marker (error 'bencode-read "Unexpected end-marker")]
    [v v]))

(define (bencode-read*/no-eof p)
  (match (bencode-read* p)
    [(? eof-object?) (error 'bencode-read "Unexpected EOF")]
    [v v]))

(define (read-dictionary p)
  (let loop ((acc (hash)))
    (match (bencode-read*/no-eof p)
      ['end-marker
       acc]
      [k
       (when (not (bytes? k)) (error 'bencode-read "Dictionary had non-bytes key"))
       (let ((v (bencode-read*/no-eof p)))
	 (loop (hash-set acc k v)))])))

(define (read-list p)
  (let loop ((acc '()))
    (match (bencode-read*/no-eof p)
      ['end-marker (reverse acc)]
      [v (loop (cons v acc))])))

(define (read-string len p)
  (when (negative? len)
    (error 'bencode-read "Negative string length not permitted"))
  (when (> len (bencode-bytes-limit))
    (error 'bencode-read
	   "String of length ~v exceeds current bencode-bytes-limit ~v"
	   len
	   (bencode-bytes-limit)))
  (define buf (read-bytes len p))
  (when (or (eof-object? buf)
	    (< (bytes-length buf) len))
    (error 'bencode-read "Unexpected EOF in string"))
  buf)

(define (bencode-read-to-end p)
  (let loop ((acc '()))
    (match (bencode-read p)
      [(? eof-object?) (reverse acc)]
      [v (loop (cons v acc))])))

(define (bytes->bencode bs)
  (call-with-input-bytes bs bencode-read-to-end))

;;---------------------------------------------------------------------------
;; Writing

(define (bencode-write x p)
  (match x
    [(? hash?)
     (write-char #\d p)
     (for ([entry (in-list (sort (hash->list x) bytes<? #:key car))])
       (match entry
	 [(cons (? bytes? k) v)
	  (bencode-write k p)
	  (bencode-write v p)]))
     (write-char #\e p)]
    [(or (? null?) (? pair?))
     (write-char #\l p)
     (for ([v (in-list x)])
       (bencode-write v p))
     (write-char #\e p)]
    [(? integer?)
     (write-char #\i p)
     (display (number->string x) p)
     (write-char #\e p)]
    [(? bytes?)
     (display (number->string (bytes-length x)) p)
     (write-char #\: p)
     (write-bytes x p)]
    [v (error 'bencode-write "Cannot encode value as bencode: ~v" v)]))

(define (bencode->bytes x)
  (call-with-output-bytes
   (lambda (p)
     (for ([v (in-list x)])
       (bencode-write v p)))))
