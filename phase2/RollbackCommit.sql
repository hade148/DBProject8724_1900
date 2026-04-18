-- ============================================================================
-- AttraTicket - Phase 2: Rollback & Commit Demonstration
-- ============================================================================
-- This file demonstrates:
--   1. ROLLBACK: Update DB → Show state → Rollback → Show original state
--   2. COMMIT: Update DB → Show state → Commit → Show persisted state
-- ============================================================================

-- ============================================================================
-- DEMONSTRATION 1: ROLLBACK
-- We will update attraction prices, verify the change, then rollback
-- to show the database returns to its original state.
-- ============================================================================

-- Step 1: Show original state BEFORE any changes
SELECT attraction_id, name, category, price, location
FROM ATTRACTION
WHERE category = 'Museum'
ORDER BY attraction_id
LIMIT 10;

-- Step 2: Begin a transaction
BEGIN;

-- Step 3: Perform the update - increase Museum prices by 25%
UPDATE ATTRACTION
SET price = ROUND((price * 1.25)::numeric, 2)
WHERE category = 'Museum';

-- Step 4: Show the state AFTER the update (within the transaction)
SELECT attraction_id, name, category, price, location
FROM ATTRACTION
WHERE category = 'Museum'
ORDER BY attraction_id
LIMIT 10;

-- Step 5: ROLLBACK - undo all changes
ROLLBACK;

-- Step 6: Verify that the database returned to the ORIGINAL state
SELECT attraction_id, name, category, price, location
FROM ATTRACTION
WHERE category = 'Museum'
ORDER BY attraction_id
LIMIT 10;

-- ============================================================================
-- DEMONSTRATION 2: COMMIT
-- We will update booking statuses, verify the change, then commit
-- to show the changes persist.
-- ============================================================================

-- Step 1: Show original state BEFORE any changes
SELECT booking_id, customer_id, booking_date, booking_status, total_price
FROM BOOKING
WHERE booking_status = 'Pending'
ORDER BY booking_id
LIMIT 10;

-- Step 2: Begin a transaction
BEGIN;

-- Step 3: Perform the update - change Pending bookings to Confirmed
UPDATE BOOKING
SET booking_status = 'Confirmed'
WHERE booking_status = 'Pending'
  AND booking_date >= CURRENT_DATE - INTERVAL '60 days';

-- Step 4: Show the state AFTER the update (within the transaction)
SELECT booking_id, customer_id, booking_date, booking_status, total_price
FROM BOOKING
WHERE booking_date >= CURRENT_DATE - INTERVAL '60 days'
ORDER BY booking_id
LIMIT 10;

-- Step 5: COMMIT - persist all changes
COMMIT;

-- Step 6: Verify that the changes PERSISTED after commit
SELECT booking_id, customer_id, booking_date, booking_status, total_price
FROM BOOKING
WHERE booking_date >= CURRENT_DATE - INTERVAL '60 days'
ORDER BY booking_id
LIMIT 10;

-- The results of Step 4 and Step 6 should be IDENTICAL,
-- confirming that COMMIT persisted the changes.
