;; Customer Verification Contract
;; Validates policyholder information

(define-data-var admin principal tx-sender)

;; Customer verification status
(define-map customer-verification
  { customer-id: uint }
  { verified: bool, verification-date: uint }
)

;; Customer information
(define-map customer-info
  { customer-id: uint }
  { name: (string-ascii 64), address: (string-ascii 256) }
)

;; Get the next customer ID
(define-data-var next-customer-id uint u1)

;; Register a new customer
(define-public (register-customer (name (string-ascii 64)) (address (string-ascii 256)))
  (begin
    (map-set customer-info
      { customer-id: (var-get next-customer-id) }
      { name: name, address: address }
    )
    (map-set customer-verification
      { customer-id: (var-get next-customer-id) }
      { verified: false, verification-date: u0 }
    )
    (var-set next-customer-id (+ (var-get next-customer-id) u1))
    (ok (- (var-get next-customer-id) u1))
  )
)

;; Verify a customer
(define-public (verify-customer (customer-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u401))
    (map-set customer-verification
      { customer-id: customer-id }
      { verified: true, verification-date: block-height }
    )
    (ok true)
  )
)

;; Check if a customer is verified
(define-read-only (is-customer-verified (customer-id uint))
  (get verified (default-to { verified: false, verification-date: u0 }
    (map-get? customer-verification { customer-id: customer-id })))
)

;; Get customer information
(define-read-only (get-customer-info (customer-id uint))
  (map-get? customer-info { customer-id: customer-id })
)
