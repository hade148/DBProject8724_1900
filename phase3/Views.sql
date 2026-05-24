-- ============================================================
-- Views.sql – Phase 3: Views and Queries on Views
-- Two views: one from our original department's perspective,
--            one from the acquired department's perspective.
-- ============================================================

-- ============================================================
-- VIEW 1 – Our department (AttraTicket): Full Booking Summary
-- Combines CUSTOMER, BOOKING, PAYMENT, BOOKINGTICKET,
--          TICKET, ATTRACTION into one booking-level view.
-- ============================================================
CREATE OR REPLACE VIEW vw_booking_summary AS
SELECT
    c.customer_id,
    c.first_name || ' ' || COALESCE(c.last_name, '') AS customer_name,
    c.email,
    c.country,
    b.booking_id,
    b.booking_date,
    b.booking_status,
    b.total_price                                     AS booking_total,
    p.amount                                          AS payment_amount,
    a.name                                            AS attraction_name,
    a.category,
    a.location,
    t.ticket_type,
    t.valid_date,
    t.price                                           AS ticket_unit_price,
    bt.quantity,
    bt.quantity * t.price                             AS line_total
FROM CUSTOMER c
JOIN BOOKING         b  ON c.customer_id   = b.customer_id
JOIN PAYMENT         p  ON b.payment_id    = p.payment_id
JOIN BOOKINGTICKET   bt ON b.booking_id    = bt.booking_id
JOIN TICKET          t  ON bt.ticket_id    = t.ticket_id
JOIN ATTRACTION      a  ON t.attraction_id = a.attraction_id;

-- ── View 1 – Query A: Revenue per attraction category ────────
-- Total revenue and booking count grouped by category.
-- Useful for marketing budget allocation and analytics dashboards.
SELECT
    category,
    COUNT(DISTINCT booking_id)               AS total_bookings,
    ROUND(SUM(line_total)::numeric,      2)  AS total_revenue,
    ROUND(AVG(ticket_unit_price)::numeric, 2) AS avg_ticket_price
FROM vw_booking_summary
GROUP BY category
ORDER BY total_revenue DESC;

-- ── View 1 – Query B: Payment consistency check ───────────────
-- Compares booking total against payment amount for paid bookings.
-- Helps the finance team spot any payment discrepancies.
SELECT
    customer_name,
    email,
    booking_id,
    booking_date,
    booking_total,
    payment_amount,
    CASE
        WHEN booking_total = payment_amount THEN 'OK'
        ELSE 'MISMATCH'
    END AS payment_check
FROM vw_booking_summary
WHERE booking_status = 'PAID'
ORDER BY booking_date DESC
LIMIT 10;

-- ============================================================
-- VIEW 2 – Acquired department (Review-Management):
--          Review Analytics with moderation metadata.
-- Combines REVIEW, CUSTOMER, ATTRACTION, REVIEWREACTION,
--          REVIEWREPORT into a per-review analytics view.
-- ============================================================
CREATE OR REPLACE VIEW vw_review_analytics AS
SELECT
    r.review_id,
    c.customer_id,
    c.first_name || ' ' || COALESCE(c.last_name, '') AS reviewer_name,
    c.email,
    a.attraction_id,
    a.name                              AS attraction_name,
    a.category,
    a.location,
    r.rating,
    r.title                             AS review_title,
    r.comment                           AS review_body,
    r.review_date,
    r.is_deleted,
    r.deleted_date,
    COUNT(DISTINCT rr.reaction_id)      AS total_reactions,
    COUNT(DISTINCT rpt.report_id)       AS total_reports
FROM REVIEW r
JOIN CUSTOMER           c   ON r.customer_id   = c.customer_id
JOIN ATTRACTION         a   ON r.attraction_id = a.attraction_id
LEFT JOIN REVIEWREACTION  rr  ON r.review_id   = rr.review_id
LEFT JOIN REVIEWREPORT    rpt ON r.review_id   = rpt.review_id
GROUP BY
    r.review_id, c.customer_id, c.first_name, c.last_name,
    c.email, a.attraction_id, a.name, a.category, a.location,
    r.rating, r.title, r.comment, r.review_date,
    r.is_deleted, r.deleted_date;

-- ── View 2 – Query A: Attractions with reported reviews ───────
-- Lists attractions whose active reviews have been reported,
-- sorted by report count. Helps the moderation team prioritise.
SELECT
    attraction_name,
    category,
    location,
    COUNT(review_id)               AS num_reviews,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    SUM(total_reports)             AS total_reports,
    SUM(total_reactions)           AS total_reactions
FROM vw_review_analytics
WHERE is_deleted = FALSE
GROUP BY attraction_name, category, location
HAVING SUM(total_reports) > 0
ORDER BY total_reports DESC
LIMIT 10;

-- ── View 2 – Query B: Top reviewers ranking ──────────────────
-- Ranks customers by number of active reviews written,
-- average rating given, and engagement received.
-- Useful for loyalty programs and detecting spam accounts.
SELECT
    reviewer_name,
    email,
    COUNT(review_id)               AS reviews_written,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating_given,
    SUM(total_reactions)           AS total_reactions_received,
    SUM(total_reports)             AS total_reports_received
FROM vw_review_analytics
WHERE is_deleted = FALSE
GROUP BY reviewer_name, email
ORDER BY reviews_written DESC, avg_rating_given DESC
LIMIT 10;
