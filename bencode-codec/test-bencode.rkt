#lang racket/base

(require bencode-codec)
(require rackunit)

(check-equal? (bytes->bencode #"") '())

(check-exn (regexp "exceeds current bencode-bytes-limit")
	   (lambda ()
	     (parameterize ((bencode-bytes-limit 2))
	       (bytes->bencode #"4:spam"))))

(check-equal? (bencode->bytes
	       '(#"spam" 3 -3 0 123 -123 (#"spam" #"eggs")
		 #hash((#"cow". #"moo") (#"spam" . #"eggs"))
		 #hash((#"spam". (#"a" #"b")))))
	      (bytes-append #"4:spami3ei-3ei0ei123ei-123el4:spam4:eggsed3:co"
			    #"w3:moo4:spam4:eggsed4:spaml1:a1:bee"))

;; The following test data are from Neil Van Dyke's test-bencode.rkt
;; from his bencode Planet package:
(check-equal? (bytes->bencode #"4:spam") '(#"spam"))
(check-equal? (bytes->bencode #"i3e")  '(3))
(check-equal? (bytes->bencode #"i-3e") '(-3))
(check-equal? (bytes->bencode #"i0e")  '(0))
(check-equal? (bytes->bencode #"i123e")  '(123))
(check-equal? (bytes->bencode #"i-123e") '(-123))
(check-equal? (bytes->bencode #"l4:spam4:eggse") '((#"spam" #"eggs")))
(check-equal? (bytes->bencode #"d3:cow3:moo4:spam4:eggse")
	      '(#hash((#"cow" . #"moo") (#"spam" . #"eggs"))))
(check-equal? (bytes->bencode #"d4:spaml1:a1:bee")
             '(#hash((#"spam" . (#"a" #"b")))))
(check-equal? (bytes->bencode
	       (bytes-append #"4:spami3ei-3ei0ei123ei-123el4:spam4:eggsed3:co"
			     #"w3:moo4:spam4:eggsed4:spaml1:a1:bee"))
	      '(#"spam" 3 -3 0 123 -123 (#"spam" #"eggs")
		#hash((#"cow". #"moo") (#"spam" . #"eggs"))
		#hash((#"spam". (#"a" #"b")))))
