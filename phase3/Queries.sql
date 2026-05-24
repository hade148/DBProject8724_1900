-- ============================================================
-- Queries.sql – Phase 3 version
-- All Phase-2 queries updated for the merged schema.
--
-- Schema changes that affect queries:
--   REVIEW    : added title, is_deleted, deleted_date
--               → SELECT queries filter is_deleted = FALSE
--               → DELETE must cascade to REVIEWREACTION / REVIEWREPORT first
--   CUSTOMER  : added register_date (nullable – no query impact)
--   REVIEWREACTION / REVIEWREPORT : new tables with FK on REVIEW
-- ============================================================

-- ============================================================
-- Query 1: Top-rated attractions (avg >= 4) with booking count
-- Change: added is_deleted = FALSE to exclude deleted reviews
-- ============================================================

-- Version A: JOINs
SELECT
    a.name        AS attraction_name,
    a.category,
    a.location,
    ROUND(AVG(r.rating)::numeric, 2)      AS avg_rating,
    COUNT(DISTINCT bt.booking_id)         AS total_bookings
FROM ATTRACTION a
JOIN REVIEW       r  ON a.attraction_id = r.attraction_id
JOIN TICKET       t  ON a.attraction_id = t.attraction_id
LEFT JOIN BOOKINGTICKET bt ON t.ticket_id = bt.ticket_id
WHERE r.is_deleted = FALSE
GROUP BY a.attraction_id, a.name, a.category, a.location
HAVING AVG(r.rating) >= 4.0
ORDER BY avg_rating DESC, total_bookings DESC;

-- Version B: Correlated subqueries
SELECT
    a.name        AS attraction_name,
    a.category,
    a.location,
    (SELECT ROUND(AVG(r.rating)::numeric, 2)
     FROM REVIEW r
     WHERE r.attraction_id = a.attraction_id
       AND r.is_deleted = FALSE)                         AS avg_rating,
    (SELECT COUNT(DISTINCT bt.booking_id)
     FROM TICKET t
     JOIN BOOKINGTICKET bt ON t.ticket_id = bt.ticket_id
     WHERE t.attraction_id = a.attraction_id)            AS total_bookings
FROM ATTRACTION a
WHERE (SELECT AVG(r2.rating)
       FROM REVIEW r2
       WHERE r2.attraction_id = a.attraction_id
         AND r2.is_deleted = FALSE) >= 4.0
ORDER BY avg_rating DESC, total_bookings DESC;

-- Efficiency: Version A (JOINs) is faster — single aggregation pass.
--             Version B runs ~3N correlated subqueries for N attractions.

-- ============================================================
-- Query 2: Customers who spent above their booking month's average
-- No schema change — query unchanged.
-- ============================================================

-- Version A: JOIN with derived table (monthly averages computed once)
SELECT
    c.first_name || ' ' || c.last_name   AS full_name,
    c.country,
    c.email,
    EXTRACT(DAY   FROM b.booking_date)   AS booking_day,
    EXTRACT(MONTH FROM b.booking_date)   AS booking_month,
    EXTRACT(YEAR  FROM b.booking_date)   AS booking_year,
    b.total_price,
    ROUND(ma.avg_monthly_price::numeric, 2) AS month_avg,
    b.booking_status
FROM CUSTOMER c
JOIN BOOKING b ON c.customer_id = b.customer_id
JOIN (
    SELECT
        EXTRACT(MONTH FROM booking_date) AS bmonth,
        EXTRACT(YEAR  FROM booking_date) AS byear,
        AVG(total_price)                 AS avg_monthly_price
    FROM BOOKING
    GROUP BY EXTRACT(MONTH FROM booking_date),
             EXTRACT(YEAR  FROM booking_date)
) ma ON  EXTRACT(MONTH FROM b.booking_date) = ma.bmonth
     AND EXTRACT(YEAR  FROM b.booking_date) = ma.byear
WHERE b.total_price > ma.avg_monthly_price
ORDER BY b.total_price DESC;

-- Version B: Correlated subquery (recalculates monthly average per row)
SELECT
    c.first_name || ' ' || c.last_name   AS full_name,
    c.country,
    c.email,
    EXTRACT(DAY   FROM b.booking_date)   AS booking_day,
    EXTRACT(MONTH FROM b.booking_date)   AS booking_month,
    EXTRACT(YEAR  FROM b.booking_date)   AS booking_year,
    b.total_price,
    (SELECT ROUND(AVG(b3.total_price)::numeric, 2)
     FROM BOOKING b3
     WHERE EXTRACT(MONTH FROM b3.booking_date) = EXTRACT(MONTH FROM b.booking_date)
       AND EXTRACT(YEAR  FROM b3.booking_date) = EXTRACT(YEAR  FROM b.booking_date)
    )                                    AS month_avg,
    b.booking_status
FROM CUSTOMER c
JOIN BOOKING b ON c.customer_id = b.customer_id
WHERE b.total_price > (
    SELECT AVG(b2.total_price)
    FROM BOOKING b2
    WHERE EXTRACT(MONTH FROM b2.booking_date) = EXTRACT(MONTH FROM b.booking_date)
      AND EXTRACT(YEAR  FROM b2.booking_date) = EXTRACT(YEAR  FROM b.booking_date)
)
ORDER BY b.total_price DESC;

-- Efficiency: Version A scans BOOKING twice total.
--             Version B scans BOOKING up to 2N+1 times for N rows.

-- ============================================================
-- Query 3: Months with total revenue above the monthly average
-- No schema change — query unchanged.
-- ============================================================

-- Version A: HAVING with nested subquery
SELECT
    EXTRACT(YEAR  FROM b.booking_date)   AS year,
    EXTRACT(MONTH FROM b.booking_date)   AS month,
    COUNT(*)                             AS num_bookings,
    ROUND(SUM(b.total_price)::numeric, 2) AS total_revenue,
    ROUND(AVG(b.total_price)::numeric, 2) AS avg_booking_price
FROM BOOKING b
GROUP BY EXTRACT(YEAR  FROM b.booking_date),
         EXTRACT(MONTH FROM b.booking_date)
HAVING SUM(b.total_price) > (
    SELECT AVG(monthly_total) FROM (
        SELECT SUM(total_price) AS monthly_total
        FROM BOOKING
        GROUP BY EXTRACT(YEAR  FROM booking_date),
                 EXTRACT(MONTH FROM booking_date)
    ) AS monthly_totals
)
ORDER BY year, month;

-- Version B: CTE + WHERE filter
WITH monthly_revenue AS (
    SELECT
        EXTRACT(YEAR  FROM b.booking_date) AS year,
        EXTRACT(MONTH FROM b.booking_date) AS month,
        COUNT(*)                           AS num_bookings,
        SUM(b.total_price)                 AS total_revenue,
        AVG(b.total_price)                 AS avg_booking_price
    FROM BOOKING b
    GROUP BY EXTRACT(YEAR  FROM b.booking_date),
             EXTRACT(MONTH FROM b.booking_date)
),
avg_monthly AS (
    SELECT AVG(total_revenue) AS avg_rev FROM monthly_revenue
)
SELECT
    mr.year,
    mr.month,
    mr.num_bookings,
    ROUND(mr.total_revenue::numeric,     2) AS total_revenue,
    ROUND(mr.avg_booking_price::numeric, 2) AS avg_booking_price
FROM monthly_revenue mr
CROSS JOIN avg_monthly am
WHERE mr.total_revenue > am.avg_rev
ORDER BY mr.year, mr.month;

-- Efficiency: Version B (CTE) is faster — aggregation computed once, reused.
--             Version A computes GROUP BY twice.

-- ============================================================
-- Query 4: Attractions with no bookings
-- No schema change — query unchanged.
-- ============================================================

-- Version A: LEFT JOIN + IS NULL
SELECT
    a.attraction_id,
    a.name        AS attraction_name,
    a.category,
    a.location,
    a.price,
    a.opening_hours
FROM ATTRACTION a
LEFT JOIN TICKET        t  ON a.attraction_id = t.attraction_id
LEFT JOIN BOOKINGTICKET bt ON t.ticket_id     = bt.ticket_id
WHERE bt.booking_id IS NULL
ORDER BY a.category, a.price DESC;

-- Version B: NOT IN with nested subqueries
SELECT
    a.attraction_id,
    a.name        AS attraction_name,
    a.category,
    a.location,
    a.price,
    a.opening_hours
FROM ATTRACTION a
WHERE a.attraction_id NOT IN (
    SELECT t.attraction_id
    FROM TICKET t
    WHERE t.ticket_id IN (
        SELECT bt.ticket_id FROM BOOKINGTICKET bt
    )
)
ORDER BY a.category, a.price DESC;

-- Efficiency: Version A is faster — hash anti-join, single pass.
--             Version B materialises each subquery level.

-- ============================================================
-- Query 5: Full customer booking history
-- No schema change — query unchanged.
-- ============================================================
SELECT
    c.first_name || ' ' || c.last_name  AS customer_name,
    c.email,
    c.country,
    a.name                              AS attraction_name,
    a.category,
    t.ticket_type,
    bt.quantity,
    t.price                             AS ticket_price,
    bt.quantity * t.price               AS line_total,
    EXTRACT(DAY   FROM b.booking_date)  AS booking_day,
    EXTRACT(MONTH FROM b.booking_date)  AS booking_month,
    EXTRACT(YEAR  FROM b.booking_date)  AS booking_year,
    b.booking_status,
    p.amount                            AS payment_amount
FROM CUSTOMER c
JOIN BOOKING       b  ON c.customer_id   = b.customer_id
JOIN PAYMENT       p  ON b.payment_id    = p.payment_id
JOIN BOOKINGTICKET bt ON b.booking_id    = bt.booking_id
JOIN TICKET        t  ON bt.ticket_id    = t.ticket_id
JOIN ATTRACTION    a  ON t.attraction_id = a.attraction_id
ORDER BY b.booking_date DESC, c.last_name;

-- ============================================================
-- Query 6: Ticket availability by month and attraction category
-- No schema change — query unchanged.
-- ============================================================
SELECT
    a.category,
    EXTRACT(MONTH FROM t.valid_date)     AS valid_month,
    EXTRACT(YEAR  FROM t.valid_date)     AS valid_year,
    COUNT(DISTINCT t.ticket_id)          AS num_ticket_types,
    SUM(t.available_quantity)            AS total_available,
    ROUND(AVG(t.price)::numeric, 2)      AS avg_ticket_price,
    ROUND(MIN(t.price)::numeric, 2)      AS min_price,
    ROUND(MAX(t.price)::numeric, 2)      AS max_price
FROM TICKET t
JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
GROUP BY a.category,
         EXTRACT(MONTH FROM t.valid_date),
         EXTRACT(YEAR  FROM t.valid_date)
HAVING SUM(t.available_quantity) > 0
ORDER BY valid_year, valid_month, a.category;

-- ============================================================
-- Query 7: Revenue per attraction category per quarter
-- No schema change — query unchanged.
-- ============================================================
SELECT
    a.category,
    EXTRACT(YEAR    FROM b.booking_date) AS year,
    EXTRACT(QUARTER FROM b.booking_date) AS quarter,
    COUNT(DISTINCT b.booking_id)         AS num_bookings,
    ROUND(SUM(bt.quantity * t.price)::numeric, 2) AS total_revenue,
    ROUND(AVG(bt.quantity * t.price)::numeric, 2) AS avg_revenue_per_booking
FROM ATTRACTION a
JOIN TICKET        t  ON a.attraction_id = t.attraction_id
JOIN BOOKINGTICKET bt ON t.ticket_id     = bt.ticket_id
JOIN BOOKING       b  ON bt.booking_id   = b.booking_id
GROUP BY a.category,
         EXTRACT(YEAR    FROM b.booking_date),
         EXTRACT(QUARTER FROM b.booking_date)
ORDER BY year, quarter, total_revenue DESC;

-- ============================================================
-- Query 8: Customers who reviewed an attraction they booked
-- Change: added is_deleted = FALSE to exclude deleted reviews
-- ============================================================
SELECT
    c.first_name || ' ' || c.last_name  AS customer_name,
    c.email,
    c.country,
    a.name                              AS attraction_name,
    a.category,
    r.rating,
    r.comment,
    EXTRACT(DAY   FROM r.review_date)   AS review_day,
    EXTRACT(MONTH FROM r.review_date)   AS review_month,
    EXTRACT(YEAR  FROM r.review_date)   AS review_year,
    b.total_price,
    b.booking_status
FROM CUSTOMER c
JOIN REVIEW        r  ON c.customer_id   = r.customer_id
JOIN ATTRACTION    a  ON r.attraction_id = a.attraction_id
JOIN BOOKING       b  ON c.customer_id   = b.customer_id
JOIN BOOKINGTICKET bt ON b.booking_id    = bt.booking_id
JOIN TICKET        t  ON bt.ticket_id    = t.ticket_id
                      AND t.attraction_id = a.attraction_id
WHERE r.is_deleted = FALSE
ORDER BY r.rating DESC, r.review_date DESC;

-- ============================================================
-- Delete 1: Remove expired tickets not linked to confirmed booking
-- No schema change — query unchanged.
-- ============================================================

-- Step 1: Remove BookingTicket entries for expired, unconfirmed tickets
DELETE FROM BOOKINGTICKET
WHERE ticket_id IN (
    SELECT t.ticket_id
    FROM TICKET t
    WHERE t.valid_date < CURRENT_DATE
      AND t.ticket_id NOT IN (
          SELECT bt2.ticket_id
          FROM BOOKINGTICKET bt2
          JOIN BOOKING b ON bt2.booking_id = b.booking_id
          WHERE b.booking_status = 'Confirmed'
      )
);

-- Step 2: Remove the expired tickets themselves
DELETE FROM TICKET
WHERE valid_date < CURRENT_DATE
  AND ticket_id NOT IN (
      SELECT bt.ticket_id FROM BOOKINGTICKET bt
  );

-- ============================================================
-- Delete 2: Remove reviews older than 1 year
-- Change: must first delete from REVIEWREACTION and REVIEWREPORT
--         (new FK constraints on REVIEW.review_id)
-- ============================================================

-- Step 1: Remove reactions on old reviews
DELETE FROM REVIEWREACTION
WHERE review_id IN (
    SELECT review_id FROM REVIEW
    WHERE review_date < CURRENT_DATE - INTERVAL '1 year'
);

-- Step 2: Remove reports on old reviews
DELETE FROM REVIEWREPORT
WHERE review_id IN (
    SELECT review_id FROM REVIEW
    WHERE review_date < CURRENT_DATE - INTERVAL '1 year'
);

-- Step 3: Remove the old reviews themselves
DELETE FROM REVIEW
WHERE review_date < CURRENT_DATE - INTERVAL '1 year';

-- ============================================================
-- Delete 3: Remove cancelled bookings and their booking tickets
-- No schema change — query unchanged.
-- ============================================================

-- Step 1: Remove related booking tickets
DELETE FROM BOOKINGTICKET
WHERE booking_id IN (
    SELECT booking_id FROM BOOKING
    WHERE booking_status = 'Cancelled'
);

-- Step 2: Remove the cancelled bookings
DELETE FROM BOOKING
WHERE booking_status = 'Cancelled';

-- ============================================================
-- Update 1: Increase ticket prices by 10% for high-demand tickets
-- No schema change — query unchanged.
-- ============================================================
UPDATE TICKET
SET price = ROUND((price * 1.10)::numeric, 2)
WHERE ticket_id IN (
    SELECT bt.ticket_id
    FROM BOOKINGTICKET bt
    GROUP BY bt.ticket_id
    HAVING COUNT(bt.booking_id) >= 2
);

-- ============================================================
-- Update 2: Confirm 'Pending' bookings from the last 30 days
-- No schema change — query unchanged.
-- ============================================================
UPDATE BOOKING
SET booking_status = 'Confirmed'
WHERE booking_status = 'Pending'
  AND booking_date >= CURRENT_DATE - INTERVAL '30 days';

-- ============================================================
-- Update 3: Apply 15% discount on all 'Museum' category attractions
-- No schema change — query unchanged.
-- ============================================================
UPDATE ATTRACTION
SET price = ROUND((price * 0.85)::numeric, 2)
WHERE category = 'Museum';
