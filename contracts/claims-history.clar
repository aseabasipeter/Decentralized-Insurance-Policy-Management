;; Claims History Contract
;; Tracks past incidents and payouts

(define-data-var admin principal tx-sender)

;; Claim status enum
(define-constant STATUS-SUBMITTED u1)
(define-constant STATUS-APPROVED u2)
(define-constant STATUS-REJECTED u3)
(define-constant STATUS-PAID u4)

;; Claim information
(define-map claims
  { claim-id: uint }
  {
    policy-id: uint,
    customer-id: uint,
    amount: uint,
    incident-date: uint,
    submission-date: uint,
    status: uint,
    description: (string-ascii 256)
  }
)

;; Get the next claim ID
(define-data-var next-claim-id uint u1)

;; Submit a new claim
(define-public (submit-claim (policy-id uint) (customer-id uint) (amount uint) (incident-date uint) (description (string-ascii 256)))
  (begin
    (map-set claims
      { claim-id: (var-get next-claim-id) }
      {
        policy-id: policy-id,
        customer-id: customer-id,
        amount: amount,
        incident-date: incident-date,
        submission-date: block-height,
        status: STATUS-SUBMITTED,
        description: description
      }
    )
    (var-set next-claim-id (+ (var-get next-claim-id) u1))
    (ok (- (var-get next-claim-id) u1))
  )
)

;; Update claim status
(define-public (update-claim-status (claim-id uint) (new-status uint))
  (let ((claim (map-get? claims { claim-id: claim-id })))
    (begin
      (asserts! (is-some claim) (err u404))
      (asserts! (is-eq tx-sender (var-get admin)) (err u401))
      (map-set claims
        { claim-id: claim-id }
        (merge (unwrap-panic claim) { status: new-status })
      )
      (ok true)
    )
  )
)

;; Get claim information
(define-read-only (get-claim-info (claim-id uint))
  (map-get? claims { claim-id: claim-id })
)
