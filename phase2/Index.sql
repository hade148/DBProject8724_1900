-- AttraTicket - Phase 2: Indexes | 3 indexes with EXPLAIN ANALYZE before/after

-- Index 1: customer(country) — speeds up country-based filtering
EXPLAIN ANALYZE
SELECT c.country, COUNT(*) AS num_customers,
    COUNT(DISTINCT b.booking_id) AS num_bookings,
    ROUND(AVG(b.total_price)::numeric, 2) AS avg_spending
FROM CUSTOMER c
LEFT JOIN BOOKING b ON c.customer_id = b.customer_id
WHERE c.country IN ('Israel', 'USA', 'France')
GROUP BY c.country ORDER BY num_bookings DESC;

CREATE INDEX idx_customer_country ON CUSTOMER(country);

EXPLAIN ANALYZE
SELECT c.country, COUNT(*) AS num_customers,
    COUNT(DISTINCT b.booking_id) AS num_bookings,
    ROUND(AVG(b.total_price)::numeric, 2) AS avg_spending
FROM CUSTOMER c
LEFT JOIN BOOKING b ON c.customer_id = b.customer_id
WHERE c.country IN ('Israel', 'USA', 'France')
GROUP BY c.country ORDER BY num_bookings DESC;

-- Index 2: ticket(valid_date) — speeds up date-range filters and expiry cleanup
EXPLAIN ANALYZE
SELECT t.ticket_id, a.name AS attraction_name, a.category,
    t.ticket_type, t.price, t.valid_date, t.available_quantity
FROM TICKET t
JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
WHERE t.valid_date BETWEEN '2026-04-01' AND '2026-06-30'
ORDER BY t.valid_date;

CREATE INDEX idx_ticket_valid_date ON TICKET(valid_date);

EXPLAIN ANALYZE
SELECT t.ticket_id, a.name AS attraction_name, a.category,
    t.ticket_type, t.price, t.valid_date, t.available_quantity
FROM TICKET t
JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
WHERE t.valid_date BETWEEN '2026-04-01' AND '2026-06-30'
ORDER BY t.valid_date;

-- Index 3: booking(booking_status) — avoids full scan on DELETE/UPDATE by status
EXPLAIN ANALYZE
SELECT b.booking_id, c.first_name || ' ' || c.last_name AS customer_name,
    c.email, b.booking_date, b.booking_status, b.total_price
FROM BOOKING b
JOIN CUSTOMER c ON b.customer_id = c.customer_id
WHERE b.booking_status = 'CANCELLED'
ORDER BY b.booking_date DESC;

CREATE INDEX idx_booking_status ON BOOKING(booking_status);

EXPLAIN ANALYZE
SELECT b.booking_id, c.first_name || ' ' || c.last_name AS customer_name,
    c.email, b.booking_date, b.booking_status, b.total_price
FROM BOOKING b
JOIN CUSTOMER c ON b.customer_id = c.customer_id
WHERE b.booking_status = 'CANCELLED'
ORDER BY b.booking_date DESC;
