-- ============================================================================
-- AttraTicket - Phase 2: Indexes
-- ============================================================================
-- This file creates 3 indexes and tests performance before and after.
-- For each index, we run EXPLAIN ANALYZE before and after creation.
--
-- EXISTING indexes (from Phase 1 / earlier work):
--   idx_booking_booking_date          ON booking(booking_date)
--   idx_bookingticket_ticket_id       ON bookingticket(ticket_id)
--   idx_review_attraction_review_date ON review(attraction_id, review_date DESC)
--
-- NEW indexes created here:
--   idx_customer_country              ON customer(country)
--   idx_ticket_valid_date             ON ticket(valid_date)
--   idx_booking_status                ON booking(booking_status)
-- ============================================================================

-- ############################################################################
-- INDEX 1: Index on CUSTOMER.country
-- ############################################################################
--
-- Motivation: Country-based analysis is common for business intelligence
--   (e.g., "which countries generate the most bookings?", filtering customers
--   by country, regional marketing campaigns). Without an index, every
--   country-based query performs a full sequential scan on 20,000+ rows.
--
-- Benefit: Speeds up WHERE filters on country, GROUP BY country aggregations,
--   and joins that include country-based filtering. Useful for the Customer
--   Management and Analytics Dashboard screens.
-- ============================================================================

-- BEFORE creating the index - measure query performance
EXPLAIN ANALYZE
SELECT 
    c.country,
    COUNT(*) AS num_customers,
    COUNT(DISTINCT b.booking_id) AS num_bookings,
    ROUND(AVG(b.total_price)::numeric, 2) AS avg_spending
FROM CUSTOMER c
LEFT JOIN BOOKING b ON c.customer_id = b.customer_id
WHERE c.country IN ('Israel', 'USA', 'France')
GROUP BY c.country
ORDER BY num_bookings DESC;

-- Create the index
CREATE INDEX idx_customer_country ON CUSTOMER(country);

-- AFTER creating the index - measure query performance again
EXPLAIN ANALYZE
SELECT 
    c.country,
    COUNT(*) AS num_customers,
    COUNT(DISTINCT b.booking_id) AS num_bookings,
    ROUND(AVG(b.total_price)::numeric, 2) AS avg_spending
FROM CUSTOMER c
LEFT JOIN BOOKING b ON c.customer_id = b.customer_id
WHERE c.country IN ('Israel', 'USA', 'France')
GROUP BY c.country
ORDER BY num_bookings DESC;

/*
 Expected Results Explanation (Index 1):
 BEFORE: The query performs a Sequential Scan (Seq Scan) on the CUSTOMER table,
   reading ALL 20,000+ rows and filtering by country. This means PostgreSQL
   scans every row even though only ~6,000 rows match 3 specific countries.
 
 AFTER: The query can use a Bitmap Index Scan on idx_customer_country to
   retrieve only rows matching 'Israel', 'USA', and 'France'. Instead of
   scanning all 20,000 rows, it reads only the relevant index entries and
   fetches matching data pages.
   
 The improvement depends on selectivity. If the 3 countries represent ~30%
 of rows, the speedup may be 2-3x. If they represent <10%, it could be 5-10x.
 For very small fractions, PostgreSQL avoids reading most heap pages entirely.
*/


-- ############################################################################
-- INDEX 2: Index on TICKET.valid_date
-- ############################################################################
--
-- Motivation: Many operations involve filtering tickets by validity date
--   (e.g., "find expired tickets", "show tickets valid this month",
--   "delete expired tickets"). The DELETE and SELECT queries in this project
--   frequently use valid_date range conditions.
--
-- Benefit: Speeds up date-range queries on tickets, which are critical for
--   the Ticket Management screen and automated cleanup of expired tickets.
--   Particularly important for the DELETE query that removes expired tickets.
-- ============================================================================

-- BEFORE creating the index
EXPLAIN ANALYZE
SELECT 
    t.ticket_id,
    a.name AS attraction_name,
    a.category,
    t.ticket_type,
    t.price,
    t.valid_date,
    t.available_quantity
FROM TICKET t
JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
WHERE t.valid_date BETWEEN '2026-04-01' AND '2026-06-30'
ORDER BY t.valid_date;

-- Create the index
CREATE INDEX idx_ticket_valid_date ON TICKET(valid_date);

-- AFTER creating the index
EXPLAIN ANALYZE
SELECT 
    t.ticket_id,
    a.name AS attraction_name,
    a.category,
    t.ticket_type,
    t.price,
    t.valid_date,
    t.available_quantity
FROM TICKET t
JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
WHERE t.valid_date BETWEEN '2026-04-01' AND '2026-06-30'
ORDER BY t.valid_date;

/*
 Expected Results Explanation (Index 2):
 BEFORE: PostgreSQL performs a Sequential Scan on TICKET, reading all rows
   and filtering by valid_date range. For small tables this is fast, but as
   the ticket count grows this becomes increasingly expensive.
 
 AFTER: PostgreSQL can use an Index Scan on idx_ticket_valid_date which
   directly navigates the B-tree to the start of the date range and reads
   only qualifying rows. Additionally, since the index is sorted by date,
   the ORDER BY t.valid_date can be satisfied without a separate Sort step.
   
 The dual benefit (range filter + sort elimination) makes this index
 especially valuable. For the DELETE of expired tickets (valid_date < CURRENT_DATE),
 the index enables precise identification of target rows without full table scan.
*/


-- ############################################################################
-- INDEX 3: Index on BOOKING.booking_status
-- ############################################################################
--
-- Motivation: Booking status is frequently used for filtering (e.g., 
--   "show all cancelled bookings", "confirm pending bookings",
--   "delete cancelled bookings"). The UPDATE and DELETE queries in Phase 2
--   both filter by booking_status.
--
-- Benefit: Speeds up queries that filter by status, which are essential for
--   the Booking Management screen. Particularly important for the DELETE query
--   that removes cancelled bookings and the UPDATE that confirms pending ones.
-- ============================================================================

-- BEFORE creating the index
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    b.booking_date,
    b.booking_status,
    b.total_price,
    p.amount AS payment_amount
FROM BOOKING b
JOIN CUSTOMER c ON b.customer_id = c.customer_id
JOIN PAYMENT p ON b.payment_id = p.payment_id
WHERE b.booking_status = 'CANCELLED'
ORDER BY b.booking_date DESC;

-- Create the index
CREATE INDEX idx_booking_status ON BOOKING(booking_status);

-- AFTER creating the index
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    b.booking_date,
    b.booking_status,
    b.total_price,
    p.amount AS payment_amount
FROM BOOKING b
JOIN CUSTOMER c ON b.customer_id = c.customer_id
JOIN PAYMENT p ON b.payment_id = p.payment_id
WHERE b.booking_status = 'CANCELLED'
ORDER BY b.booking_date DESC;

/*
 Expected Results Explanation (Index 3):
 BEFORE: PostgreSQL performs a Sequential Scan on BOOKING, reading all rows
   and applying a filter on booking_status. Every row must be checked even
   though only a fraction have status 'CANCELLED'.
 
 AFTER: PostgreSQL can use an Index Scan on idx_booking_status to directly
   fetch only rows where booking_status = 'CANCELLED'. This avoids reading
   rows with other statuses entirely.
   
 The efficiency gain depends on the cardinality of each status value.
 If 'CANCELLED' represents ~20% of bookings, the index reduces rows read by ~80%.
 For the DELETE of cancelled bookings, this index is critical: it precisely
 identifies target rows and their related BOOKINGTICKET entries without
 scanning the entire table. As the booking table grows, this index becomes
 increasingly valuable for status-based operations.
*/
