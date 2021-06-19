#lang racket

(provide (all-defined-out))

(require json
         "error-codes.rkt"
         "responses.rkt")

;; TextDocumentSynKind enumeration
(define TextDocSync.None 0)
(define TextDocSync.Full 1)
(define TextDocSync.Incremental 2)

(define already-initialized? #f)

(define (initialize id params)
  (match params
    [(hash-table ['processId (? (or/c number? (json-null)) process-id)]
                 ['capabilities (? jsexpr? capabilities)])
     (define sync-options
       (hasheq 'openClose #t
               'change TextDocSync.Full
               'willSave #f
               'willSaveWaitUntil #f))
     (define server-capabilities
       (hasheq 'textDocumentSync sync-options
               'hoverProvider #f
               'definitionProvider #f
               'referencesProvider #f
               'completionProvider #f
               'signatureHelpProvider #f
               'renameProvider #f
               'documentHighlightProvider #t
               'documentSymbolProvider #f
               'documentFormattingProvider #f
               'documentRangeFormattingProvider #f
               'documentOnTypeFormattingProvider #f))

     (set! already-initialized? #t)
     (success-response id (hasheq 'capabilities server-capabilities))]
    [_
     (error-response id INVALID-PARAMS "initialize failed")]))
