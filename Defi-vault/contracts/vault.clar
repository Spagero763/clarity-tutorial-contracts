;; DeFi Vault Contract
;; Secure asset storage with time-based withdrawal delays

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-no-deposit (err u101))
(define-constant err-withdrawal-pending (err u102))
(define-constant err-withdrawal-not-ready (err u103))
(define-constant err-zero-amount (err u104))
(define-constant err-insufficient-balance (err u105))

;; Withdrawal delay: ~24 hours in blocks
(define-constant withdrawal-delay u144)

;; Data structures
(define-map vaults
  principal
  {
    balance: uint,
    pending-withdrawal: uint,
    withdrawal-block: uint
  }
)

(define-data-var total-deposits uint u0)

;; Deposit STX
(define-public (deposit (amount uint))
  (let (
    (vault (default-to 
      { balance: u0, pending-withdrawal: u0, withdrawal-block: u0 }
      (map-get? vaults tx-sender)
    ))
  )
    (asserts! (> amount u0) err-zero-amount)
    
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    (map-set vaults tx-sender (merge vault {
      balance: (+ (get balance vault) amount)
    }))
    
    (var-set total-deposits (+ (var-get total-deposits) amount))
    (ok amount)
  )
)

;; Request withdrawal (starts delay period)
(define-public (request-withdrawal (amount uint))
  (let (
    (vault (unwrap! (map-get? vaults tx-sender) err-no-deposit))
    (current-balance (get balance vault))
    (pending (get pending-withdrawal vault))
  )
    (asserts! (> amount u0) err-zero-amount)
    (asserts! (<= amount current-balance) err-insufficient-balance)
    (asserts! (is-eq pending u0) err-withdrawal-pending)
    
    (map-set vaults tx-sender (merge vault {
      balance: (- current-balance amount),
      pending-withdrawal: amount,
      withdrawal-block: (+ block-height withdrawal-delay)
    }))
    
    (ok { amount: amount, ready-at: (+ block-height withdrawal-delay) })
  )
)

;; Complete withdrawal after delay
(define-public (complete-withdrawal)
  (let (
    (vault (unwrap! (map-get? vaults tx-sender) err-no-deposit))
    (pending (get pending-withdrawal vault))
    (ready-block (get withdrawal-block vault))
  )
    (asserts! (> pending u0) err-no-deposit)
    (asserts! (>= block-height ready-block) err-withdrawal-not-ready)
    
    (try! (as-contract (stx-transfer? pending tx-sender tx-sender)))
    
    (map-set vaults tx-sender (merge vault {
      pending-withdrawal: u0,
      withdrawal-block: u0
    }))
    
    (var-set total-deposits (- (var-get total-deposits) pending))
    (ok pending)
  )
)

;; Cancel pending withdrawal
(define-public (cancel-withdrawal)
  (let (
    (vault (unwrap! (map-get? vaults tx-sender) err-no-deposit))
    (pending (get pending-withdrawal vault))
    (current-balance (get balance vault))
  )
    (asserts! (> pending u0) err-no-deposit)
    
    (map-set vaults tx-sender {
      balance: (+ current-balance pending),
      pending-withdrawal: u0,
      withdrawal-block: u0
    })
    
    (ok pending)
  )
)

;; Read-only functions
(define-read-only (get-vault (user principal))
  (map-get? vaults user)
)

(define-read-only (get-balance (user principal))
  (match (map-get? vaults user)
    vault (get balance vault)
    u0
  )
)

(define-read-only (get-total-deposits)
  (var-get total-deposits)
)

(define-read-only (get-withdrawal-delay)
  withdrawal-delay
)
