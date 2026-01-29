;; Escrow Contract - Enhanced Multi-Party Escrow System
;; Secure fund holding with dispute resolution support

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-escrow-exists (err u100))
(define-constant err-zero-amount (err u101))
(define-constant err-no-beneficiary (err u102))
(define-constant err-empty-escrow (err u103))
(define-constant err-not-authorized (err u104))
(define-constant err-invalid-state (err u105))
(define-constant err-escrow-not-found (err u106))

;; Escrow states
(define-constant STATE-PENDING u0)
(define-constant STATE-RELEASED u1)
(define-constant STATE-REFUNDED u2)
(define-constant STATE-DISPUTED u3)

;; Data structures
(define-map escrows
  uint
  {
    depositor: principal,
    beneficiary: principal,
    amount: uint,
    state: uint,
    created-at: uint,
    description: (string-utf8 256)
  }
)

(define-data-var escrow-nonce uint u0)

;; Create new escrow
(define-public (create-escrow (receiver principal) (amount uint) (description (string-utf8 256)))
  (let (
    (escrow-id (var-get escrow-nonce))
  )
    (asserts! (> amount u0) err-zero-amount)
    (asserts! (not (is-eq receiver tx-sender)) err-invalid-state)
    
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    (map-set escrows escrow-id {
      depositor: tx-sender,
      beneficiary: receiver,
      amount: amount,
      state: STATE-PENDING,
      created-at: block-height,
      description: description
    })
    
    (var-set escrow-nonce (+ escrow-id u1))
    (ok escrow-id)
  )
)

;; Release funds to beneficiary
(define-public (release (escrow-id uint))
  (let (
    (escrow (unwrap! (map-get? escrows escrow-id) err-escrow-not-found))
    (depositor (get depositor escrow))
    (beneficiary (get beneficiary escrow))
    (amount (get amount escrow))
    (state (get state escrow))
  )
    (asserts! (is-eq state STATE-PENDING) err-invalid-state)
    (asserts! (is-eq tx-sender depositor) err-not-authorized)
    
    (try! (as-contract (stx-transfer? amount tx-sender beneficiary)))
    
    (map-set escrows escrow-id (merge escrow { state: STATE-RELEASED }))
    (ok true)
  )
)

;; Refund to depositor (beneficiary releases)
(define-public (refund (escrow-id uint))
  (let (
    (escrow (unwrap! (map-get? escrows escrow-id) err-escrow-not-found))
    (depositor (get depositor escrow))
    (beneficiary (get beneficiary escrow))
    (amount (get amount escrow))
    (state (get state escrow))
  )
    (asserts! (is-eq state STATE-PENDING) err-invalid-state)
    (asserts! (is-eq tx-sender beneficiary) err-not-authorized)
    
    (try! (as-contract (stx-transfer? amount tx-sender depositor)))
    
    (map-set escrows escrow-id (merge escrow { state: STATE-REFUNDED }))
    (ok true)
  )
)

;; Read escrow details
(define-read-only (get-escrow (escrow-id uint))
  (map-get? escrows escrow-id)
)

;; Get total escrows created
(define-read-only (get-escrow-count)
  (var-get escrow-nonce)
)
