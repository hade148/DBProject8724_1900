-- AttraTicket - Phase 2: Constraints (ALTER TABLE)
-- Adds 3 new CHECK constraints. Each is followed by a violation test.
--
-- Existing constraints (Phase 1): booking_total_price_check, booking_status domain,
-- customer_email_check, customer_phone_check, chk_customer_password_min_length,
-- chk_attraction_name_not_blank, attraction_price_check, ticket_price_check,
-- ticket_available_quantity_check, payment_amount_check, review_rating_check,
-- bookingticket_quantity_check

-- ============================================================
-- Constraint 1: booking_date must not be in the future
-- Rationale: A booking is created at the time it is made; a future date
--            indicates a data entry error and skews date-based reports.
-- ============================================================

ALTER TABLE BOOKING
ADD CONSTRAINT chk_booking_date_not_future
CHECK (booking_date <= CURRENT_DATE);

-- Violation test (should FAIL):
INSERT INTO PAYMENT (payment_id, booking_id, amount) VALUES (99999, 99999, 50.00);
INSERT INTO BOOKING (booking_id, customer_id, booking_date, booking_status, total_price, payment_id)
VALUES (99999, 1, '2030-01-01', 'CONFIRMED', 50.00, 99999);
-- Expected: ERROR: new row for relation "booking" violates check constraint "chk_booking_date_not_future"

-- Cleanup (payment only; booking insertion failed):
DELETE FROM PAYMENT WHERE payment_id = 99999;

-- ============================================================
-- Constraint 2: ticket available_quantity must not exceed 1000
-- Rationale: Guards against data entry mistakes (e.g., typing 10000
--            instead of 100) and enforces realistic inventory limits.
-- ============================================================

ALTER TABLE TICKET
ADD CONSTRAINT chk_ticket_max_quantity
CHECK (available_quantity <= 1000);

-- Violation test (should FAIL):
INSERT INTO TICKET (ticket_id, attraction_id, price, valid_date, ticket_type, available_quantity)
VALUES (99999, 1, 50.00, '2027-01-01', 'Adult', 5000);
-- Expected: ERROR: new row for relation "ticket" violates check constraint "chk_ticket_max_quantity"

-- ============================================================
-- Constraint 3: attraction price must not exceed 500
-- Rationale: Prices above 500 are almost certainly data entry errors.
--            Prevents extreme values from affecting revenue analytics
--            and customer-facing booking screens.
-- ============================================================

ALTER TABLE ATTRACTION
ADD CONSTRAINT chk_attraction_max_price
CHECK (price <= 500);

-- Violation test (should FAIL):
INSERT INTO ATTRACTION (attraction_id, name, location, description, opening_hours, category, price)
VALUES (99999, 'ExpensiveAttraction', 'TelAviv', 'Test', '09:00:00', 'Museum', 999.99);
-- Expected: ERROR: new row for relation "attraction" violates check constraint "chk_attraction_max_price"
