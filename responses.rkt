#lang racket/base

(provide (all-defined-out))

(require json)

(define not-given (gensym 'not-given))

(define (success-response id result)
  (hasheq 'jsonrpc "2.0"
          'id id
          'result result))

;; Constructor for a response object representing failure.
(define (error-response id code message [data not-given])
  (define err (hasheq 'code code
                      'message message))
  (define err* (if (eq? data not-given)
                   err
                   (hash-set err 'data data)))
  (hasheq 'jsonrpc "2.0"
          'id id
          'error err*))

(define Diag-Error 1)
(define Diag-Warning 2)
(define Diag-Information 3)
(define Diag-Hint 4)

;; Constructor for a response object representing diagnostics.
(define (diagnostics-message uri diags)
  (hasheq 'jsonrpc "2.0"
          'method "textDocument/publishDiagnostics"
          'params (hasheq 'uri uri
                          'diagnostics diags)))

(define DocumentHighlightKind.Text 1)
(define DocumentHighlightKind.Read 2)
(define DocumentHighlightKind.Write 3)
(define (DocumentHighlight range [kind #f])
  (hasheq 'range range
          'kind kind))
