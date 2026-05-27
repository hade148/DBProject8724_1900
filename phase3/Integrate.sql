-- ============================================================
-- Integrate.sql – Phase 3: Database Integration
-- Our system  : AttraTicket (CUSTOMER, ATTRACTION, TICKET,
--               PAYMENT, BOOKING, REVIEW, BOOKINGTICKET)
-- Their system: Review-Management (CUSTOMER, ATTRACTION,
--               TICKET, REVIEW, REVIEWREACTION, REVIEWREPORT)
-- Goal        : Merge into one unified schema, keeping our
--               table names and structure, adding only the
--               columns and tables that genuinely extend ours.
-- ============================================================

-- ============================================================
-- STEP 0 – Context (already executed before this script)
-- After restoring our backup we renamed the clashing tables:
--
  ALTER TABLE customer    RENAME TO customer1;
  ALTER TABLE attraction  RENAME TO attraction1;
  ALTER TABLE review      RENAME TO review1;
  ALTER TABLE ticket      RENAME TO ticket1;

  ALTER TABLE customer1   RENAME CONSTRAINT customer_pkey    TO customer1_pkey;
  ALTER TABLE attraction1 RENAME CONSTRAINT attraction_pkey  TO attraction1_pkey;
  ALTER TABLE review1     RENAME CONSTRAINT review_pkey      TO review1_pkey;
  ALTER TABLE ticket1     RENAME CONSTRAINT ticket1_pkey     TO ticket1_pkey;

-- Then we restored the second team's backup (their tables
-- loaded as: CUSTOMER, ATTRACTION, TICKET, REVIEW,
--            REVIEWREACTION, REVIEWREPORT).
-- ============================================================

-- ============================================================
-- STEP 1 – Enrich OUR tables with agreed new columns only
-- Integration decisions (see README_phase3.md for full table):
--   CUSTOMER  : add register_date (genuinely new)
--   ATTRACTION: no change (city ≡ location, already covered)
--   TICKET    : no change (their extra columns not adopted)
--   REVIEW    : add title, is_deleted, deleted_date
--               (content not added — our "comment" covers it)
-- ============================================================

-- ── CUSTOMER ─────────────────────────────────────────────────
ALTER TABLE customer1
    ADD COLUMN IF NOT EXISTS register_date DATE;

-- ── REVIEW ───────────────────────────────────────────────────
ALTER TABLE review1
    ADD COLUMN IF NOT EXISTS title        VARCHAR(200),
    ADD COLUMN IF NOT EXISTS is_deleted   BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS deleted_date DATE;

-- ============================================================
-- STEP 2 – Import THEIR data into OUR (renamed) tables
-- IDs are shifted DYNAMICALLY: offset = MAX(existing_id) so
-- that new rows always start right after the last existing ID.
-- The offsets are stored in a temp table BEFORE any inserts,
-- so they stay consistent across all statements.
-- ============================================================

-- ── 2-prep. Snapshot the current MAX IDs into a temp table ───
CREATE TEMP TABLE _offsets AS
SELECT
    (SELECT COALESCE(MAX(customer_id),   0) FROM customer1)   AS cust,
    (SELECT COALESCE(MAX(attraction_id), 0) FROM attraction1) AS attr,
    (SELECT COALESCE(MAX(ticket_id),     0) FROM ticket1)     AS tick,
    (SELECT COALESCE(MAX(review_id),     0) FROM review1)     AS rev;

-- ── 2a. CUSTOMER ─────────────────────────────────────────────
-- Their columns: customer_id, full_name, email, phone, register_date
-- Mapping: full_name split into first_name / last_name on first space.
INSERT INTO customer1
    (customer_id, first_name, last_name, email, phone,
     password, country, register_date)
SELECT
    c.customer_id + (SELECT cust FROM _offsets)        AS customer_id,
    SPLIT_PART(c.full_name::TEXT, ' ', 1)              AS first_name,
    NULLIF(SPLIT_PART(c.full_name::TEXT, ' ', 2), '')  AS last_name,
    c.email::TEXT                                      AS email,
    c.phone::TEXT                                      AS phone,
    'imported_pwd'                                     AS password,
    'Unknown'                                          AS country,
    c.register_date::DATE                              AS register_date
FROM CUSTOMER c
WHERE (c.customer_id + (SELECT cust FROM _offsets))
      NOT IN (SELECT customer_id FROM customer1);

-- ── 2b. ATTRACTION ───────────────────────────────────────────
-- Their columns: attraction_id, attraction_name, city, category, description
-- Mapping: attraction_name → name, city → location.
--          opening_hours defaults to '09:00:00'; price defaults to 0.
INSERT INTO attraction1
    (attraction_id, name, location, description,
     opening_hours, category, price)
SELECT
    a.attraction_id + (SELECT attr FROM _offsets)  AS attraction_id,
    a.attraction_name::TEXT                        AS name,
    a.city::TEXT                                   AS location,
    a.description::TEXT                            AS description,
    '09:00:00'                                     AS opening_hours,
    a.category::TEXT                               AS category,
    0                                              AS price
FROM ATTRACTION a
WHERE (a.attraction_id + (SELECT attr FROM _offsets))
      NOT IN (SELECT attraction_id FROM attraction1);

-- ── 2c. TICKET ───────────────────────────────────────────────
-- Their columns: ticket_id, purchase_date, visit_date, price,
--               ticket_status, customer_id, attraction_id
-- Mapping: visit_date → valid_date.
--          Extra columns (purchase_date, ticket_status, customer_id)
--          were decided NOT to adopt → ignored here.
INSERT INTO ticket1
    (ticket_id, attraction_id, price, valid_date,
     ticket_type, available_quantity)
SELECT
    t.ticket_id     + (SELECT tick FROM _offsets)  AS ticket_id,
    t.attraction_id + (SELECT attr FROM _offsets)  AS attraction_id,
    t.price::FLOAT                                 AS price,
    t.visit_date::DATE                             AS valid_date,
    'REGULAR'                                      AS ticket_type,
    NULL                                           AS available_quantity
FROM TICKET t
WHERE (t.ticket_id + (SELECT tick FROM _offsets))
      NOT IN (SELECT ticket_id FROM ticket1);

-- ── 2d. REVIEW ───────────────────────────────────────────────
-- Their columns: review_id, ticket_id, rating, title, content,
--               review_date, is_deleted, deleted_date
-- Mapping: customer_id and attraction_id resolved via ticket chain.
--          content → kept in their system but mapped to comment here
--          (since we already have comment and chose NOT to add content).
INSERT INTO review1
    (review_id, customer_id, attraction_id, rating, comment,
     review_date, title, is_deleted, deleted_date)
SELECT
    r.review_id     + (SELECT rev  FROM _offsets)          AS review_id,
    t.customer_id   + (SELECT cust FROM _offsets)          AS customer_id,
    t.attraction_id + (SELECT attr FROM _offsets)          AS attraction_id,
    r.rating::FLOAT                                        AS rating,
    COALESCE(r.content::TEXT, r.title::TEXT,
             'imported review')                            AS comment,
    r.review_date::DATE                                    AS review_date,
    r.title::TEXT                                          AS title,
    COALESCE(r.is_deleted::BOOLEAN, FALSE)                 AS is_deleted,
    r.deleted_date::DATE                                   AS deleted_date
FROM REVIEW r
JOIN TICKET t ON r.ticket_id = t.ticket_id
WHERE (r.review_id + (SELECT rev FROM _offsets))
      NOT IN (SELECT review_id FROM review1);

-- ── 2e. REVIEWREACTION – re-point FKs to our merged tables ──
-- Shift IDs so they reference the shifted customer/review rows.
ALTER TABLE REVIEWREACTION
    DROP CONSTRAINT IF EXISTS reviewreaction_review_id_fkey,
    DROP CONSTRAINT IF EXISTS reviewreaction_customer_id_fkey;

UPDATE REVIEWREACTION
SET review_id   = review_id   + (SELECT rev  FROM _offsets),
    customer_id = customer_id + (SELECT cust FROM _offsets);

ALTER TABLE REVIEWREACTION
    ADD CONSTRAINT reviewreaction_review_id_fkey
        FOREIGN KEY (review_id)   REFERENCES review1(review_id),
    ADD CONSTRAINT reviewreaction_customer_id_fkey
        FOREIGN KEY (customer_id) REFERENCES customer1(customer_id);

-- ── 2f. REVIEWREPORT – same treatment ────────────────────────
ALTER TABLE REVIEWREPORT
    DROP CONSTRAINT IF EXISTS reviewreport_review_id_fkey,
    DROP CONSTRAINT IF EXISTS reviewreport_customer_id_fkey;

UPDATE REVIEWREPORT
SET review_id   = review_id   + (SELECT rev  FROM _offsets),
    customer_id = customer_id + (SELECT cust FROM _offsets);

ALTER TABLE REVIEWREPORT
    ADD CONSTRAINT reviewreport_review_id_fkey
        FOREIGN KEY (review_id)   REFERENCES review1(review_id),
    ADD CONSTRAINT reviewreport_customer_id_fkey
        FOREIGN KEY (customer_id) REFERENCES customer1(customer_id);

-- ── 2-cleanup. Drop the temp offsets table ───────────────────
DROP TABLE IF EXISTS _offsets;

-- ============================================================
-- STEP 3 – Drop source tables from the second team's backup
-- ============================================================
DROP TABLE IF EXISTS TICKET     CASCADE;
DROP TABLE IF EXISTS REVIEW     CASCADE;
DROP TABLE IF EXISTS ATTRACTION CASCADE;
DROP TABLE IF EXISTS CUSTOMER   CASCADE;

-- ============================================================
-- STEP 4 – Rename our enriched tables back to canonical names
-- ============================================================
ALTER TABLE customer1   RENAME TO CUSTOMER;
ALTER TABLE attraction1 RENAME TO ATTRACTION;
ALTER TABLE ticket1     RENAME TO TICKET;
ALTER TABLE review1     RENAME TO REVIEW;

ALTER TABLE CUSTOMER   RENAME CONSTRAINT customer1_pkey   TO customer_pkey;
ALTER TABLE ATTRACTION RENAME CONSTRAINT attraction1_pkey TO attraction_pkey;
ALTER TABLE REVIEW     RENAME CONSTRAINT review1_pkey     TO review_pkey;
ALTER TABLE TICKET     RENAME CONSTRAINT ticket1_pkey     TO ticket_pkey;

-- ============================================================
-- STEP 5 – Verify row counts
-- ============================================================
SELECT 'CUSTOMER'      AS tbl, COUNT(*) AS rows FROM CUSTOMER
UNION ALL
SELECT 'ATTRACTION',           COUNT(*)          FROM ATTRACTION
UNION ALL
SELECT 'TICKET',               COUNT(*)          FROM TICKET
UNION ALL
SELECT 'PAYMENT',              COUNT(*)          FROM PAYMENT
UNION ALL
SELECT 'BOOKING',              COUNT(*)          FROM BOOKING
UNION ALL
SELECT 'REVIEW',               COUNT(*)          FROM REVIEW
UNION ALL
SELECT 'BOOKINGTICKET',        COUNT(*)          FROM BOOKINGTICKET
UNION ALL
SELECT 'REVIEWREACTION',       COUNT(*)          FROM REVIEWREACTION
UNION ALL
SELECT 'REVIEWREPORT',         COUNT(*)          FROM REVIEWREPORT;

