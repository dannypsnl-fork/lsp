#lang racket

(provide (all-from-out "responses.rkt")
         (all-from-out "position.rkt")
         (all-from-out "text-document.rkt")
         (all-from-out "methods.rkt")
         (all-from-out "error-codes.rkt")
         display-message/flush
         read-message)

(require "responses.rkt"
         "position.rkt"
         "text-document.rkt"
         "methods.rkt"
         "error-codes.rkt"
         json)

(define (display-message/flush msg [out (current-output-port)])
  (display-message msg out)
  (flush-output out))
(define (display-message msg [out (current-output-port)])
  (when (verbose-io?)
    (eprintf "\nresp = ~v\n" msg))
  (define null-port (open-output-nowhere))
  (write-json msg null-port)
  (define content-length (file-position null-port))
  (fprintf out "Content-Length: ~a\r\n\r\n" content-length)
  (write-json msg out))
(define verbose-io? (make-parameter #f))

(define (read-message [in (current-input-port)])
  (match (read-line in 'return-linefeed)
    ["" (with-handlers ([exn:fail:read? (λ (exn) 'parse-json-error)])
          (string->jsexpr (string-replace (jsexpr->string (read-json in)) "\\r\\n" "\\n")))]
    [(? eof-object?) eof]
    [_ (read-message in)]))
