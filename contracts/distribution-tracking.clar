;; Food Bank Distribution Tracking Contract
;; Handles distribution events, impact measurement, and nutrition program coordination

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-EVENT-NOT-FOUND (err u400))
(define-constant ERR-INVALID-INPUT (err u200))
(define-constant ERR-EVENT-NOT-ACTIVE (err u300))
(define-constant ERR-INSUFFICIENT-VOLUNTEERS (err u301))

;; Data Variables
(define-data-var next-event-id uint u1)
(define-data-var next-program-id uint u1)

;; Data Maps
(define-map distribution-events
  { event-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 300),
    location: (string-ascii 200),
    start-block: uint,
    end-block: uint,
    required-volunteers: uint,
    assigned-volunteers: uint,
    target-recipients: uint,
    actual-recipients: uint,
    total-items-distributed: uint,
    total-value-distributed: uint,
    is-active: bool,
    event-type: (string-ascii 50)
  }
)

(define-map event-allocations
  { event-id: uint, allocation-id: uint }
  {
    item-id: uint,
    recipient-id: uint,
    quantity: uint,
    allocation-block: uint,
    volunteer-id: uint
  }
)

(define-map allocation-counters
  { event-id: uint }
  { count: uint }
)

(define-map nutrition-programs
  { program-id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 300),
    target-demographics: (string-ascii 200),
    nutritional-goals: (string-ascii 400),
    duration-blocks: uint,
    participants: uint,
    success-metrics: (string-ascii 300),
    is-active: bool
  }
)

(define-map program-participants
  { program-id: uint, participant-id: uint }
  {
    recipient-id: uint,
    enrollment-block: uint,
    progress-score: uint,
    completion-status: bool
  }
)

(define-map participant-counters
  { program-id: uint }
  { count: uint }
)

(define-map impact-metrics
  { event-id: uint }
  {
    meals-provided: uint,
    families-served: uint,
    children-served: uint,
    seniors-served: uint,
    nutritional-value-score: uint,
    waste-prevented-kg: uint,
    volunteer-hours: uint,
    community-impact-score: uint
  }
)

;; Public Functions

;; Create a new distribution event (admin only)
(define-public (create-distribution-event
  (title (string-ascii 100))
  (description (string-ascii 300))
  (location (string-ascii 200))
  (start-block uint)
  (end-block uint)
  (required-volunteers uint)
  (target-recipients uint)
  (event-type (string-ascii 50))
)
  (let
    (
      (event-id (var-get next-event-id))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> end-block start-block) ERR-INVALID-INPUT)
    (asserts! (> required-volunteers u0) ERR-INVALID-INPUT)
    (asserts! (> target-recipients u0) ERR-INVALID-INPUT)

    (map-set distribution-events
      { event-id: event-id }
      {
        title: title,
        description: description,
        location: location,
        start-block: start-block,
        end-block: end-block,
        required-volunteers: required-volunteers,
        assigned-volunteers: u0,
        target-recipients: target-recipients,
        actual-recipients: u0,
        total-items-distributed: u0,
        total-value-distributed: u0,
        is-active: true,
        event-type: event-type
      }
    )

    (map-set allocation-counters
      { event-id: event-id }
      { count: u0 }
    )

    (var-set next-event-id (+ event-id u1))
    (ok event-id)
  )
)

;; Record item allocation during distribution
(define-public (record-allocation
  (event-id uint)
  (item-id uint)
  (recipient-id uint)
  (quantity uint)
  (volunteer-id uint)
)
  (let
    (
      (event-info (unwrap! (map-get? distribution-events { event-id: event-id }) ERR-EVENT-NOT-FOUND))
      (allocation-count (get count (default-to { count: u0 } (map-get? allocation-counters { event-id: event-id }))))
      (current-block block-height)
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (get is-active event-info) ERR-EVENT-NOT-ACTIVE)
    (asserts! (>= current-block (get start-block event-info)) ERR-INVALID-INPUT)
    (asserts! (<= current-block (get end-block event-info)) ERR-INVALID-INPUT)

    (map-set event-allocations
      { event-id: event-id, allocation-id: allocation-count }
      {
        item-id: item-id,
        recipient-id: recipient-id,
        quantity: quantity,
        allocation-block: current-block,
        volunteer-id: volunteer-id
      }
    )

    (map-set allocation-counters
      { event-id: event-id }
      { count: (+ allocation-count u1) }
    )

    (map-set distribution-events
      { event-id: event-id }
      (merge event-info
        { total-items-distributed: (+ (get total-items-distributed event-info) quantity) }
      )
    )

    (ok allocation-count)
  )
)

;; Create nutrition program (admin only)
(define-public (create-nutrition-program
  (name (string-ascii 100))
  (description (string-ascii 300))
  (target-demographics (string-ascii 200))
  (nutritional-goals (string-ascii 400))
  (duration-blocks uint)
  (success-metrics (string-ascii 300))
)
  (let
    (
      (program-id (var-get next-program-id))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> duration-blocks u0) ERR-INVALID-INPUT)

    (map-set nutrition-programs
      { program-id: program-id }
      {
        name: name,
        description: description,
        target-demographics: target-demographics,
        nutritional-goals: nutritional-goals,
        duration-blocks: duration-blocks,
        participants: u0,
        success-metrics: success-metrics,
        is-active: true
      }
    )

    (map-set participant-counters
      { program-id: program-id }
      { count: u0 }
    )

    (var-set next-program-id (+ program-id u1))
    (ok program-id)
  )
)

;; Enroll recipient in nutrition program
(define-public (enroll-in-program (program-id uint) (recipient-id uint))
  (let
    (
      (program-info (unwrap! (map-get? nutrition-programs { program-id: program-id }) ERR-EVENT-NOT-FOUND))
      (participant-count (get count (default-to { count: u0 } (map-get? participant-counters { program-id: program-id }))))
      (current-block block-height)
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (get is-active program-info) ERR-EVENT-NOT-ACTIVE)

    (map-set program-participants
      { program-id: program-id, participant-id: participant-count }
      {
        recipient-id: recipient-id,
        enrollment-block: current-block,
        progress-score: u0,
        completion-status: false
      }
    )

    (map-set participant-counters
      { program-id: program-id }
      { count: (+ participant-count u1) }
    )

    (map-set nutrition-programs
      { program-id: program-id }
      (merge program-info { participants: (+ (get participants program-info) u1) })
    )

    (ok participant-count)
  )
)

;; Record impact metrics for distribution event
(define-public (record-impact-metrics
  (event-id uint)
  (meals-provided uint)
  (families-served uint)
  (children-served uint)
  (seniors-served uint)
  (nutritional-value-score uint)
  (waste-prevented-kg uint)
  (volunteer-hours uint)
)
  (let
    (
      (event-info (unwrap! (map-get? distribution-events { event-id: event-id }) ERR-EVENT-NOT-FOUND))
      (community-impact-score (+ families-served (* children-served u2) (* seniors-served u2)))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set impact-metrics
      { event-id: event-id }
      {
        meals-provided: meals-provided,
        families-served: families-served,
        children-served: children-served,
        seniors-served: seniors-served,
        nutritional-value-score: nutritional-value-score,
        waste-prevented-kg: waste-prevented-kg,
        volunteer-hours: volunteer-hours,
        community-impact-score: community-impact-score
      }
    )

    (map-set distribution-events
      { event-id: event-id }
      (merge event-info { actual-recipients: families-served })
    )

    (ok true)
  )
)

;; Close distribution event
(define-public (close-event (event-id uint))
  (let
    (
      (event-info (unwrap! (map-get? distribution-events { event-id: event-id }) ERR-EVENT-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (get is-active event-info) ERR-EVENT-NOT-ACTIVE)

    (map-set distribution-events
      { event-id: event-id }
      (merge event-info { is-active: false })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get distribution event details
(define-read-only (get-distribution-event (event-id uint))
  (map-get? distribution-events { event-id: event-id })
)

;; Get event allocation
(define-read-only (get-event-allocation (event-id uint) (allocation-id uint))
  (map-get? event-allocations { event-id: event-id, allocation-id: allocation-id })
)

;; Get nutrition program details
(define-read-only (get-nutrition-program (program-id uint))
  (map-get? nutrition-programs { program-id: program-id })
)

;; Get program participant
(define-read-only (get-program-participant (program-id uint) (participant-id uint))
  (map-get? program-participants { program-id: program-id, participant-id: participant-id })
)

;; Get impact metrics
(define-read-only (get-impact-metrics (event-id uint))
  (map-get? impact-metrics { event-id: event-id })
)

;; Get allocation count for event
(define-read-only (get-allocation-count (event-id uint))
  (default-to u0 (get count (map-get? allocation-counters { event-id: event-id })))
)

;; Get participant count for program
(define-read-only (get-participant-count (program-id uint))
  (default-to u0 (get count (map-get? participant-counters { program-id: program-id })))
)

;; Check if event is currently active
(define-read-only (is-event-active (event-id uint))
  (match (map-get? distribution-events { event-id: event-id })
    event-info (and (get is-active event-info)
                   (>= block-height (get start-block event-info))
                   (<= block-height (get end-block event-info)))
    false
  )
)
