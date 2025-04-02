;; Risk Assessment Contract
;; Calculates premiums based on risk factors

(define-data-var admin principal tx-sender)

;; Customer risk scores
(define-map customer-risk-scores
  { customer-id: uint }
  { score: uint, last-updated: uint }
)

;; Set risk score for a customer
(define-public (set-risk-score (customer-id uint) (score uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u401))
    (map-set customer-risk-scores
      { customer-id: customer-id }
      { score: score, last-updated: block-height }
    )
    (ok true)
  )
)

;; Calculate premium for a customer
(define-public (calculate-premium (customer-id uint) (base-premium uint))
  (let ((risk-score (get-risk-score-value customer-id)))
    (ok (+ base-premium (* base-premium (/ risk-score u100))))
  )
)

;; Get risk score value (helper)
(define-private (get-risk-score-value (customer-id uint))
  (get score (default-to { score: u50, last-updated: u0 }
    (map-get? customer-risk-scores { customer-id: customer-id })))
)

;; Get customer risk score
(define-read-only (get-risk-score (customer-id uint))
  (map-get? customer-risk-scores { customer-id: customer-id })
)
