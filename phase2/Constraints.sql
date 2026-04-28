-- AttraTicket - Phase 2: Constraints | 3 CHECK constraints + violation tests

-- Constraint 1: booking_date >= CURRENT_DATE
ALTER TABLE BOOKING
ADD CONSTRAINT chk_booking_date_not_future
CHECK (booking_date >= CURRENT_DATE);

INSERT INTO PAYMENT (payment_id, booking_id, amount) VALUES (99999, 99999, 50.00);
INSERT INTO BOOKING (booking_id, customer_id, booking_date, booking_status, total_price, payment_id)
VALUES (99999, 1, '2020-01-01', 'CONFIRMED', 50.00, 99999); -- Expected: FAIL
DELETE FROM PAYMENT WHERE payment_id = 99999;

-- Constraint 2: available_quantity <= 1000
ALTER TABLE TICKET
ADD CONSTRAINT chk_ticket_max_quantity
CHECK (available_quantity <= 1000);

INSERT INTO TICKET (ticket_id, attraction_id, price, valid_date, ticket_type, available_quantity)
VALUES (99999, 1, 50.00, '2027-01-01', 'Adult', 5000); -- Expected: FAIL

-- Constraint 3: attraction price <= 500
ALTER TABLE ATTRACTION
ADD CONSTRAINT chk_attraction_max_price
CHECK (price <= 500);

INSERT INTO ATTRACTION (attraction_id, name, location, description, opening_hours, category, price)
VALUES (99999, 'ExpensiveAttraction', 'TelAviv', 'Test', '09:00:00', 'Museum', 999.99); -- Expected: FAIL
