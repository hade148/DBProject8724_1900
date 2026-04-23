-- AttraTicket - Phase 2: Rollback & Commit Demonstration
-- Demo 1: Change → verify → ROLLBACK  (changes discarded)
-- Demo 2: Change → verify → COMMIT    (changes persisted)

-- ============================================================
-- Demo 1: ROLLBACK
-- Increase Museum prices by 25%, then undo the change.
-- ============================================================

-- State before change
SELECT attraction_id, name, category, price, location
FROM ATTRACTION
WHERE category = 'Museum'
ORDER BY attraction_id
LIMIT 10;

BEGIN;

UPDATE ATTRACTION
SET price = ROUND((price * 1.25)::numeric, 2)
WHERE category = 'Museum';

-- State after update (within transaction)
SELECT attraction_id, name, category, price, location
FROM ATTRACTION
WHERE category = 'Museum'
ORDER BY attraction_id
LIMIT 10;

ROLLBACK;

-- State after rollback (should match the first SELECT)
SELECT attraction_id, name, category, price, location
FROM ATTRACTION
WHERE category = 'Museum'
ORDER BY attraction_id
LIMIT 10;

-- ============================================================
-- Demo 2: COMMIT
-- Confirm recent Pending bookings, then persist the change.
-- ============================================================

-- State before change
SELECT booking_id, customer_id, booking_date, booking_status, total_price
FROM BOOKING
WHERE booking_status = 'Pending'
ORDER BY booking_id
LIMIT 10;

BEGIN;

UPDATE BOOKING
SET booking_status = 'Confirmed'
WHERE booking_status = 'Pending'
  AND booking_date >= CURRENT_DATE - INTERVAL '60 days';

-- State after update (within transaction)
SELECT booking_id, customer_id, booking_date, booking_status, total_price
FROM BOOKING
WHERE booking_date >= CURRENT_DATE - INTERVAL '60 days'
ORDER BY booking_id
LIMIT 10;

COMMIT;

-- State after commit (should match the previous SELECT)
SELECT booking_id, customer_id, booking_date, booking_status, total_price
FROM BOOKING
WHERE booking_date >= CURRENT_DATE - INTERVAL '60 days'
ORDER BY booking_id
LIMIT 10;
