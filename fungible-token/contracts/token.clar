;; Fungible Token - SIP-010 Implementation
;; Full-featured token with minting, burning, and allowances

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-insufficient-allowance (err u103))

;; Token definition
(define-fungible-token stx-token)

;; Token metadata
(define-constant token-name "Stacks Token")
(define-constant token-symbol "STK")
(define-constant token-decimals u6)

;; Allowances map
(define-map allowances
  { owner: principal, spender: principal }
  uint
)

;; SIP-010 Required Functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance stx-token account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply stx-token))
)

(define-read-only (get-token-uri)
  (ok (some u"https://example.com/token-metadata.json"))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (try! (ft-transfer? stx-token amount sender recipient))
    (match memo
      m (print m)
      true
    )
    (ok true)
  )
)

;; Allowance functions
(define-read-only (get-allowance (owner principal) (spender principal))
  (default-to u0 (map-get? allowances { owner: owner, spender: spender }))
)

(define-public (approve (spender principal) (amount uint))
  (begin
    (map-set allowances { owner: tx-sender, spender: spender } amount)
    (ok true)
  )
)

(define-public (transfer-from (amount uint) (owner principal) (recipient principal))
  (let (
    (current-allowance (get-allowance owner tx-sender))
  )
    (asserts! (>= current-allowance amount) err-insufficient-allowance)
    (try! (ft-transfer? stx-token amount owner recipient))
    (map-set allowances 
      { owner: owner, spender: tx-sender }
      (- current-allowance amount)
    )
    (ok true)
  )
)

;; Mint function (owner only)
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner)
    (ft-mint? stx-token amount recipient)
  )
)

;; Burn function
(define-public (burn (amount uint))
  (begin
    (asserts! (>= (ft-get-balance stx-token tx-sender) amount) err-insufficient-balance)
    (ft-burn? stx-token amount tx-sender)
  )
)
