;; Counter Contract - Enhanced Version
;; A simple counter with increment, decrement, and reset functionality

;; Data variables
(define-data-var counter uint u0)
(define-data-var last-modified-block uint u0)
(define-constant contract-owner tx-sender)

;; Error codes
(define-constant err-not-owner (err u100))
(define-constant err-overflow (err u101))
(define-constant err-underflow (err u102))

;; Public functions
(define-public (increment)
  (let ((current (var-get counter)))
    (asserts! (< current u340282366920938463463374607431768211455) err-overflow)
    (var-set counter (+ current u1))
    (var-set last-modified-block block-height)
    (ok (var-get counter))
  )
)

(define-public (decrement)
  (let ((current (var-get counter)))
    (asserts! (> current u0) err-underflow)
    (var-set counter (- current u1))
    (var-set last-modified-block block-height)
    (ok (var-get counter))
  )
)

(define-public (increment-by (amount uint))
  (let ((current (var-get counter)))
    (asserts! (<= amount (- u340282366920938463463374607431768211455 current)) err-overflow)
    (var-set counter (+ current amount))
    (var-set last-modified-block block-height)
    (ok (var-get counter))
  )
)

(define-public (reset)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner)
    (var-set counter u0)
    (var-set last-modified-block block-height)
    (ok u0)
  )
)

;; Read-only functions
(define-read-only (get-counter)
  (var-get counter)
)

(define-read-only (get-last-modified)
  (var-get last-modified-block)
)

(define-read-only (get-owner)
  contract-owner
)
