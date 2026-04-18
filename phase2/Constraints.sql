-- ============================================================================
-- AttraTicket - Phase 2: Constraints (ALTER TABLE)
-- ============================================================================
-- This file adds 3 new constraints to the database using ALTER TABLE.
-- For each constraint, we also demonstrate a violation attempt.
--
-- EXISTING constraints (from Phase 1):
--   booking_total_price_check, booking_status domain, customer_email_check,
--   customer_phone_check, chk_customer_password_min_length,
--   chk_attraction_name_not_blank, attraction_price_check,
--   ticket_price_check, ticket_available_quantity_check,
--   payment_amount_check, review_rating_check, bookingticket_quantity_check
-- ============================================================================

-- ============================================================================
-- CONSTRAINT 1: Ensure booking_date is not in the future
-- ============================================================================
-- Motivation: A booking date should reflect when the booking was MADE,
--   which logically cannot be in the future. This prevents data entry errors
--   and ensures accurate reporting of booking timelines.
-- Benefit: Guarantees data integrity for date-based financial reports and
--   prevents erroneous future-dated bookings from skewing analytics.
--   Important for the Booking Management and Financial Reports screens.
-- ============================================================================

ALTER TABLE BOOKING
ADD CONSTRAINT chk_booking_date_not_future
CHECK (booking_date <= CURRENT_DATE);

-- Test: Try to insert a booking with a future date (should FAIL)
-- First, create the required payment:
INSERT INTO PAYMENT (payment_id, booking_id, amount) VALUES (99999, 99999, 50.00);
-- Now try the booking with a future date:
INSERT INTO BOOKING (booking_id, customer_id, booking_date, booking_status, total_price, payment_id)
VALUES (99999, 1, '2030-01-01', 'CONFIRMED', 50.00, 99999);
-- Expected error: ERROR: new row for relation "booking" violates check constraint "chk_booking_date_not_future"

-- Cleanup (the payment we created, since the booking insertion failed):
DELETE FROM PAYMENT WHERE payment_id = 99999;

-- ============================================================================
-- CONSTRAINT 2: Ensure ticket available_quantity does not exceed 1000
-- ============================================================================
-- Motivation: No single ticket type should have more than 1000 units available.
--   This is a business rule to prevent data entry mistakes (e.g., accidentally
--   entering 10000 instead of 100) and to ensure reasonable capacity planning.
-- Benefit: Protects against accidental overselling and ensures the ticketing
--   system maintains realistic inventory levels. Critical for the Ticket
--   Management screen where staff update availability.
-- ============================================================================

ALTER TABLE TICKET
ADD CONSTRAINT chk_ticket_max_quantity
CHECK (available_quantity <= 1000);

-- Test: Try to insert a ticket with quantity > 1000 (should FAIL)
INSERT INTO TICKET (ticket_id, attraction_id, price, valid_date, ticket_type, available_quantity)
VALUES (99999, 1, 50.00, '2027-01-01', 'Adult', 5000);
-- Expected error: ERROR: new row for relation "ticket" violates check constraint "chk_ticket_max_quantity"

-- ============================================================================
-- CONSTRAINT 3: Ensure attraction price does not exceed 500
-- ============================================================================
-- Motivation: Attraction prices are expected to be within a reasonable range.
--   A price above 500 is likely a data entry error. This constraint protects
--   against accidental extreme values that could affect revenue calculations
--   and displayed prices on the customer-facing booking screens.
-- Benefit: Ensures pricing consistency across the system, prevents display
--   of unrealistic prices to customers in the Attraction Booking screen,
--   and maintains data quality for accurate financial analytics.
-- ============================================================================

ALTER TABLE ATTRACTION
ADD CONSTRAINT chk_attraction_max_price
CHECK (price <= 500);

-- Test: Try to insert an attraction with price > 500 (should FAIL)
INSERT INTO ATTRACTION (attraction_id, name, location, description, opening_hours, category, price)
VALUES (99999, 'ExpensiveAttraction', 'TelAviv', 'Test', '09:00:00', 'Museum', 999.99);
-- Expected error: ERROR: new row for relation "attraction" violates check constraint "chk_attraction_max_price"
