#lang racket

(provide (all-defined-out))

(require json
         "error-codes.rkt"
         "responses.rkt")

;; TextDocumentSynKind enumeration
(define TextDocSync-None 0)
(define TextDocSync-Full 1)
(define TextDocSync-Incremental 2)

(define already-initialized? #f)

(define (initialize params)
  (match params
    [(hash-table ['processId (? (or/c number? (json-null)) process-id)]
                 ['capabilities (? jsexpr? capabilities)])
     (define sync-options
       (hasheq 'openClose #t
               'change TextDocSync-Incremental
               'willSave #f
               'willSaveWaitUntil #f))
     (define renameProvider
       (match capabilities
         [(hash-table ['textDocument 
                       (hash-table ['rename
                                    (hash-table ['prepareSupport #t])])])
          (hasheq 'prepareProvider #t)]
         [_ #t]))
     (define server-capabilities
       (hasheq 'textDocumentSync sync-options
               'hoverProvider #t
               'definitionProvider #t
               'referencesProvider #t
               'completionProvider (hasheq 'triggerCharacters (list "("))
               'signatureHelpProvider (hasheq 'triggerCharacters (list " " ")" "]"))
               'renameProvider renameProvider
               'documentHighlightProvider #t
               'documentSymbolProvider #t
               'documentFormattingProvider #t
               'documentRangeFormattingProvider #t
               'documentOnTypeFormattingProvider (hasheq 'firstTriggerCharacter ")" 'moreTriggerCharacter (list "\n" "]"))))

     (set! already-initialized? #t)
     (hasheq 'capabilities server-capabilities)]
    [_
     (error-response INVALID-PARAMS "initialize failed")]))
