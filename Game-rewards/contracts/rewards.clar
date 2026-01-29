;; Game Rewards Contract
;; Distribute rewards to players based on achievements

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-achievement-exists (err u101))
(define-constant err-achievement-not-found (err u102))
(define-constant err-already-claimed (err u103))
(define-constant err-not-authorized (err u104))
(define-constant err-insufficient-pool (err u105))

;; Achievement tiers
(define-constant TIER-BRONZE u1)
(define-constant TIER-SILVER u2)
(define-constant TIER-GOLD u3)
(define-constant TIER-PLATINUM u4)

;; Data structures
(define-map achievements
  (string-ascii 32)
  {
    name: (string-utf8 64),
    description: (string-utf8 256),
    tier: uint,
    reward-amount: uint,
    total-claims: uint,
    active: bool
  }
)

(define-map player-achievements
  { player: principal, achievement-id: (string-ascii 32) }
  {
    claimed: bool,
    claimed-at: uint
  }
)

(define-map authorized-granters principal bool)

(define-data-var reward-pool uint u0)

;; Admin: Fund reward pool
(define-public (fund-pool (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set reward-pool (+ (var-get reward-pool) amount))
    (ok amount)
  )
)

;; Admin: Create achievement
(define-public (create-achievement 
  (id (string-ascii 32))
  (name (string-utf8 64))
  (description (string-utf8 256))
  (tier uint)
  (reward uint)
)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner)
    (asserts! (is-none (map-get? achievements id)) err-achievement-exists)
    
    (map-set achievements id {
      name: name,
      description: description,
      tier: tier,
      reward-amount: reward,
      total-claims: u0,
      active: true
    })
    (ok id)
  )
)

;; Admin: Authorize granter
(define-public (authorize-granter (granter principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner)
    (map-set authorized-granters granter true)
    (ok true)
  )
)

;; Grant achievement to player (by authorized granter)
(define-public (grant-achievement (player principal) (achievement-id (string-ascii 32)))
  (let (
    (achievement (unwrap! (map-get? achievements achievement-id) err-achievement-not-found))
    (player-key { player: player, achievement-id: achievement-id })
    (existing (map-get? player-achievements player-key))
    (reward (get reward-amount achievement))
  )
    (asserts! (or 
      (is-eq tx-sender contract-owner)
      (default-to false (map-get? authorized-granters tx-sender))
    ) err-not-authorized)
    (asserts! (get active achievement) err-achievement-not-found)
    (asserts! (is-none existing) err-already-claimed)
    (asserts! (>= (var-get reward-pool) reward) err-insufficient-pool)
    
    ;; Transfer reward
    (try! (as-contract (stx-transfer? reward tx-sender player)))
    
    ;; Record achievement
    (map-set player-achievements player-key {
      claimed: true,
      claimed-at: block-height
    })
    
    ;; Update stats
    (map-set achievements achievement-id (merge achievement {
      total-claims: (+ (get total-claims achievement) u1)
    }))
    
    (var-set reward-pool (- (var-get reward-pool) reward))
    (ok reward)
  )
)

;; Read-only functions
(define-read-only (get-achievement (id (string-ascii 32)))
  (map-get? achievements id)
)

(define-read-only (has-achievement (player principal) (achievement-id (string-ascii 32)))
  (match (map-get? player-achievements { player: player, achievement-id: achievement-id })
    data (get claimed data)
    false
  )
)

(define-read-only (get-reward-pool)
  (var-get reward-pool)
)

(define-read-only (is-granter (account principal))
  (default-to false (map-get? authorized-granters account))
)
