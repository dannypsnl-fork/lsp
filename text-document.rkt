#lang racket

(provide (all-defined-out))

(require json
         "json-util.rkt"
         "responses.rkt"
         "error-codes.rkt"
         "position.rkt")

(define (uri-is-path? str)
  (string-prefix? str "file://"))

(define (uri->path uri)
  (cond
    [(eq? (system-type 'os) 'windows)
     ;; If a file URI begins with file:// or file:////, Windows translates it
     ;; as a UNC path. If it begins with file:///, it's translated to an MS-DOS
     ;; path. (https://en.wikipedia.org/wiki/File_URI_scheme#Windows_2)
     (cond
       [(string-prefix? uri "file:////") (substring uri 7)]
       [(string-prefix? uri "file:///") (substring uri 8)]
       [else (string-append "//" (substring uri 7))])]
    [else (substring uri 7)]))

;;
;; Match Expanders
;;;;;;;;;;;;;;;;;;;;

(define-json-expander Location
  [uri string?]
  [range any/c])

(define-json-expander ContentChangeEvent
  [range any/c]
  [rangeLength exact-nonnegative-integer?]
  [text string?])

;; VersionedTextDocumentIdentifier
(define-json-expander DocIdentifier
  [version exact-nonnegative-integer?]
  [uri string?])

;; TextDocumentItem
(define-json-expander DocItem
  [uri string?]
  [languageId string?]
  [version exact-nonnegative-integer?]
  [text string?])

(define-json-expander DocHighlight
  [range any/c])

(define-json-expander SymbolInfo
  [name string?]
  [kind exact-positive-integer?]
  [location any/c])

(define-json-expander TextEdit
  [range any/c]
  [newText string?])

;;
;; Requests
;;;;;;;;;;;;;

;; Definition request
(define (definition get-decl id params)
  (match params
    [(hash-table ['textDocument (DocIdentifier #:uri uri)]
                 ['position (Pos #:line line #:char char)])
     (define-values (start end decl) (get-decl uri line char))
     (define doc-text (string->symbol uri))
     (define result
       (match decl
         [#f (json-null)]
         [range
          (Location #:uri uri
                    #:range range)]))
     (success-response id result)]
    [_
     (error-response id INVALID-PARAMS "textDocument/definition failed")]))
