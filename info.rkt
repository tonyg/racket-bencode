#lang setup/infotab
(define name "bencode")
(define blurb
  (list
   `(p "Reading and writing of Bencoded data")))
(define categories '(net))
(define can-be-loaded-with 'all)
(define homepage "https://github.com/tonyg/racket-bencode")
(define primary-file "main.rkt")
(define repositories '("4.x"))
(define scribblings '(("manual.scrbl" ())))

(define racket-launcher-libraries '("dump.rkt"))
(define racket-launcher-names '("bencode-dump"))
