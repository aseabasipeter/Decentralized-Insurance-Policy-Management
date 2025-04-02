;; Policy Issuance Contract
;; Creates and manages insurance coverage

(define-data-var admin principal tx-sender)

;; Policy status enum
(define-constant STATUS-ACTIVE u1)
(define-constant STATUS-CANCELLED u2)

;; Policy information
(define-map policies
  { policy-id: uint }
  {
    customer-id: uint,
    premium: uint,
    coverage-amount: uint,
    start-date: uint,
    end-date: uint,
    status: uint
  }
)

;; Get the next policy ID
(define-data-var next-policy-id uint u1)

;; Issue a new policy
(define-public (issue-policy (customer-id uint) (premium uint) (coverage-amount uint) (duration uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u401))
    (map-set policies
      { policy-id: (var-get next-policy-id) }
      {
        customer-id: customer-id,
        premium: premium,
        coverage-amount: coverage-amount,
        start-date: block-height,
        end-date: (+ block-height duration),
        status: STATUS-ACTIVE
      }
    )
    (var-set next-policy-id (+ (var-get next-policy-id) u1))
    (ok (- (var-get next-policy-id) u1))
  )
)

;; Cancel a policy
(define-public (cancel-policy (policy-id uint))
  (let ((policy (map-get? policies { policy-id: policy-id })))
    (begin
      (asserts! (is-some policy) (err u404))
      (asserts! (is-eq tx-sender (var-get admin)) (err u401))
      (map-set policies
        { policy-id: policy-id }
        (merge (unwrap-panic policy) { status: STATUS-CANCELLED })
      )
      (ok true)
    )
  )
)

;; Get policy information
(define-read-only (get-policy-info (policy-id uint))
  (map-get? policies { policy-id: policy-id })
)
