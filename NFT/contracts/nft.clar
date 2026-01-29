;; SIP-009 Compliant NFT Contract
;; Full implementation with metadata, royalties, and marketplace support

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-not-found (err u102))
(define-constant err-already-listed (err u103))
(define-constant err-not-listed (err u104))
(define-constant err-wrong-price (err u105))
(define-constant err-same-owner (err u106))

;; NFT Definition
(define-non-fungible-token stacks-nft uint)

;; Data variables
(define-data-var last-token-id uint u0)
(define-data-var base-uri (string-ascii 256) "https://api.example.com/nft/")
(define-data-var royalty-percent uint u5) ;; 5% royalty

;; Data maps
(define-map token-metadata
  uint
  {
    creator: principal,
    uri: (string-ascii 256),
    created-at: uint
  }
)

(define-map market-listings
  uint
  {
    price: uint,
    seller: principal
  }
)

;; SIP-009 Required Functions
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get base-uri)))
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stacks-nft token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (asserts! (not (is-eq sender recipient)) err-same-owner)
    (nft-transfer? stacks-nft token-id sender recipient)
  )
)

;; Mint function
(define-public (mint (recipient principal) (metadata-uri (string-ascii 256)))
  (let (
    (token-id (+ (var-get last-token-id) u1))
  )
    (try! (nft-mint? stacks-nft token-id recipient))
    
    (map-set token-metadata token-id {
      creator: tx-sender,
      uri: metadata-uri,
      created-at: block-height
    })
    
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

;; Burn function
(define-public (burn (token-id uint))
  (let (
    (owner (unwrap! (nft-get-owner? stacks-nft token-id) err-not-found))
  )
    (asserts! (is-eq tx-sender owner) err-not-authorized)
    (nft-burn? stacks-nft token-id owner)
  )
)

;; Marketplace: List for sale
(define-public (list-for-sale (token-id uint) (price uint))
  (let (
    (owner (unwrap! (nft-get-owner? stacks-nft token-id) err-not-found))
  )
    (asserts! (is-eq tx-sender owner) err-not-authorized)
    (asserts! (is-none (map-get? market-listings token-id)) err-already-listed)
    
    (map-set market-listings token-id {
      price: price,
      seller: tx-sender
    })
    (ok true)
  )
)

;; Marketplace: Unlist
(define-public (unlist (token-id uint))
  (let (
    (listing (unwrap! (map-get? market-listings token-id) err-not-listed))
  )
    (asserts! (is-eq tx-sender (get seller listing)) err-not-authorized)
    (map-delete market-listings token-id)
    (ok true)
  )
)

;; Marketplace: Buy
(define-public (buy (token-id uint))
  (let (
    (listing (unwrap! (map-get? market-listings token-id) err-not-listed))
    (price (get price listing))
    (seller (get seller listing))
    (metadata (unwrap! (map-get? token-metadata token-id) err-not-found))
    (creator (get creator metadata))
    (royalty (/ (* price (var-get royalty-percent)) u100))
    (seller-amount (- price royalty))
  )
    (asserts! (not (is-eq tx-sender seller)) err-same-owner)
    
    ;; Pay seller
    (try! (stx-transfer? seller-amount tx-sender seller))
    
    ;; Pay royalty to creator
    (if (> royalty u0)
      (try! (stx-transfer? royalty tx-sender creator))
      true
    )
    
    ;; Transfer NFT
    (try! (nft-transfer? stacks-nft token-id seller tx-sender))
    
    ;; Remove listing
    (map-delete market-listings token-id)
    (ok true)
  )
)

;; Read-only: Get metadata
(define-read-only (get-metadata (token-id uint))
  (map-get? token-metadata token-id)
)

;; Read-only: Get listing
(define-read-only (get-listing (token-id uint))
  (map-get? market-listings token-id)
)

;; Admin: Set base URI
(define-public (set-base-uri (new-uri (string-ascii 256)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner)
    (var-set base-uri new-uri)
    (ok true)
  )
)
