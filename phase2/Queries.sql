-- ============================================================================
-- AttraTicket - Phase 2: Queries
-- ============================================================================
-- This file contains:
--   8 SELECT queries (4 with dual forms + 4 additional)
--   3 DELETE queries
--   3 UPDATE queries
-- ============================================================================
-- Database: PostgreSQL (AttraTicket)
-- ============================================================================

-- ############################################################################
--                        SELECT QUERIES (Dual Forms)
-- ############################################################################

-- ============================================================================
-- QUERY 1: Top-Rated Attractions by Category with Number of Bookings
-- Description (Hebrew): עבור כל קטגוריה, מצא את האטרקציות עם דירוג ממוצע גבוה
--   מ-4, והצג את מספר ההזמנות שלהן, ממוין לפי דירוג ממוצע בסדר יורד.
-- Purpose: Helps business managers identify the best-performing attractions
--   in each category for marketing and resource allocation.
-- ============================================================================

-- Version A: Using JOINs
SELECT 
    a.name AS attraction_name,
    a.category,
    a.location,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_rating,
    COUNT(DISTINCT bt.booking_id) AS total_bookings
FROM ATTRACTION a
JOIN REVIEW r ON a.attraction_id = r.attraction_id
JOIN TICKET t ON a.attraction_id = t.attraction_id
LEFT JOIN BOOKINGTICKET bt ON t.ticket_id = bt.ticket_id
GROUP BY a.attraction_id, a.name, a.category, a.location
HAVING AVG(r.rating) >= 4.0
ORDER BY avg_rating DESC, total_bookings DESC;

-- Version B: Using Subqueries
SELECT 
    a.name AS attraction_name,
    a.category,
    a.location,
    (SELECT ROUND(AVG(r.rating)::numeric, 2)
     FROM REVIEW r 
     WHERE r.attraction_id = a.attraction_id) AS avg_rating,
    (SELECT COUNT(DISTINCT bt.booking_id) 
     FROM TICKET t 
     JOIN BOOKINGTICKET bt ON t.ticket_id = bt.ticket_id
     WHERE t.attraction_id = a.attraction_id) AS total_bookings
FROM ATTRACTION a
WHERE (SELECT AVG(r2.rating) FROM REVIEW r2 WHERE r2.attraction_id = a.attraction_id) >= 4.0
ORDER BY avg_rating DESC, total_bookings DESC;

/*
 Efficiency Analysis (Query 1):
 Version A (JOINs) is generally MORE EFFICIENT because:
 - The query optimizer can process all joins in a single pass using hash joins or merge joins.
 - Aggregation (GROUP BY + HAVING) is computed once.
 
 Version B (Subqueries) is LESS EFFICIENT because:
 - Each correlated subquery in the SELECT and WHERE clauses runs once PER ROW in ATTRACTION.
 - For N attractions, the REVIEW subquery runs N times for filtering + N times for display,
   and the BOOKINGTICKET subquery runs N times, resulting in ~3N subquery executions.
*/

-- ============================================================================
-- QUERY 2: Customers Who Spent Above the Monthly Average for Their Booking Month
-- Description (Hebrew): מצא את כל הלקוחות שסכום ההזמנה שלהם גבוה מהממוצע של
--   החודש שבו הם ביצעו את ההזמנה. הצג שם, מדינה, תאריך מפורק, סכום, סטטוס ותשלום.
-- Purpose: Identify high-value customers relative to their booking month's average
--   for seasonal loyalty programs and targeted marketing.
-- ============================================================================

-- Version A: Using JOIN with Derived Table (EFFICIENT)
-- Pre-computes monthly averages ONCE in a derived table, then JOINs.
SELECT 
    c.first_name || ' ' || c.last_name AS full_name,
    c.country,
    c.email,
    EXTRACT(DAY FROM b.booking_date) AS booking_day,
    EXTRACT(MONTH FROM b.booking_date) AS booking_month,
    EXTRACT(YEAR FROM b.booking_date) AS booking_year,
    b.total_price,
    ROUND(ma.avg_monthly_price::numeric, 2) AS month_avg,
    b.booking_status
FROM CUSTOMER c
JOIN BOOKING b ON c.customer_id = b.customer_id
JOIN PAYMENT p ON b.payment_id = p.payment_id
JOIN (
    SELECT 
        EXTRACT(MONTH FROM booking_date) AS bmonth,
        EXTRACT(YEAR FROM booking_date) AS byear,
        AVG(total_price) AS avg_monthly_price
    FROM BOOKING
    GROUP BY EXTRACT(MONTH FROM booking_date), EXTRACT(YEAR FROM booking_date)
) ma ON EXTRACT(MONTH FROM b.booking_date) = ma.bmonth
    AND EXTRACT(YEAR FROM b.booking_date) = ma.byear
WHERE b.total_price > ma.avg_monthly_price
ORDER BY b.total_price DESC;

-- Version B: Using Correlated Subquery (LESS EFFICIENT)
-- Recalculates the monthly average for EVERY row individually.
SELECT 
    c.first_name || ' ' || c.last_name AS full_name,
    c.country,
    c.email,
    EXTRACT(DAY FROM b.booking_date) AS booking_day,
    EXTRACT(MONTH FROM b.booking_date) AS booking_month,
    EXTRACT(YEAR FROM b.booking_date) AS booking_year,
    b.total_price,
    (SELECT ROUND(AVG(b3.total_price)::numeric, 2)
     FROM BOOKING b3
     WHERE EXTRACT(MONTH FROM b3.booking_date) = EXTRACT(MONTH FROM b.booking_date)
       AND EXTRACT(YEAR FROM b3.booking_date) = EXTRACT(YEAR FROM b.booking_date)
    ) AS month_avg,
    b.booking_status
FROM CUSTOMER c
JOIN BOOKING b ON c.customer_id = b.customer_id
JOIN PAYMENT p ON b.payment_id = p.payment_id
WHERE b.total_price > (
    SELECT AVG(b2.total_price)
    FROM BOOKING b2
    WHERE EXTRACT(MONTH FROM b2.booking_date) = EXTRACT(MONTH FROM b.booking_date)
      AND EXTRACT(YEAR FROM b2.booking_date) = EXTRACT(YEAR FROM b.booking_date)
)
ORDER BY b.total_price DESC;

/*
 Efficiency Analysis (Query 2):
 Version A (JOIN with Derived Table) is MORE EFFICIENT because:
 - The derived table computes the monthly averages in a SINGLE PASS over the BOOKING table.
 - The result is a small table (one row per month/year), which is then joined efficiently
   using hash join or merge join.
 - Total scans of BOOKING: 2 (one for the derived table, one for the main query).

 Version B (Correlated Subquery) is LESS EFFICIENT because:
 - The correlated subquery in WHERE recalculates the monthly average for EACH ROW
   in the outer query. For N bookings, it performs N additional scans of BOOKING.
 - Additionally, the correlated subquery in SELECT runs another N scans for display.
 - Total scans of BOOKING: up to 2N + 1 (main scan + N for WHERE filter + N for display).
 - For a table with 10,000 bookings, this means ~20,001 scans vs just 2 scans in Version A.
*/

-- ============================================================================
-- QUERY 3: Monthly Revenue Analysis - Months with Revenue Above Category Average
-- Description (Hebrew): הצג ניתוח הכנסות חודשי - מצא את החודשים שבהם ההכנסה
--   הכוללת מהזמנות גבוהה מהממוצע החודשי, כולל מספר ההזמנות ומחיר ממוצע.
-- Purpose: Financial reporting for business managers to identify peak months.
-- ============================================================================

-- Version A: Using HAVING with subquery
SELECT 
    EXTRACT(YEAR FROM b.booking_date) AS year,
    EXTRACT(MONTH FROM b.booking_date) AS month,
    COUNT(*) AS num_bookings,
    ROUND(SUM(b.total_price)::numeric, 2) AS total_revenue,
    ROUND(AVG(b.total_price)::numeric, 2) AS avg_booking_price
FROM BOOKING b
GROUP BY EXTRACT(YEAR FROM b.booking_date), EXTRACT(MONTH FROM b.booking_date)
HAVING SUM(b.total_price) > (
    SELECT AVG(monthly_total) FROM (
        SELECT SUM(total_price) AS monthly_total
        FROM BOOKING
        GROUP BY EXTRACT(YEAR FROM booking_date), EXTRACT(MONTH FROM booking_date)
    ) AS monthly_totals
)
ORDER BY year, month;

-- Version B: Using CTE + WHERE filter (derived table)
WITH monthly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM b.booking_date) AS year,
        EXTRACT(MONTH FROM b.booking_date) AS month,
        COUNT(*) AS num_bookings,
        SUM(b.total_price) AS total_revenue,
        AVG(b.total_price) AS avg_booking_price
    FROM BOOKING b
    GROUP BY EXTRACT(YEAR FROM b.booking_date), EXTRACT(MONTH FROM b.booking_date)
),
avg_monthly AS (
    SELECT AVG(total_revenue) AS avg_rev FROM monthly_revenue
)
SELECT 
    mr.year,
    mr.month,
    mr.num_bookings,
    ROUND(mr.total_revenue::numeric, 2) AS total_revenue,
    ROUND(mr.avg_booking_price::numeric, 2) AS avg_booking_price
FROM monthly_revenue mr
CROSS JOIN avg_monthly am
WHERE mr.total_revenue > am.avg_rev
ORDER BY mr.year, mr.month;

/*
 Efficiency Analysis (Query 3):
 Version B (CTE) is MORE EFFICIENT because:
 - The monthly aggregation is computed ONCE and reused both for the result set and for 
   computing the average.
 - Version A computes the monthly aggregation TWICE: once in the main query and once 
   inside the HAVING subquery.
 - For large datasets, avoiding the duplicate GROUP BY scan can save significant I/O.
 
 Version A is simpler to read for simple cases but duplicates computation.
*/

-- ============================================================================
-- QUERY 4: Attractions That Have No Bookings (through the ticket→bookingticket chain)
-- Description (Hebrew): מצא את כל האטרקציות שאין להן אף הזמנה (דרך שרשרת
--   כרטיס→הזמנת_כרטיס). הצג שם אטרקציה, קטגוריה, מיקום, מחיר, ושעות פתיחה.
-- Purpose: Help managers identify attractions with zero demand that need
--   marketing campaigns or pricing adjustments (Attraction Management screen).
-- ============================================================================

-- Version A: Using LEFT JOIN chain with IS NULL (EFFICIENT)
-- The optimizer converts the LEFT JOIN + IS NULL into an anti-join, processed in one pass.
SELECT 
    a.attraction_id,
    a.name AS attraction_name,
    a.category,
    a.location,
    a.price,
    a.opening_hours
FROM ATTRACTION a
LEFT JOIN TICKET t ON a.attraction_id = t.attraction_id
LEFT JOIN BOOKINGTICKET bt ON t.ticket_id = bt.ticket_id
WHERE bt.booking_id IS NULL
ORDER BY a.category, a.price DESC;

-- Version B: Using NOT IN with Nested Subqueries (LESS EFFICIENT)
-- Forces full materialization of each subquery level before filtering.
SELECT 
    a.attraction_id,
    a.name AS attraction_name,
    a.category,
    a.location,
    a.price,
    a.opening_hours
FROM ATTRACTION a
WHERE a.attraction_id NOT IN (
    SELECT t.attraction_id
    FROM TICKET t
    WHERE t.ticket_id IN (
        SELECT bt.ticket_id
        FROM BOOKINGTICKET bt
    )
)
ORDER BY a.category, a.price DESC;

/*
 Efficiency Analysis (Query 4):
 Version A (LEFT JOIN + IS NULL) is MORE EFFICIENT because:
 - PostgreSQL converts the LEFT JOIN + IS NULL pattern into an optimized anti-join.
 - The entire join chain is processed in a SINGLE PASS using hash anti-join,
   meaning each table is scanned only once.
 - The optimizer can pipeline the results without materializing intermediate sets.

 Version B (NOT IN with nested subqueries) is LESS EFFICIENT because:
 - Each NOT IN / IN subquery must be FULLY MATERIALIZED before it can be used
   by the outer query. The inner subquery scans BOOKINGTICKET fully, produces a
   list, then the middle query scans TICKET fully, and finally ATTRACTION is filtered.
 - NOT IN has additional overhead for NULL-safety: PostgreSQL must check every value
   in the subquery result to verify none are NULL before it can exclude a row.
   If any value IS NULL, the entire NOT IN evaluates to UNKNOWN (no rows returned).
 - NOT IN cannot short-circuit — it must compare against ALL values in the list,
   whereas the anti-join in Version A stops as soon as a match is found.
 - For large tables, the materialization overhead of NOT IN significantly increases
   memory usage and execution time compared to the streaming anti-join approach.
*/


-- ############################################################################
--                    ADDITIONAL SELECT QUERIES (4 more)
-- ############################################################################

-- ============================================================================
-- QUERY 5: Full Customer Booking History with Ticket and Attraction Details
-- Description (Hebrew): הצג את היסטוריית ההזמנות המלאה של הלקוחות, כולל פרטי
--   הכרטיסים, שם האטרקציה, ותאריך ההזמנה מפורק ליום, חודש ושנה.
-- Purpose: Customer service screen - view complete booking trail for a customer.
-- ============================================================================
SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    c.country,
    a.name AS attraction_name,
    a.category,
    t.ticket_type,
    bt.quantity,
    t.price AS ticket_price,
    bt.quantity * t.price AS line_total,
    EXTRACT(DAY FROM b.booking_date) AS booking_day,
    EXTRACT(MONTH FROM b.booking_date) AS booking_month,
    EXTRACT(YEAR FROM b.booking_date) AS booking_year,
    b.booking_status,
    p.amount AS payment_amount
FROM CUSTOMER c
JOIN BOOKING b ON c.customer_id = b.customer_id
JOIN PAYMENT p ON b.payment_id = p.payment_id
JOIN BOOKINGTICKET bt ON b.booking_id = bt.booking_id
JOIN TICKET t ON bt.ticket_id = t.ticket_id
JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
ORDER BY b.booking_date DESC, c.last_name;

-- ============================================================================
-- QUERY 6: Ticket Availability Analysis by Month and Category
-- Description (Hebrew): ניתוח זמינות כרטיסים לפי חודש תוקף וקטגוריית אטרקציה,
--   כולל סה"כ כרטיסים זמינים, מחיר ממוצע, ומספר סוגי כרטיסים.
-- Purpose: Inventory management screen - plan ticket stock per season/category.
-- ============================================================================
SELECT 
    a.category,
    EXTRACT(MONTH FROM t.valid_date) AS valid_month,
    EXTRACT(YEAR FROM t.valid_date) AS valid_year,
    COUNT(DISTINCT t.ticket_id) AS num_ticket_types,
    SUM(t.available_quantity) AS total_available,
    ROUND(AVG(t.price)::numeric, 2) AS avg_ticket_price,
    ROUND(MIN(t.price)::numeric, 2) AS min_price,
    ROUND(MAX(t.price)::numeric, 2) AS max_price
FROM TICKET t
JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
GROUP BY a.category, EXTRACT(MONTH FROM t.valid_date), EXTRACT(YEAR FROM t.valid_date)
HAVING SUM(t.available_quantity) > 0
ORDER BY valid_year, valid_month, a.category;

-- ============================================================================
-- QUERY 7: Revenue Per Attraction Category Per Quarter
-- Description (Hebrew): הכנסות לפי קטגוריית אטרקציה לפי רבעון - מצא את הרבעון
--   הרווחי ביותר לכל קטגוריה, כולל מספר הזמנות וממוצע הכנסה להזמנה.
-- Purpose: Executive dashboard - quarterly revenue breakdown by category.
-- ============================================================================
SELECT 
    a.category,
    EXTRACT(YEAR FROM b.booking_date) AS year,
    EXTRACT(QUARTER FROM b.booking_date) AS quarter,
    COUNT(DISTINCT b.booking_id) AS num_bookings,
    ROUND(SUM(bt.quantity * t.price)::numeric, 2) AS total_revenue,
    ROUND(AVG(bt.quantity * t.price)::numeric, 2) AS avg_revenue_per_booking
FROM ATTRACTION a
JOIN TICKET t ON a.attraction_id = t.attraction_id
JOIN BOOKINGTICKET bt ON t.ticket_id = bt.ticket_id
JOIN BOOKING b ON bt.booking_id = b.booking_id
GROUP BY a.category, EXTRACT(YEAR FROM b.booking_date), EXTRACT(QUARTER FROM b.booking_date)
ORDER BY year, quarter, total_revenue DESC;

-- ============================================================================
-- QUERY 8: Customers Who Reviewed Attractions They Booked (Cross-Reference)
-- Description (Hebrew): מצא לקוחות שגם הזמינו וגם כתבו ביקורת על אטרקציה,
--   הצג פרטי הלקוח, דירוג, תאריך הביקורת מפורק, והמחיר ששילם.
-- Purpose: Customer engagement screen - match bookings with feedback for quality insights.
-- ============================================================================
SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    c.country,
    a.name AS attraction_name,
    a.category,
    r.rating,
    r.comment,
    EXTRACT(DAY FROM r.review_date) AS review_day,
    EXTRACT(MONTH FROM r.review_date) AS review_month,
    EXTRACT(YEAR FROM r.review_date) AS review_year,
    b.total_price,
    b.booking_status
FROM CUSTOMER c
JOIN REVIEW r ON c.customer_id = r.customer_id
JOIN ATTRACTION a ON r.attraction_id = a.attraction_id
JOIN BOOKING b ON c.customer_id = b.customer_id
JOIN BOOKINGTICKET bt ON b.booking_id = bt.booking_id
JOIN TICKET t ON bt.ticket_id = t.ticket_id AND t.attraction_id = a.attraction_id
ORDER BY r.rating DESC, r.review_date DESC;


-- ############################################################################
--                          DELETE QUERIES (3)
-- ############################################################################

-- ============================================================================
-- DELETE 1: Delete Tickets That Have Expired (valid_date in the past)
-- Description (Hebrew): מחק כרטיסים שתאריך התוקף שלהם עבר ושלא שייכים להזמנה
--   פעילה (מסך ניהול כרטיסים - ניקוי כרטיסים ישנים).
-- ============================================================================

-- First, show data before delete:
-- SELECT t.ticket_id, t.valid_date, a.name 
-- FROM TICKET t JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
-- WHERE t.valid_date < CURRENT_DATE;

DELETE FROM BOOKINGTICKET
WHERE ticket_id IN (
    SELECT t.ticket_id 
    FROM TICKET t
    WHERE t.valid_date < CURRENT_DATE
    AND t.ticket_id NOT IN (
        SELECT bt2.ticket_id FROM BOOKINGTICKET bt2
        JOIN BOOKING b ON bt2.booking_id = b.booking_id
        WHERE b.booking_status = 'Confirmed'
    )
);

DELETE FROM TICKET
WHERE valid_date < CURRENT_DATE
AND ticket_id NOT IN (
    SELECT bt.ticket_id FROM BOOKINGTICKET bt
);

-- After delete, verify:
-- SELECT COUNT(*) FROM TICKET WHERE valid_date < CURRENT_DATE;

-- ============================================================================
-- DELETE 2: Delete Reviews Older Than 1 Year
-- Description (Hebrew): מחק ביקורות שנכתבו לפני יותר משנה - ניקוי ביקורות
--   ישנות שכבר לא רלוונטיות (מסך ניהול ביקורות).
-- ============================================================================

-- First, show data before delete:
-- SELECT r.review_id, r.review_date, r.rating, c.first_name, a.name
-- FROM REVIEW r 
-- JOIN CUSTOMER c ON r.customer_id = c.customer_id
-- JOIN ATTRACTION a ON r.attraction_id = a.attraction_id
-- WHERE r.review_date < CURRENT_DATE - INTERVAL '1 year';

DELETE FROM REVIEW
WHERE review_date < CURRENT_DATE - INTERVAL '1 year';

-- After delete, verify:
-- SELECT COUNT(*) FROM REVIEW WHERE review_date < CURRENT_DATE - INTERVAL '1 year';

-- ============================================================================
-- DELETE 3: Delete Cancelled Bookings and Their Related BookingTickets
-- Description (Hebrew): מחק הזמנות שבוטלו (סטטוס 'Cancelled') יחד עם כרטיסי
--   ההזמנה המשויכים אליהם (מסך ניהול הזמנות - ניקוי הזמנות מבוטלות).
-- ============================================================================

-- First, show data before delete:
-- SELECT b.booking_id, b.booking_status, b.booking_date, c.first_name || ' ' || c.last_name AS customer
-- FROM BOOKING b 
-- JOIN CUSTOMER c ON b.customer_id = c.customer_id
-- WHERE b.booking_status = 'Cancelled';

-- Step 1: Delete related booking tickets
DELETE FROM BOOKINGTICKET
WHERE booking_id IN (
    SELECT b.booking_id FROM BOOKING b WHERE b.booking_status = 'Cancelled'
);

-- Step 2: Delete the cancelled bookings (must also handle PAYMENT FK)
-- First save payment_ids to delete later
DELETE FROM BOOKING
WHERE booking_status = 'Cancelled';

-- After delete, verify:
-- SELECT COUNT(*) FROM BOOKING WHERE booking_status = 'Cancelled';


-- ############################################################################
--                          UPDATE QUERIES (3)
-- ############################################################################

-- ============================================================================
-- UPDATE 1: Increase Ticket Prices by 10% for High-Demand Attractions
-- Description (Hebrew): העלה את מחיר הכרטיסים ב-10% לאטרקציות שיש להן יותר
--   מ-2 הזמנות (ביקוש גבוה). מסך ניהול תמחור.
-- ============================================================================

-- Before update:
-- SELECT t.ticket_id, a.name, t.price, t.ticket_type
-- FROM TICKET t JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
-- WHERE t.ticket_id IN (
--     SELECT bt.ticket_id FROM BOOKINGTICKET bt
--     GROUP BY bt.ticket_id HAVING COUNT(*) >= 2
-- );

UPDATE TICKET
SET price = ROUND((price * 1.10)::numeric, 2)
WHERE ticket_id IN (
    SELECT bt.ticket_id 
    FROM BOOKINGTICKET bt
    GROUP BY bt.ticket_id
    HAVING COUNT(bt.booking_id) >= 2
);

-- After update:
-- SELECT t.ticket_id, a.name, t.price, t.ticket_type
-- FROM TICKET t JOIN ATTRACTION a ON t.attraction_id = a.attraction_id;

-- ============================================================================
-- UPDATE 2: Set Booking Status to 'Confirmed' for Bookings from the Last 30 Days
--           That Are Still 'Pending'
-- Description (Hebrew): עדכן את סטטוס ההזמנה ל-'Confirmed' עבור הזמנות מ-30 הימים
--   האחרונים שעדיין בסטטוס 'Pending'. מסך ניהול הזמנות.
-- ============================================================================

-- Before update:
-- SELECT b.booking_id, c.first_name || ' ' || c.last_name AS customer,
--        b.booking_date, b.booking_status
-- FROM BOOKING b JOIN CUSTOMER c ON b.customer_id = c.customer_id
-- WHERE b.booking_status = 'Pending' 
--   AND b.booking_date >= CURRENT_DATE - INTERVAL '30 days';

UPDATE BOOKING
SET booking_status = 'Confirmed'
WHERE booking_status = 'Pending'
  AND booking_date >= CURRENT_DATE - INTERVAL '30 days';

-- After update:
-- SELECT b.booking_id, c.first_name || ' ' || c.last_name AS customer,
--        b.booking_date, b.booking_status
-- FROM BOOKING b JOIN CUSTOMER c ON b.customer_id = c.customer_id
-- WHERE b.booking_date >= CURRENT_DATE - INTERVAL '30 days';

-- ============================================================================
-- UPDATE 3: Apply 15% Discount on All Attractions in 'Museum' Category
-- Description (Hebrew): החל הנחה של 15% על כל האטרקציות בקטגוריית 'Museum'.
--   מסך ניהול אטרקציות - מבצעים וקידום מכירות.
-- ============================================================================

-- Before update:
-- SELECT a.attraction_id, a.name, a.category, a.price, a.location
-- FROM ATTRACTION a WHERE a.category = 'Museum';

UPDATE ATTRACTION
SET price = ROUND((price * 0.85)::numeric, 2)
WHERE category = 'Museum';

-- After update:
-- SELECT a.attraction_id, a.name, a.category, a.price, a.location
-- FROM ATTRACTION a WHERE a.category = 'Museum';
