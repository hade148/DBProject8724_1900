# AttraTicket: Attraction Booking System

## Project Information
**Prepared by:** Hadasa Esther Elbaz, Tamar Rozen  
**System Name:** AttraTicket  
**Module:** Attraction Booking, Ticketing, Review Management

---

## Table of Contents
- [Stage 3: Integration and Views](#stage-3-integration-and-views)
  - [Introduction](#introduction)
  - [DSD of the Acquired Department (System B)](#dsd-of-the-acquired-department-system-b)
  - [ERD of System B — Reverse Engineering](#erd-of-system-b--reverse-engineering)
  - [Combined ERD](#combined-erd)
  - [DSD After Integration](#dsd-after-integration)
  - [Integration Decisions](#integration-decisions)
  - [Integration Process](#integration-process)
  - [Views](#views)

---

## Stage 3: Integration and Views

### Introduction
In this stage we integrated our **AttraTicket** database (attraction booking and ticketing) with the **Review-Management** database received from the second team.  

The integration follows **Method A**:
1. Restore our own backup.
2. Rename our conflicting tables to free namespace.
3. Restore the second team's backup on top.
4. Reverse-engineer their schema into an ERD.
5. Design a merged ERD.
6. Apply `ALTER TABLE` commands — no recreation from scratch.
7. Migrate their data into our tables.
8. Drop the now-redundant source tables and rename ours back.
9. Verify all Phase-2 queries still execute correctly.
10. Create two views (one per department perspective).

**Our system (Dept A):** CUSTOMER, ATTRACTION, TICKET, PAYMENT, BOOKING, REVIEW, BOOKINGTICKET  
**Their system (Dept B):** CUSTOMER, ATTRACTION, TICKET, REVIEW, REVIEWREACTION, REVIEWREPORT

---

## DSD of the Acquired Department (System B)

The tables loaded from the second team's backup:

| Table | Key Columns |
|---|---|
| CUSTOMER | customer_id (PK), full_name, email, phone, register_date |
| ATTRACTION | attraction_id (PK), attraction_name, city, category, description |
| TICKET | ticket_id (PK), purchase_date, visit_date, price, ticket_status, customer_id (FK→CUSTOMER), attraction_id (FK→ATTRACTION) |
| REVIEW | review_id (PK), ticket_id (FK→TICKET), rating, title, content, review_date, is_deleted, deleted_date |
| REVIEWREACTION | reaction_id (PK), reaction_type, reaction_date, review_id (FK→REVIEW), customer_id (FK→CUSTOMER) |
| REVIEWREPORT | report_id (PK), report_reason, report_description, report_date, admin_decision, decision_date, customer_id (FK→CUSTOMER), review_id (FK→REVIEW) |

>  **Note:** Screenshot of DSD to be added here after generating in ERDPlus.

---

## ERD of System B — Reverse Engineering

### Reverse Engineering Algorithm

The following algorithm was applied to recover the ERD from the physical schema:

**Step 1 — Identify entities:**  
Every table that has its own primary key (not just foreign keys) represents an independent entity.  
→ Entities: **CUSTOMER**, **ATTRACTION**, **TICKET**, **REVIEW**  
→ Weak / associative tables: **REVIEWREACTION**, **REVIEWREPORT**

**Step 2 — Identify relationships from foreign keys:**

| FK Column | Source Table | Referenced Table | Relationship |
|---|---|---|---|
| customer_id | TICKET | CUSTOMER | Many tickets → one customer |
| attraction_id | TICKET | ATTRACTION | Many tickets → one attraction |
| ticket_id | REVIEW | TICKET | Many reviews → one ticket |
| review_id | REVIEWREACTION | REVIEW | Reaction belongs to a review |
| customer_id | REVIEWREACTION | CUSTOMER | Reaction belongs to a customer |
| review_id | REVIEWREPORT | REVIEW | Report belongs to a review |
| customer_id | REVIEWREPORT | CUSTOMER | Report belongs to a customer |

**Step 3 — Determine cardinality:**  
- TICKET directly links to CUSTOMER (no booking layer) → many-to-one.  
- REVIEW links to TICKET → many-to-one.  
- REVIEWREACTION and REVIEWREPORT link both REVIEW and CUSTOMER → many-to-many resolved tables.

**Resulting ERD (textual):**
```
CUSTOMER ──< TICKET >── ATTRACTION
                │
             REVIEW ──< REVIEWREACTION >── CUSTOMER
                   ──< REVIEWREPORT    >── CUSTOMER
```

> 📌 **Note:** Full ERD diagram (ERDPlus screenshot) to be added here.

---

## Combined ERD

After merging both department ERDs we obtained the following unified structure:

```
CUSTOMER ──< BOOKING >── BOOKINGTICKET >── TICKET >── ATTRACTION
    │                                                      │
    └──────────────────────────────────────────────── REVIEW ──< REVIEWREACTION >── CUSTOMER
    │                                                        ──< REVIEWREPORT    >── CUSTOMER
    └─── PAYMENT (1:1 with BOOKING)
```

Key design decisions:
- The **BOOKING / BOOKINGTICKET** layer (ours) supersedes their direct `TICKET → CUSTOMER` link.
- **REVIEW** now connects to CUSTOMER and ATTRACTION directly (our model), making the `ticket_id` FK in their schema redundant in the merged design.
- **REVIEWREACTION** and **REVIEWREPORT** are added as new tables with FK references updated to our unified REVIEW and CUSTOMER.

> 📌 **Note:** Combined ERD diagram (ERDPlus screenshot) to be added here.

---

## DSD After Integration

The final schema after integration:

| Table | Status | Changes |
|---|---|---|
| CUSTOMER | Enriched | Added `register_date` |
| ATTRACTION | Unchanged | No new columns (their `city` ≡ our `location`) |
| TICKET | Unchanged | Their extra columns not adopted (group decision) |
| PAYMENT | Unchanged | Ours only — no equivalent in their system |
| BOOKING | Unchanged | Ours only — no equivalent in their system |
| BOOKINGTICKET | Unchanged | Ours only — no equivalent in their system |
| REVIEW | Enriched | Added `title`, `is_deleted`, `deleted_date` |
| REVIEWREACTION | **New** | Imported from their system, FKs updated |
| REVIEWREPORT | **New** | Imported from their system, FKs updated |

> 📌 **Note:** DSD after integration (ERDPlus screenshot) to be added here.

---

## Integration Decisions

### CUSTOMER

| Their Column | Our Column | Decision |
|---|---|---|
| customer_id | customer_id | Identical — their IDs shifted dynamically by MAX(existing_id) to avoid collision |
| full_name | first_name + last_name | Our split form is richer; `full_name` split on first space during import |
| email | email | Identical |
| phone | phone | Identical |
| register_date | *(missing)* | ✅ **Added** — genuinely new information |
| *(missing)* | password | Ours only — `'imported_pwd'` placeholder used for their rows |
| *(missing)* | country | Ours only — `'Unknown'` used for their rows |

### ATTRACTION

| Their Column | Our Column | Decision |
|---|---|---|
| attraction_id | attraction_id | Identical — their IDs shifted dynamically by MAX(existing_id) |
| attraction_name | name | Equivalent — kept our `name` |
| city | location | **Equivalent — kept our `location`** (no new column added) |
| category | category | Identical |
| description | description | Identical |
| *(missing)* | opening_hours | Ours only — default `'09:00:00'` for their rows |
| *(missing)* | price | Ours only — default `0` for their rows |

### TICKET

| Their Column | Our Column | Decision |
|---|---|---|
| ticket_id | ticket_id | Identical — their IDs shifted dynamically by MAX(existing_id) |
| visit_date | valid_date | **Equivalent — kept our `valid_date`** |
| price | price | Identical |
| purchase_date | *(missing)* | ❌ **Not adopted** — group decision |
| ticket_status | *(missing)* | ❌ **Not adopted** — group decision |
| customer_id | *(missing)* | ❌ **Not adopted** — link handled via BOOKING layer |
| attraction_id | attraction_id | Identical — shifted +1000 |

### REVIEW

| Their Column | Our Column | Decision |
|---|---|---|
| review_id | review_id | Identical — their IDs shifted dynamically by MAX(existing_id) |
| rating | rating | Identical |
| review_date | review_date | Identical |
| title | *(missing)* | ✅ **Added** — genuine extra metadata |
| content | comment | **Equivalent — kept our `comment`** (content not added) |
| is_deleted | *(missing)* | ✅ **Added** — soft-delete flag from their system |
| deleted_date | *(missing)* | ✅ **Added** — paired with is_deleted |
| ticket_id | *(missing)* | ❌ **Not adopted** — our model links review → customer + attraction directly |

### New Tables

| Table | Decision |
|---|---|
| REVIEWREACTION | ✅ **Kept** — entirely new to our schema; IDs and FKs updated dynamically |
| REVIEWREPORT | ✅ **Kept** — entirely new to our schema; IDs and FKs updated dynamically |

---

## Integration Process

**[View Integrate.sql](./Integrate.sql)**

### Step 0 — Preparation
We restored our own backup (`backup2`). Then we renamed our four conflicting tables to `customer1`, `attraction1`, `ticket1`, `review1` (including their primary-key constraint names) to free the original table names. We then restored the second team's backup, which loaded their tables under the original names.

```sql
ALTER TABLE customer    RENAME TO customer1;
ALTER TABLE attraction  RENAME TO attraction1;
ALTER TABLE review      RENAME TO review1;
ALTER TABLE ticket      RENAME TO ticket1;

ALTER TABLE customer1   RENAME CONSTRAINT customer_pkey    TO customer1_pkey;
ALTER TABLE attraction1 RENAME CONSTRAINT attraction_pkey  TO attraction1_pkey;
ALTER TABLE review1     RENAME CONSTRAINT review_pkey      TO review1_pkey;
ALTER TABLE ticket1     RENAME CONSTRAINT ticket1_pkey     TO ticket1_pkey;
```

### Step 1 — Column Enrichment
We added only the agreed new columns to our existing tables using `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`:

```sql
-- CUSTOMER: add register_date
ALTER TABLE customer1
    ADD COLUMN IF NOT EXISTS register_date DATE;

-- REVIEW: add title, is_deleted, deleted_date
ALTER TABLE review1
    ADD COLUMN IF NOT EXISTS title        VARCHAR(200),
    ADD COLUMN IF NOT EXISTS is_deleted   BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS deleted_date DATE;
```

No changes were made to ATTRACTION or TICKET (group decision).

### Step 2 — Data Migration

All IDs from the second team are shifted **dynamically** using `MAX(existing_id)` — the offset is calculated at runtime from the last existing ID in each table. This ensures that imported rows always start right after the highest existing ID, preventing collisions regardless of data volume.

Before any inserts, a temporary table snapshots the current MAX IDs. These values stay constant throughout the migration, keeping all foreign-key references consistent:

```sql
CREATE TEMP TABLE _offsets AS
SELECT
    (SELECT COALESCE(MAX(customer_id),   0) FROM customer1)   AS cust,
    (SELECT COALESCE(MAX(attraction_id), 0) FROM attraction1) AS attr,
    (SELECT COALESCE(MAX(ticket_id),     0) FROM ticket1)     AS tick,
    (SELECT COALESCE(MAX(review_id),     0) FROM review1)     AS rev;
```

**CUSTOMER** — `full_name` is split on the first space:
```sql
INSERT INTO customer1 (customer_id, first_name, last_name, email, phone, password, country, register_date)
SELECT
    c.customer_id + (SELECT cust FROM _offsets),
    SPLIT_PART(c.full_name::TEXT, ' ', 1),
    NULLIF(SPLIT_PART(c.full_name::TEXT, ' ', 2), ''),
    c.email::TEXT, c.phone::TEXT,
    'imported_pwd', 'Unknown',
    c.register_date::DATE
FROM CUSTOMER c
WHERE (c.customer_id + (SELECT cust FROM _offsets)) NOT IN (SELECT customer_id FROM customer1);
```

**ATTRACTION** — `attraction_name → name`, `city → location`:
```sql
INSERT INTO attraction1 (attraction_id, name, location, description, opening_hours, category, price)
SELECT
    a.attraction_id + (SELECT attr FROM _offsets), a.attraction_name::TEXT, a.city::TEXT,
    a.description::TEXT, '09:00:00', a.category::TEXT, 0
FROM ATTRACTION a
WHERE (a.attraction_id + (SELECT attr FROM _offsets)) NOT IN (SELECT attraction_id FROM attraction1);
```

**TICKET** — `visit_date → valid_date`, extra columns ignored:
```sql
INSERT INTO ticket1 (ticket_id, attraction_id, price, valid_date, ticket_type, available_quantity)
SELECT
    t.ticket_id + (SELECT tick FROM _offsets), t.attraction_id + (SELECT attr FROM _offsets),
    t.price::FLOAT, t.visit_date::DATE, 'REGULAR', NULL
FROM TICKET t
WHERE (t.ticket_id + (SELECT tick FROM _offsets)) NOT IN (SELECT ticket_id FROM ticket1);
```

**REVIEW** — `customer_id` and `attraction_id` resolved via the TICKET chain; `content → comment`:
```sql
INSERT INTO review1 (review_id, customer_id, attraction_id, rating, comment, review_date, title, is_deleted, deleted_date)
SELECT
    r.review_id + (SELECT rev FROM _offsets), t.customer_id + (SELECT cust FROM _offsets), t.attraction_id + (SELECT attr FROM _offsets),
    r.rating::FLOAT,
    COALESCE(r.content::TEXT, r.title::TEXT, 'imported review'),
    r.review_date::DATE, r.title::TEXT,
    COALESCE(r.is_deleted::BOOLEAN, FALSE), r.deleted_date::DATE
FROM REVIEW r
JOIN TICKET t ON r.ticket_id = t.ticket_id
WHERE (r.review_id + (SELECT rev FROM _offsets)) NOT IN (SELECT review_id FROM review1);
```

### Step 3 — REVIEWREACTION and REVIEWREPORT FK Update

For both new tables we:
1. Dropped their old FK constraints (pointing to the temporary source tables).
2. Shifted their `review_id` and `customer_id` columns using the same dynamic offsets from `_offsets`.
3. Added new FK constraints pointing to our merged `review1` and `customer1` tables.

```sql
ALTER TABLE REVIEWREACTION DROP CONSTRAINT IF EXISTS reviewreaction_review_id_fkey,
                           DROP CONSTRAINT IF EXISTS reviewreaction_customer_id_fkey;

UPDATE REVIEWREACTION SET review_id = review_id + (SELECT rev FROM _offsets),
                          customer_id = customer_id + (SELECT cust FROM _offsets);

ALTER TABLE REVIEWREACTION
    ADD CONSTRAINT reviewreaction_review_id_fkey   FOREIGN KEY (review_id)   REFERENCES review1(review_id),
    ADD CONSTRAINT reviewreaction_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer1(customer_id);
```
*(Same pattern applied to REVIEWREPORT. The `_offsets` temp table is dropped at the end.)*

### Step 4 — Cleanup and Rename

```sql
-- Drop source tables (now empty after migration)
DROP TABLE IF EXISTS TICKET, REVIEW, ATTRACTION, CUSTOMER CASCADE;

-- Rename our enriched tables back to canonical names
ALTER TABLE customer1   RENAME TO CUSTOMER;
ALTER TABLE attraction1 RENAME TO ATTRACTION;
ALTER TABLE ticket1     RENAME TO TICKET;
ALTER TABLE review1     RENAME TO REVIEW;

-- Restore constraint names
ALTER TABLE CUSTOMER   RENAME CONSTRAINT customer1_pkey   TO customer_pkey;
ALTER TABLE ATTRACTION RENAME CONSTRAINT attraction1_pkey TO attraction_pkey;
ALTER TABLE REVIEW     RENAME CONSTRAINT review1_pkey     TO review_pkey;
ALTER TABLE TICKET     RENAME CONSTRAINT ticket1_pkey     TO ticket_pkey;
```

### Step 5 — Row Count Verification

```sql
SELECT 'CUSTOMER'    AS tbl, COUNT(*) AS rows FROM CUSTOMER  UNION ALL
SELECT 'ATTRACTION',          COUNT(*)          FROM ATTRACTION UNION ALL
SELECT 'TICKET',              COUNT(*)          FROM TICKET     UNION ALL
SELECT 'PAYMENT',             COUNT(*)          FROM PAYMENT    UNION ALL
SELECT 'BOOKING',             COUNT(*)          FROM BOOKING    UNION ALL
SELECT 'REVIEW',              COUNT(*)          FROM REVIEW     UNION ALL
SELECT 'BOOKINGTICKET',       COUNT(*)          FROM BOOKINGTICKET UNION ALL
SELECT 'REVIEWREACTION',      COUNT(*)          FROM REVIEWREACTION UNION ALL
SELECT 'REVIEWREPORT',        COUNT(*)          FROM REVIEWREPORT;
```

> 📌 **Note:** Screenshot of verification output to be added here.

### Step 6 — Phase-2 Query Validation

All Phase-2 queries from `phase2/Queries.sql` were re-executed on the merged schema to confirm backward compatibility. The queries reference CUSTOMER, ATTRACTION, TICKET, BOOKING, BOOKINGTICKET, PAYMENT, and REVIEW — all of which retained their original column structure (only new nullable columns were added).

> 📌 **Note:** Screenshot confirming Phase-2 queries run successfully to be added here.

---

## Views

**[View Views.sql](./Views.sql)**

---

### View 1: `vw_booking_summary` — AttraTicket Department Perspective

**Description:**  
Joins the full booking chain — CUSTOMER → BOOKING → PAYMENT → BOOKINGTICKET → TICKET → ATTRACTION — into a single flat view. Each row represents one ticket line within a booking, making it easy to calculate per-line revenue, spot payment mismatches, and produce per-category analytics.

**Definition:**
```sql
CREATE OR REPLACE VIEW vw_booking_summary AS
SELECT
    c.customer_id,
    c.first_name || ' ' || COALESCE(c.last_name, '') AS customer_name,
    c.email,
    c.country,
    b.booking_id,
    b.booking_date,
    b.booking_status,
    b.total_price          AS booking_total,
    p.amount               AS payment_amount,
    a.name                 AS attraction_name,
    a.category,
    a.location,
    t.ticket_type,
    t.valid_date,
    t.price                AS ticket_unit_price,
    bt.quantity,
    bt.quantity * t.price  AS line_total
FROM CUSTOMER c
JOIN BOOKING         b  ON c.customer_id   = b.customer_id
JOIN PAYMENT         p  ON b.payment_id    = p.payment_id
JOIN BOOKINGTICKET   bt ON b.booking_id    = bt.booking_id
JOIN TICKET          t  ON bt.ticket_id    = t.ticket_id
JOIN ATTRACTION      a  ON t.attraction_id = a.attraction_id;
```

**Sample output (`SELECT * FROM vw_booking_summary LIMIT 10`):**

| customer_name | email | country | booking_id | booking_date | booking_status | booking_total | payment_amount | attraction_name | category | location | ticket_type | valid_date | ticket_unit_price | quantity | line_total |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Noa Levi | noa.levi1@example.com | Israel | 1 | 2026-03-10 | PAID | 79.90 | 79.90 | OldPortWalk | Tour | TelAviv | REGULAR | 2026-04-01 | 79.90 | 1 | 79.90 |
| Yael Cohen | yael.cohen2@example.com | Israel | 2 | 2026-03-11 | PAID | 55.00 | 55.00 | CityMuseum | Museum | Haifa | REGULAR | 2026-04-01 | 55.00 | 2 | 110.00 |
| Liam Dan | liam.dan3@example.com | Israel | 3 | 2026-03-12 | PAID | 120.00 | 120.00 | NegevSafari | Nature | Beersheba | FAMILY | 2026-04-02 | 120.00 | 3 | 360.00 |
| Maya Barak | maya.barak4@example.com | Israel | 4 | 2026-03-13 | PAID | 140.00 | 140.00 | AquaPark | Water | Eilat | VIP | 2026-04-02 | 140.00 | 2 | 280.00 |
| Omer Katz | omer.katz5@example.com | Israel | 5 | 2026-03-14 | PAID | 95.50 | 95.50 | FoodMarket | Food | Jerusalem | REGULAR | 2026-04-03 | 95.50 | 1 | 95.50 |

> 📌 **Note:** Screenshot of `SELECT *` output to be added here.

---

#### Query A on View 1: Revenue per Attraction Category

**Description:**  
Groups the view by attraction category and computes total booking count, total revenue (sum of all line totals), and average ticket unit price. Used on the **Analytics Dashboard** to identify which categories generate the most revenue and to guide marketing budget allocation.

```sql
SELECT
    category,
    COUNT(DISTINCT booking_id)                AS total_bookings,
    ROUND(SUM(line_total)::numeric,       2)  AS total_revenue,
    ROUND(AVG(ticket_unit_price)::numeric, 2) AS avg_ticket_price
FROM vw_booking_summary
GROUP BY category
ORDER BY total_revenue DESC;
```

**Sample output:**

| category | total_bookings | total_revenue | avg_ticket_price |
|---|---|---|---|
| Nature | 1 | 360.00 | 120.00 |
| Water | 1 | 280.00 | 140.00 |
| Food | 1 | 95.50 | 95.50 |
| Museum | 1 | 110.00 | 55.00 |
| Tour | 1 | 79.90 | 79.90 |

> 📌 **Note:** Screenshot of query output to be added here.

---

#### Query B on View 1: Payment Consistency Check

**Description:**  
Filters paid bookings and compares `booking_total` against `payment_amount`. Rows where the two values differ are flagged as `'MISMATCH'`. Used by the **Finance Team** to detect any payment processing errors or data inconsistencies.

```sql
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
```

**Sample output:**

| customer_name | email | booking_id | booking_date | booking_total | payment_amount | payment_check |
|---|---|---|---|---|---|---|
| Omer Katz | omer.katz5@example.com | 5 | 2026-03-14 | 95.50 | 95.50 | OK |
| Maya Barak | maya.barak4@example.com | 4 | 2026-03-13 | 140.00 | 140.00 | OK |
| Liam Dan | liam.dan3@example.com | 3 | 2026-03-12 | 120.00 | 120.00 | OK |
| Yael Cohen | yael.cohen2@example.com | 2 | 2026-03-11 | 55.00 | 55.00 | OK |
| Noa Levi | noa.levi1@example.com | 1 | 2026-03-10 | 79.90 | 79.90 | OK |

> 📌 **Note:** Screenshot of query output to be added here.

---

### View 2: `vw_review_analytics` — Review-Management Department Perspective

**Description:**  
Joins REVIEW with CUSTOMER and ATTRACTION for full review context, then LEFT JOINs REVIEWREACTION and REVIEWREPORT to aggregate per-review engagement and moderation metrics. Each row represents one active review enriched with reaction and report counts. Used by the **Moderation Team** to prioritise content review and identify influential reviewers.

**Definition:**
```sql
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
JOIN CUSTOMER          c   ON r.customer_id   = c.customer_id
JOIN ATTRACTION        a   ON r.attraction_id = a.attraction_id
LEFT JOIN REVIEWREACTION  rr  ON r.review_id  = rr.review_id
LEFT JOIN REVIEWREPORT    rpt ON r.review_id  = rpt.review_id
GROUP BY
    r.review_id, c.customer_id, c.first_name, c.last_name,
    c.email, a.attraction_id, a.name, a.category, a.location,
    r.rating, r.title, r.comment, r.review_date,
    r.is_deleted, r.deleted_date;
```

**Sample output (`SELECT * FROM vw_review_analytics LIMIT 10`):**

| review_id | reviewer_name | email | attraction_name | category | location | rating | review_title | review_body | review_date | is_deleted | total_reactions | total_reports |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Noa Levi | noa.levi1@example.com | OldPortWalk | Tour | TelAviv | 4.8 | NULL | Great guided route and atmosphere | 2026-03-15 | false | 0 | 0 |
| 2 | Yael Cohen | yael.cohen2@example.com | CityMuseum | Museum | Haifa | 4.3 | NULL | Interesting exhibits and easy access | 2026-03-16 | false | 0 | 0 |
| 3 | Liam Dan | liam.dan3@example.com | NegevSafari | Nature | Beersheba | 4.6 | NULL | Kids enjoyed the whole day | 2026-03-17 | false | 0 | 0 |
| 4 | Maya Barak | maya.barak4@example.com | AquaPark | Water | Eilat | 4.1 | NULL | Fun slides but crowded at noon | 2026-03-18 | false | 0 | 0 |
| 5 | Omer Katz | omer.katz5@example.com | FoodMarket | Food | Jerusalem | 4.7 | NULL | Excellent food and local stories | 2026-03-19 | false | 0 | 0 |

> 📌 **Note:** Screenshot of `SELECT *` output to be added here.

---

#### Query A on View 2: Attractions with Reported Reviews

**Description:**  
Groups non-deleted reviews by attraction and returns only those where at least one review has been reported (`total_reports > 0`). Shows average rating, total reports, and total reactions per attraction, sorted by report count descending. Used by the **Moderation Team** to prioritise which attraction pages need content review.

```sql
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
```

> 📌 **Note:** Output will be available after the second team's REVIEWREPORT data is inserted. Screenshot to be added here.

---

#### Query B on View 2: Top Reviewers Ranking

**Description:**  
Groups non-deleted reviews by reviewer and ranks them by number of reviews written, average rating given, and total engagement (reactions and reports received). Used to identify **loyal and influential reviewers** for loyalty programmes, and to flag accounts with unusually high report rates that may indicate spam.

```sql
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
```

**Sample output:**

| reviewer_name | email | reviews_written | avg_rating_given | total_reactions_received | total_reports_received |
|---|---|---|---|---|---|
| Noa Levi | noa.levi1@example.com | 1 | 4.80 | 0 | 0 |
| Omer Katz | omer.katz5@example.com | 1 | 4.70 | 0 | 0 |
| Liam Dan | liam.dan3@example.com | 1 | 4.60 | 0 | 0 |
| Yael Cohen | yael.cohen2@example.com | 1 | 4.30 | 0 | 0 |
| Maya Barak | maya.barak4@example.com | 1 | 4.10 | 0 | 0 |

> 📌 **Note:** Screenshot of query output to be added here.

---
