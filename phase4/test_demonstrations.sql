-- ============================================================
-- test_demonstrations.sql
-- Phase 4: Demonstration and Verification script for triggers,
--          functions, and procedures.
-- Run this script on IntegratedDB to verify all functionality.
-- ============================================================

-- ============================================================
-- DEMONSTRATION 1: Trigger 1 (tr_audit_booking_status_change)
-- ============================================================
\echo '--- DEMONSTRATION 1: Cancel Booking and Trigger Audit ---'

-- Check initial state
SELECT ticket_id, available_quantity FROM TICKET WHERE ticket_id = 3;

-- Update status to CANCELLED (fires tr_audit_booking_status)
UPDATE BOOKING 
SET booking_status = 'CANCELLED' 
WHERE booking_id = 3;

-- Verify quantity was restored (should increase by bookingticket.quantity = 4)
SELECT ticket_id, available_quantity FROM TICKET WHERE ticket_id = 3;

-- Verify audit log entry was created
SELECT * FROM booking_audit_log ORDER BY log_id DESC LIMIT 1;


-- ============================================================
-- DEMONSTRATION 2: Trigger 2 (tr_prevent_suspended_customer_activity)
-- ============================================================
\echo '--- DEMONSTRATION 2: Suspend Customer and Block Activity ---'

-- Let's suspend customer 210
UPDATE CUSTOMER 
SET is_suspended = TRUE 
WHERE customer_id = 210;

-- Now try to insert a new booking for customer 210 (Should fail with custom exception!)
-- We wrap this in an anonymous block to catch and print the custom exception
DO $$
BEGIN
    INSERT INTO BOOKING (booking_id, customer_id, booking_date, total_price, booking_status, payment_id)
    VALUES (999999, 210, CURRENT_TIMESTAMP, 150.00, 'PENDING', 1);
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Trigger 2 Blocked Action Successfully! Exception Caught: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
$$;

-- Clean up/unsuspend customer 210 for future tests
UPDATE CUSTOMER 
SET is_suspended = FALSE 
WHERE customer_id = 210;


-- ============================================================
-- DEMONSTRATION 3: Procedure 2 (pr_moderator_review_cleanup)
-- ============================================================
\echo '--- DEMONSTRATION 3: Automated Account Suspension via Reports ---'

-- Insert dummy reports pointing to customer 5 reviews
-- Let's find/create a review for customer 5
INSERT INTO REVIEW (review_id, customer_id, attraction_id, rating, comment, review_date, title, is_deleted)
VALUES (9999, 5, 1, 1.0, 'Awful customer service', CURRENT_DATE, 'Terrible', FALSE)
ON CONFLICT (review_id) DO NOTHING;

-- Add two reports for customer 5 review (to exceed threshold of 1)
INSERT INTO REVIEWREPORT (report_id, report_reason, report_description, report_date, admin_decision, decision_date, customer_id, review_id)
VALUES 
    (99991, 'Spam', 'Inappropriate content', CURRENT_DATE, 'UPHELD', CURRENT_DATE, 5, 9999),
    (99992, 'Abuse', 'Harsh language', CURRENT_DATE, 'UPHELD', CURRENT_DATE, 5, 9999)
ON CONFLICT (report_id) DO NOTHING;

-- Check initial customer suspension and review state
SELECT customer_id, first_name, is_suspended FROM CUSTOMER WHERE customer_id = 5;
SELECT review_id, is_deleted, comment FROM REVIEW WHERE review_id = 9999;

-- Run moderator review cleanup with threshold = 1
CALL pr_moderator_review_cleanup(1);

-- Verify customer 5 was suspended, audit log created, and review soft-deleted
SELECT customer_id, first_name, is_suspended FROM CUSTOMER WHERE customer_id = 5;
SELECT review_id, is_deleted, comment FROM REVIEW WHERE review_id = 9999;
SELECT * FROM moderation_audit ORDER BY audit_id DESC LIMIT 1;
