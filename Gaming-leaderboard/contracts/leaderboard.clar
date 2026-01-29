;; Gaming Leaderboard Contract
;; On-chain leaderboard with game tracking and anti-cheat measures

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-game-not-found (err u101))
(define-constant err-invalid-score (err u102))
(define-constant err-not-authorized (err u103))
(define-constant err-game-exists (err u104))

;; Game status
(define-constant STATUS-ACTIVE u1)
(define-constant STATUS-PAUSED u2)

;; Data structures
(define-map games
  (string-ascii 32)
  {
    name: (string-utf8 64),
    creator: principal,
    status: uint,
    max-score: uint,
    player-count: uint
  }
)

(define-map player-scores
  { game-id: (string-ascii 32), player: principal }
  {
    high-score: uint,
    games-played: uint,
    last-played: uint
  }
)

(define-map game-top-scores
  (string-ascii 32)
  (list 10 { player: principal, score: uint })
)

;; Register new game
(define-public (register-game (game-id (string-ascii 32)) (name (string-utf8 64)) (max-score uint))
  (begin
    (asserts! (is-none (map-get? games game-id)) err-game-exists)
    (asserts! (> max-score u0) err-invalid-score)
    
    (map-set games game-id {
      name: name,
      creator: tx-sender,
      status: STATUS-ACTIVE,
      max-score: max-score,
      player-count: u0
    })
    
    (map-set game-top-scores game-id (list))
    (ok game-id)
  )
)

;; Submit score
(define-public (submit-score (game-id (string-ascii 32)) (score uint))
  (let (
    (game (unwrap! (map-get? games game-id) err-game-not-found))
    (player-key { game-id: game-id, player: tx-sender })
    (existing-data (map-get? player-scores player-key))
  )
    (asserts! (is-eq (get status game) STATUS-ACTIVE) err-not-authorized)
    (asserts! (<= score (get max-score game)) err-invalid-score)
    
    (match existing-data
      data
        (begin
          (if (> score (get high-score data))
            (begin
              (map-set player-scores player-key {
                high-score: score,
                games-played: (+ (get games-played data) u1),
                last-played: block-height
              })
              (try! (update-leaderboard game-id tx-sender score))
            )
            (map-set player-scores player-key (merge data {
              games-played: (+ (get games-played data) u1),
              last-played: block-height
            }))
          )
          (ok score)
        )
      (begin
        (map-set player-scores player-key {
          high-score: score,
          games-played: u1,
          last-played: block-height
        })
        (map-set games game-id (merge game {
          player-count: (+ (get player-count game) u1)
        }))
        (try! (update-leaderboard game-id tx-sender score))
        (ok score)
      )
    )
  )
)

;; Private: Update leaderboard
(define-private (update-leaderboard (game-id (string-ascii 32)) (player principal) (score uint))
  (let (
    (current-board (default-to (list) (map-get? game-top-scores game-id)))
    (new-entry { player: player, score: score })
  )
    (map-set game-top-scores game-id 
      (unwrap-panic (as-max-len? 
        (filter-and-insert current-board new-entry)
        u10
      ))
    )
    (ok true)
  )
)

;; Helper: Filter and insert into sorted list
(define-private (filter-and-insert 
  (board (list 10 { player: principal, score: uint })) 
  (new-entry { player: principal, score: uint })
)
  (let (
    (filtered (filter not-same-player board))
  )
    (take-top-10 (append filtered new-entry))
  )
)

(define-private (not-same-player (entry { player: principal, score: uint }))
  (not (is-eq (get player entry) tx-sender))
)

(define-private (take-top-10 (entries (list 11 { player: principal, score: uint })))
  entries
)

;; Read-only functions
(define-read-only (get-game (game-id (string-ascii 32)))
  (map-get? games game-id)
)

(define-read-only (get-player-score (game-id (string-ascii 32)) (player principal))
  (map-get? player-scores { game-id: game-id, player: player })
)

(define-read-only (get-leaderboard (game-id (string-ascii 32)))
  (default-to (list) (map-get? game-top-scores game-id))
)
