;; Advanced Staking Contract with Rewards
;; Stake STX and earn proportional rewards over time

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-zero-amount (err u101))
(define-constant err-insufficient-stake (err u102))
(define-constant err-no-rewards (err u103))
(define-constant err-already-staked (err u104))

;; Reward rate: 10% APY (calculated per block, ~144 blocks/day)
(define-constant blocks-per-year u52560)
(define-constant reward-rate-basis-points u1000) ;; 10%

;; Data maps
(define-map stakes
  principal
  {
    amount: uint,
    start-block: uint,
    last-claim-block: uint
  }
)

(define-data-var total-staked uint u0)
(define-data-var reward-pool uint u0)

;; Admin: Fund reward pool
(define-public (fund-rewards (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner)
    (asserts! (> amount u0) err-zero-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set reward-pool (+ (var-get reward-pool) amount))
    (ok amount)
  )
)

;; Stake STX
(define-public (stake (amount uint))
  (let (
    (existing-stake (map-get? stakes tx-sender))
  )
    (asserts! (> amount u0) err-zero-amount)
    
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    (match existing-stake
      stake-data
        (map-set stakes tx-sender {
          amount: (+ (get amount stake-data) amount),
          start-block: (get start-block stake-data),
          last-claim-block: block-height
        })
      (map-set stakes tx-sender {
        amount: amount,
        start-block: block-height,
        last-claim-block: block-height
      })
    )
    
    (var-set total-staked (+ (var-get total-staked) amount))
    (ok amount)
  )
)

;; Unstake STX
(define-public (unstake (amount uint))
  (let (
    (stake-data (unwrap! (map-get? stakes tx-sender) err-insufficient-stake))
    (current-stake (get amount stake-data))
  )
    (asserts! (>= current-stake amount) err-insufficient-stake)
    
    (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
    
    (if (is-eq current-stake amount)
      (map-delete stakes tx-sender)
      (map-set stakes tx-sender (merge stake-data {
        amount: (- current-stake amount),
        last-claim-block: block-height
      }))
    )
    
    (var-set total-staked (- (var-get total-staked) amount))
    (ok amount)
  )
)

;; Calculate pending rewards
(define-read-only (get-pending-rewards (staker principal))
  (match (map-get? stakes staker)
    stake-data
      (let (
        (staked-amount (get amount stake-data))
        (blocks-since-claim (- block-height (get last-claim-block stake-data)))
        (reward (/ (* (* staked-amount reward-rate-basis-points) blocks-since-claim) (* blocks-per-year u10000)))
      )
        reward
      )
    u0
  )
)

;; Claim rewards
(define-public (claim-rewards)
  (let (
    (stake-data (unwrap! (map-get? stakes tx-sender) err-insufficient-stake))
    (rewards (get-pending-rewards tx-sender))
  )
    (asserts! (> rewards u0) err-no-rewards)
    (asserts! (<= rewards (var-get reward-pool)) err-no-rewards)
    
    (try! (as-contract (stx-transfer? rewards tx-sender tx-sender)))
    
    (map-set stakes tx-sender (merge stake-data { last-claim-block: block-height }))
    (var-set reward-pool (- (var-get reward-pool) rewards))
    (ok rewards)
  )
)

;; Read-only functions
(define-read-only (get-stake (staker principal))
  (map-get? stakes staker)
)

(define-read-only (get-total-staked)
  (var-get total-staked)
)

(define-read-only (get-reward-pool)
  (var-get reward-pool)
)
