# AttraTicket: Attraction Booking System

## Project Information
**Prepared by:** Hadasa Esther Elbaz, Tamar Rozen
**System Name:** AttraTicket  
**Module:** Attraction Booking, Ticketing 

---

## Table of Contents
- [Stage 1: Design and Build the Database](#stage-1-design-and-build-the-database)
  - [Introduction](#introduction)
  - [AI-Generated Prototype](#ai-generated-prototype)
  - [Logical Design](#logical-design)
  - [Data Dictionary](#data)
  - [SQL Scripts](#sql-scripts)
  - [Backup & Recovery](#backup--recovery)
- [Stage 2: Queries and Constraints](#stage-2-queries-and-constraints)
  - [Introduction](#introduction-1)
  - [Deliverables](#deliverables)
  - [SELECT Queries](#select-queries)
    - [Query 1 — Top-Rated Attractions by Category with Booking Count](#query-1--top-rated-attractions-by-category-with-booking-count)
    - [Query 2 — Customers Who Spent Above the Monthly Average](#query-2--customers-who-spent-above-the-monthly-average)
    - [Query 3 — Monthly Revenue Above the Overall Monthly Average](#query-3--monthly-revenue-above-the-overall-monthly-average)
    - [Query 4 — Attractions With No Bookings](#query-4--attractions-with-no-bookings)
    - [Query 5 — Full Customer Booking History](#query-5--full-customer-booking-history)
    - [Query 6 — Ticket Availability Analysis by Month and Category](#query-6--ticket-availability-analysis-by-month-and-category)
    - [Query 7 — Revenue per Attraction Category per Quarter](#query-7--revenue-per-attraction-category-per-quarter)
    - [Query 8 — Customers Who Reviewed Attractions They Booked](#query-8--customers-who-reviewed-attractions-they-booked)
  - [DELETE Queries](#delete-queries)
    - [DELETE 1 — Remove Expired Tickets](#delete-1--remove-expired-tickets-not-linked-to-confirmed-bookings)
    - [DELETE 2 — Remove Old Reviews](#delete-2--remove-reviews-older-than-one-year)
    - [DELETE 3 — Remove Cancelled Bookings](#delete-3--remove-cancelled-bookings-and-their-booking-tickets)
  - [UPDATE Queries](#update-queries)
    - [UPDATE 1 — Price Increase for High-Demand Tickets](#update-1--increase-ticket-prices-by-10-for-high-demand-attractions)
    - [UPDATE 2 — Auto-Confirm Recent Pending Bookings](#update-2--auto-confirm-recent-pending-bookings)
    - [UPDATE 3 — Museum Category Discount](#update-3--apply-a-15-discount-to-all-museum-category-attractions)
  - [Constraints](#constraints)
    - [Constraint 1 — Booking Date Not in Future](#constraint-1--booking-date-cannot-be-in-the-future-chk_booking_date_not_future)
    - [Constraint 2 — Ticket Quantity Max 1000](#constraint-2--ticket-available-quantity-cannot-exceed-1000-chk_ticket_max_quantity)
    - [Constraint 3 — Attraction Price Max 500](#constraint-3--attraction-price-cannot-exceed-500-chk_attraction_max_price)
  - [Rollback & Commit Demonstrations](#rollback--commit-demonstrations)
  - [Indexes](#indexes)
    - [Index 1 — idx_customer_country](#index-1--idx_customer_country-on-customercountry)
    - [Index 2 — idx_ticket_valid_date](#index-2--idx_ticket_valid_date-on-ticketvalid_date)
    - [Index 3 — idx_booking_status](#index-3--idx_booking_status-on-bookingbooking_status)

---

## Stage 1: Design and Build the Database

## Introduction
The **AttraTicket Database** is a booking and ticket management system for attractions.  
It connects customers, attractions, ticket inventory, bookings, payments, and reviews in one normalized relational schema.

#### Purpose of the Database
This database provides a reliable solution to:
- **Manage Customers:** registration details, contact information, and identity records.
- **Manage Attractions:** location, category, opening hours, descriptions, and base pricing.
- **Manage Ticketing:** ticket type, validity date, available quantity, and attraction linkage.
- **Manage Transactions:** booking records, payment linkage, and booking status.
- **Collect Feedback:** customer ratings and comments per attraction.
- **Enable Reporting:** perform SQL-based analysis over bookings, reviews, and attraction demand.

#### Potential Use Cases
- **Customers** can book attractions, purchase tickets, and submit reviews.
- **Business Managers** can analyze popular attractions and customer satisfaction.
- **Support Teams** can track booking/payment relationships and resolve issues quickly.
---

## AI-Generated Prototype
### System Screens
The system was planned using a **Top-Down approach** with UI characterization in Google AI Studio.

 **[Live Demo (AI Studio Link)](https://ai.studio/apps/22d49e6f-06a0-43ed-933f-a033e8c625c5)**


<img width="1845" height="789" alt="Screenshot 2026-04-13 225842" src="https://github.com/user-attachments/assets/a3711a36-d6a5-4b26-aca7-46caf8a6759f" />
<img width="1551" height="879" alt="צילום מסך 2026-04-14 114529" src="https://github.com/user-attachments/assets/095fea65-4622-469e-973b-34fedab30abe" />
<img width="1751" height="789" alt="Screenshot 2026-04-13 230115" src="https://github.com/user-attachments/assets/a201985f-9863-4d41-849d-6635a77eb7fb" />
<img width="1729" height="785" alt="Screenshot 2026-04-13 225957" src="https://github.com/user-attachments/assets/5e76834b-3dc5-4299-9342-ad1fefb62e46" />

---

## Logical Design
### ERD (Entity-Relationship Diagram) & DSD (Data Structure Diagram)
The database schema was designed according to **3NF (Third Normal Form)** to reduce redundancy and enforce consistency.

### ERD (Entity-Relationship Diagram)    
![ERD Diagram](./phase1/ERDandDSDfiles/ERD.png)

### DSD (Data Structure Diagram)   
![DSD Diagram](./phase1/ERDandDSDfiles/DSD.png)

---

## SQL Scripts
Provide the following SQL scripts:

- **Create Tables Script**  
  **[View Create Tables](phase1/SQLscripts/02-createTables.sql)**

- **Drop Tables Script**  
  **[View Drop Tables](phase1/SQLscripts/01-dropTables.sql)**

- **Insert Data Script**  
  **[View Insert Data](phase1/SQLscripts/03-insertTables.sql)**

- **Select All Data Script**  
  **[View Select All](phase1/SQLscripts/04-selectAll.sql)**

---

### Data  

#### First tool: using [Mockaroo](https://www.mockaroo.com/) to create CSV files
Mockaroo was used to generate realistic CSV datasets that match the schema field names and data types.  
For each table we defined the exact column names (as in the SQL schema), selected appropriate generators (names, emails, prices, dates, etc.), and exported the result as **CSV with header** (Windows CRLF) to ensure smooth import into PostgreSQL.

##### Configuring data generation for **ATTRACTION**
We created a Mockaroo schema for the **ATTRACTION** table with the following key mapping:
- `attraction_id` → Row Number (unique identifier)
- `name` → Product Name (used as attraction name)
- `location` → Street Name (used as attraction location)
- `description` → Product Description
- `opening_hours` → Time (12-hour format)
- `category` → Product Category
- `price` → Product Price

**Mockaroo configuration screenshot:**  
<img width="1282" height="632" alt="attraction" src="https://github.com/user-attachments/assets/f3157410-3879-4921-a2dc-d89b9f81408b" />

##### Configuring data generation for **CUSTOMER**
For the **CUSTOMER** table we configured identity and contact fields with realistic constraints:
- `customer_id` → Row Number
- `first_name` / `last_name` → First/Last Name generators
- `email` → Email Address generator
- `phone` → Phone generator with formatted pattern
- `password` → Password generator (minimum length and mixed character settings)
- `country` → Country generator

**Mockaroo configuration screenshot:**  
<img width="1796" height="641" alt="customer" src="https://github.com/user-attachments/assets/0eaeba06-1eae-4348-a6aa-8d0c0be348f2" />

##### Configuring data generation for **TICKET**
For the **TICKET** table we generated ticket details with meaningful ranges:
- `ticket_id` → Row Number
- `attraction_id` → Row Number (to match existing attraction identifiers)
- `price` → Product Price
- `valid_date` → Datetime within the project-defined date range
- `ticket_type` → Custom List (general_admission, VIP, student, senior)
- `available_quantity` → Number range (1–100)

**Mockaroo configuration screenshot:**  
<img width="1806" height="577" alt="ticket" src="https://github.com/user-attachments/assets/d7d62a22-a114-47e3-9e9c-f4b7b3944bdc" />

##### Configuring data generation for **BOOKING**
For the **BOOKING** table we generated transactional booking records:
- `booking_id` → Row Number
- `customer_id` → Row Number (to match existing customers)
- `booking_date` → Datetime within a defined range
- `total_price` → Product Price
- `payment_id` → Row Number (to match existing payments)

**Mockaroo configuration screenshot:**  
<img width="1389" height="524" alt="booking" src="https://github.com/user-attachments/assets/a2e7cf32-2f92-4765-bae8-a3eafd74b858" />


#### Second tool: Loading from files (CSV Import)
The import process was performed through the pgAdmin import window:
<img width="1041" height="375" alt="צילום מסך 2026-04-14 003427" src="https://github.com/user-attachments/assets/96ac8bb0-b8ef-4aa2-8689-a4601fc09bb7" />

After running the import, pgAdmin confirmed the process completed successfully:
<img width="971" height="389" alt="צילום מסך 2026-04-14 003350" src="https://github.com/user-attachments/assets/ac1b9d4c-b288-4e80-a1da-e487ffdfc5a9" />

##### Row Count Validation
To verify that the table was populated correctly and meets the project requirements, we executed:

`SELECT COUNT(*) FROM CUSTOMER;`

<img width="183" height="111" alt="SQL COUNT query" src="https://github.com/user-attachments/assets/f13716d4-8084-40f0-a62c-0859346dbe8c" />

**Result:** `20000` rows successfully loaded into the `CUSTOMER` table.

---

#### Third tool: Python Program — Direct Insert to the Database
A Python script connects directly to PostgreSQL and inserts data into the tables without using an intermediate import step (CSV/SQL import).

- **Direct DB insert script:**  
  **[View `insert_data.py`](phase1/programingData/insert_data.py)**
<img width="1018" height="447" alt="image" src="https://github.com/user-attachments/assets/e4bcc1e1-9120-4dcc-b9db-28ee4c35f068" />
<img width="1486" height="656" alt="image" src="https://github.com/user-attachments/assets/d9410b93-70e0-49f1-bbfb-0cf26d4f1cba" />

---

## Backup & Recovery
Backup and restore were executed to ensure data safety and reproducibility.

- A full backup file was created with date/time naming.
- Restore was tested on a clean DB instance.
- Post-restore validation was performed using row-count queries.
  **[Go to Backup Folder](phase1/Backup)**  
  **[View Backup File `backup14_04_2026`](phase1/Backup/backup14_04_2026)**

<img width="1050" height="830" alt="image" src="https://github.com/user-attachments/assets/04c34005-5214-4de4-87d3-7cfa4428a844" />
<img width="870" height="397" alt="image" src="https://github.com/user-attachments/assets/3df95fad-846b-4226-9242-d19aac69427c" />

the restore:
<img width="1050" height="601" alt="image" src="https://github.com/user-attachments/assets/364fa4d9-a3a1-4692-b9da-1aa06636da41" />
<img width="565" height="391" alt="image" src="https://github.com/user-attachments/assets/cde294f5-97bc-4d23-b1d4-ae58a5db1b7b" />

---

## Stage 2: Queries and Constraints

### Introduction

In this stage we performed advanced querying of the AttraTicket database.  
We wrote complex SELECT, DELETE, and UPDATE queries, worked with transactions (`ROLLBACK` / `COMMIT`), added integrity constraints via `ALTER TABLE`, and added indexes to improve query performance.

All queries are aligned with the system screens defined in Stage 1 (Customer Management, Booking Management, Ticket Management, Analytics Dashboard) so they can be connected directly to the GUI in the final project phase.

---

### Deliverables

| File | Link |
|------|------|
| Queries.sql | [View File](phase2/Queries.sql) |
| Constraints.sql | [View File](phase2/Constraints.sql) |
| RollbackCommit.sql | [View File](phase2/RollbackCommit.sql) |
| Index.sql | [View File](phase2/Index.sql) |
| backup2 | `phase2/backup2` |

---

## SELECT Queries

The query file contains:
- **4 dual-form SELECT queries** — each written in two different ways, with a detailed explanation of which form is more efficient and why.
- **4 additional SELECT queries** — non-trivial, multi-table queries using `GROUP BY`, `HAVING`, `ORDER BY`, subqueries, and date decomposition (`EXTRACT` for day / month / year / quarter).

---

### Query 1 — Top-Rated Attractions by Category with Booking Count

**Description:** עבור כל קטגוריה, מצא את האטרקציות עם דירוג ממוצע גבוה מ-4, והצג את מספר ההזמנות שלהן.

For each attraction, calculate the average customer review rating and the total number of distinct bookings made through its tickets. Display only attractions with an average rating above 4.0, sorted by rating descending. This query is used on the **Analytics Dashboard** screen to highlight top performers per category.

#### Version A — Using JOINs (more efficient)

```sql
SELECT
    a.name          AS attraction_name,
    a.category,
    a.location,
    ROUND(AVG(r.rating)::numeric, 2)      AS avg_rating,
    COUNT(DISTINCT bt.booking_id)         AS total_bookings
FROM ATTRACTION a
JOIN REVIEW       r  ON a.attraction_id = r.attraction_id
JOIN TICKET       t  ON a.attraction_id = t.attraction_id
LEFT JOIN BOOKINGTICKET bt ON t.ticket_id = bt.ticket_id
GROUP BY a.attraction_id, a.name, a.category, a.location
HAVING AVG(r.rating) >= 4.0
ORDER BY avg_rating DESC, total_bookings DESC;
```

#### Version B — Using Correlated Subqueries (less efficient)

```sql
SELECT
    a.name          AS attraction_name,
    a.category,
    a.location,
    (SELECT ROUND(AVG(r.rating)::numeric, 2)
     FROM REVIEW r
     WHERE r.attraction_id = a.attraction_id)                    AS avg_rating,
    (SELECT COUNT(DISTINCT bt.booking_id)
     FROM TICKET t
     JOIN BOOKINGTICKET bt ON t.ticket_id = bt.ticket_id
     WHERE t.attraction_id = a.attraction_id)                    AS total_bookings
FROM ATTRACTION a
WHERE (SELECT AVG(r2.rating) FROM REVIEW r2
       WHERE r2.attraction_id = a.attraction_id) >= 4.0
ORDER BY avg_rating DESC, total_bookings DESC;
```

#### Efficiency Analysis

| | Version A (JOINs) | Version B (Correlated Subqueries) |
|---|---|---|
| **Strategy** | Single multi-table join processed by the optimizer in one pass | Three correlated subqueries, each executed once per row in ATTRACTION |
| **Scans** | Each table scanned once | REVIEW scanned N times (filter) + N times (display); BOOKINGTICKET scanned N times |
| **Winner** | ✅ **Version A** | ❌ Less efficient for large tables |

**Why Version A is better:** The query optimizer can choose hash joins or merge joins and compute aggregation once via `GROUP BY`. Version B executes up to 3N subqueries for N attractions, making it exponentially slower as the attraction count grows.

*[Run this query in pgAdmin and attach a screenshot of the execution and up to 5 result rows]*

---

### Query 2 — Customers Who Spent Above the Monthly Average

**Description:** מצא את כל הלקוחות שסכום ההזמנה שלהם גבוה מהממוצע של החודש שבו ביצעו את ההזמנה. הצג שם, מדינה, תאריך מפורק, סכום, סטטוס ותשלום.

Identifies high-value customers relative to the average booking amount within their booking month. This is useful for the **Loyalty & Marketing** module to target seasonal high-spenders.

#### Version A — Derived Table (more efficient)

Pre-computes the monthly average **once** in a derived table, then joins.

```sql
SELECT
    c.first_name || ' ' || c.last_name        AS full_name,
    c.country,
    c.email,
    EXTRACT(DAY   FROM b.booking_date)        AS booking_day,
    EXTRACT(MONTH FROM b.booking_date)        AS booking_month,
    EXTRACT(YEAR  FROM b.booking_date)        AS booking_year,
    b.total_price,
    ROUND(ma.avg_monthly_price::numeric, 2)   AS month_avg,
    b.booking_status,
    p.amount                                  AS payment_amount
FROM CUSTOMER c
JOIN BOOKING b ON c.customer_id = b.customer_id
JOIN PAYMENT p ON b.payment_id  = p.payment_id
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
```

#### Version B — Correlated Subquery (less efficient)

Recalculates the monthly average for **every row** individually.

```sql
SELECT
    c.first_name || ' ' || c.last_name        AS full_name,
    c.country,
    c.email,
    EXTRACT(DAY   FROM b.booking_date)        AS booking_day,
    EXTRACT(MONTH FROM b.booking_date)        AS booking_month,
    EXTRACT(YEAR  FROM b.booking_date)        AS booking_year,
    b.total_price,
    (SELECT ROUND(AVG(b3.total_price)::numeric, 2)
     FROM BOOKING b3
     WHERE EXTRACT(MONTH FROM b3.booking_date) = EXTRACT(MONTH FROM b.booking_date)
       AND EXTRACT(YEAR  FROM b3.booking_date) = EXTRACT(YEAR  FROM b.booking_date)
    )                                         AS month_avg,
    b.booking_status,
    p.amount                                  AS payment_amount
FROM CUSTOMER c
JOIN BOOKING b ON c.customer_id = b.customer_id
JOIN PAYMENT p ON b.payment_id  = p.payment_id
WHERE b.total_price > (
    SELECT AVG(b2.total_price)
    FROM BOOKING b2
    WHERE EXTRACT(MONTH FROM b2.booking_date) = EXTRACT(MONTH FROM b.booking_date)
      AND EXTRACT(YEAR  FROM b2.booking_date) = EXTRACT(YEAR  FROM b.booking_date)
)
ORDER BY b.total_price DESC;
```

#### Efficiency Analysis

| | Version A (Derived Table) | Version B (Correlated Subquery) |
|---|---|---|
| **BOOKING scans** | 2 total (one for derived table, one for main query) | Up to 2N + 1 (N = number of bookings) |
| **Winner** | ✅ **Version A** | ❌ Less efficient |

**Why Version A is better:** The derived table aggregates all monthly averages in a single pass. Version B re-scans the BOOKING table for every row in the outer query: once in the `WHERE` clause to filter, and again in the `SELECT` clause to display the average — for 10,000 bookings that is ~20,001 scans vs just 2 in Version A.

*[Run this query in pgAdmin and attach a screenshot of the execution and up to 5 result rows]*

---

### Query 3 — Monthly Revenue Above the Overall Monthly Average

**Description:** הצג ניתוח הכנסות חודשי — מצא את החודשים שבהם ההכנסה הכוללת גבוהה מהממוצע החודשי, כולל מספר הזמנות ומחיר ממוצע.

Groups bookings by year and month, computes total revenue per month, and returns only the months that exceed the overall average monthly revenue. Used on the **Financial Reports** screen to identify peak months for capacity and staffing decisions.

#### Version A — HAVING with Nested Subquery

```sql
SELECT
    EXTRACT(YEAR  FROM b.booking_date) AS year,
    EXTRACT(MONTH FROM b.booking_date) AS month,
    COUNT(*)                           AS num_bookings,
    ROUND(SUM(b.total_price)::numeric, 2) AS total_revenue,
    ROUND(AVG(b.total_price)::numeric, 2) AS avg_booking_price
FROM BOOKING b
GROUP BY EXTRACT(YEAR  FROM b.booking_date),
         EXTRACT(MONTH FROM b.booking_date)
HAVING SUM(b.total_price) > (
    SELECT AVG(monthly_total)
    FROM (
        SELECT SUM(total_price) AS monthly_total
        FROM BOOKING
        GROUP BY EXTRACT(YEAR  FROM booking_date),
                 EXTRACT(MONTH FROM booking_date)
    ) AS monthly_totals
)
ORDER BY year, month;
```

#### Version B — CTE (more efficient)

```sql
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
    ROUND(mr.total_revenue::numeric,    2) AS total_revenue,
    ROUND(mr.avg_booking_price::numeric, 2) AS avg_booking_price
FROM monthly_revenue mr
CROSS JOIN avg_monthly am
WHERE mr.total_revenue > am.avg_rev
ORDER BY mr.year, mr.month;
```

#### Efficiency Analysis

| | Version A (HAVING + subquery) | Version B (CTE) |
|---|---|---|
| **GROUP BY passes** | 2 — once in the main query, once inside the HAVING subquery | 1 — the CTE `monthly_revenue` is computed once and reused |
| **Winner** | ❌ Less efficient | ✅ **Version B** |

**Why Version B is better:** The CTE materialises the grouped monthly data once and references it twice (for the result set and for the average). Version A computes the GROUP BY aggregation twice — once in the outer query and once inside the HAVING subquery — doubling I/O on large datasets.

*[Run this query in pgAdmin and attach a screenshot of the execution and up to 5 result rows]*

---

### Query 4 — Attractions With No Bookings

**Description:** מצא את כל האטרקציות שאין להן אף הזמנה (דרך שרשרת כרטיס→הזמנת_כרטיס). הצג שם אטרקציה, קטגוריה, מיקום, מחיר, ושעות פתיחה.

Finds all attractions that have never been booked (through the TICKET → BOOKINGTICKET chain). Used on the **Attraction Management** screen to flag attractions that need promotional attention or pricing adjustments.

#### Version A — LEFT JOIN + IS NULL (more efficient)

```sql
SELECT
    a.attraction_id,
    a.name         AS attraction_name,
    a.category,
    a.location,
    a.price,
    a.opening_hours
FROM ATTRACTION a
LEFT JOIN TICKET       t  ON a.attraction_id = t.attraction_id
LEFT JOIN BOOKINGTICKET bt ON t.ticket_id    = bt.ticket_id
WHERE bt.booking_id IS NULL
ORDER BY a.category, a.price DESC;
```

#### Version B — NOT IN with Nested Subqueries (less efficient)

```sql
SELECT
    a.attraction_id,
    a.name         AS attraction_name,
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
```

#### Efficiency Analysis

| | Version A (LEFT JOIN + IS NULL) | Version B (NOT IN nested subqueries) |
|---|---|---|
| **Strategy** | Anti-join: optimizer converts LEFT JOIN + IS NULL into a single-pass hash anti-join | Full materialisation of each subquery level before filtering begins |
| **NULL safety** | Safe by design | `NOT IN` returns UNKNOWN if any subquery value is NULL, potentially returning zero rows |
| **Short-circuit** | Stops on first match | Must compare against every value in the subquery result list |
| **Winner** | ✅ **Version A** | ❌ Less efficient |

**Why Version A is better:** PostgreSQL recognises the LEFT JOIN + IS NULL pattern as an anti-join and executes it in a single pass. Version B forces full materialisation of the BOOKINGTICKET and TICKET subqueries, incurring additional memory and I/O cost, and carries a correctness risk if any `attraction_id` in TICKET is NULL.

*[Run this query in pgAdmin and attach a screenshot of the execution and up to 5 result rows]*

---

### Query 5 — Full Customer Booking History

**Description:** הצג את היסטוריית ההזמנות המלאה של הלקוחות, כולל פרטי הכרטיסים, שם האטרקציה, ותאריך ההזמנה מפורק ליום, חודש ושנה.

Returns the complete booking trail for every customer, including attraction name, ticket type, quantity, per-line total, and the booking date decomposed into day / month / year. Used on the **Customer Service** screen to give support staff a full view of a customer's activity.

```sql
SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    c.country,
    a.name                             AS attraction_name,
    a.category,
    t.ticket_type,
    bt.quantity,
    t.price                            AS ticket_price,
    bt.quantity * t.price              AS line_total,
    EXTRACT(DAY   FROM b.booking_date) AS booking_day,
    EXTRACT(MONTH FROM b.booking_date) AS booking_month,
    EXTRACT(YEAR  FROM b.booking_date) AS booking_year,
    b.booking_status,
    p.amount                           AS payment_amount
FROM CUSTOMER c
JOIN BOOKING      b  ON c.customer_id  = b.customer_id
JOIN PAYMENT      p  ON b.payment_id   = p.payment_id
JOIN BOOKINGTICKET bt ON b.booking_id  = bt.booking_id
JOIN TICKET       t  ON bt.ticket_id   = t.ticket_id
JOIN ATTRACTION   a  ON t.attraction_id = a.attraction_id
ORDER BY b.booking_date DESC, c.last_name;
```

*[Run this query in pgAdmin and attach a screenshot of the execution and up to 5 result rows]*

---

### Query 6 — Ticket Availability Analysis by Month and Category

**Description:** ניתוח זמינות כרטיסים לפי חודש תוקף וקטגוריית אטרקציה, כולל סה"כ כרטיסים זמינים, מחיר ממוצע, ומספר סוגי כרטיסים.

Summarises the available ticket inventory grouped by attraction category and validity month/year, showing total available quantity, average price, and price range. Used on the **Ticket Management / Inventory** screen for seasonal stock planning.

```sql
SELECT
    a.category,
    EXTRACT(MONTH FROM t.valid_date) AS valid_month,
    EXTRACT(YEAR  FROM t.valid_date) AS valid_year,
    COUNT(DISTINCT t.ticket_id)      AS num_ticket_types,
    SUM(t.available_quantity)        AS total_available,
    ROUND(AVG(t.price)::numeric, 2)  AS avg_ticket_price,
    ROUND(MIN(t.price)::numeric, 2)  AS min_price,
    ROUND(MAX(t.price)::numeric, 2)  AS max_price
FROM TICKET t
JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
GROUP BY a.category,
         EXTRACT(MONTH FROM t.valid_date),
         EXTRACT(YEAR  FROM t.valid_date)
HAVING SUM(t.available_quantity) > 0
ORDER BY valid_year, valid_month, a.category;
```

*[Run this query in pgAdmin and attach a screenshot of the execution and up to 5 result rows]*

---

### Query 7 — Revenue per Attraction Category per Quarter

**Description:** הכנסות לפי קטגוריית אטרקציה לפי רבעון — מצא את הרבעון הרווחי ביותר לכל קטגוריה, כולל מספר הזמנות וממוצע הכנסה להזמנה.

Breaks down total revenue, booking count, and average revenue per booking by attraction category and calendar quarter. Used on the **Executive Dashboard** for strategic financial reporting.

```sql
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
```

*[Run this query in pgAdmin and attach a screenshot of the execution and up to 5 result rows]*

---

### Query 8 — Customers Who Reviewed Attractions They Booked

**Description:** מצא לקוחות שגם הזמינו וגם כתבו ביקורת על אטרקציה. הצג פרטי הלקוח, דירוג, תאריך הביקורת מפורק, והמחיר ששילם.

Cross-references the booking and review tables to find customers who both booked and reviewed the same attraction. Shows the customer's full details, rating, review date broken down into day / month / year, and the booking amount. Used on the **Customer Engagement** screen to measure feedback quality.

```sql
SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    c.country,
    a.name                             AS attraction_name,
    a.category,
    r.rating,
    r.comment,
    EXTRACT(DAY   FROM r.review_date)  AS review_day,
    EXTRACT(MONTH FROM r.review_date)  AS review_month,
    EXTRACT(YEAR  FROM r.review_date)  AS review_year,
    b.total_price,
    b.booking_status
FROM CUSTOMER c
JOIN REVIEW        r  ON c.customer_id  = r.customer_id
JOIN ATTRACTION    a  ON r.attraction_id = a.attraction_id
JOIN BOOKING       b  ON c.customer_id  = b.customer_id
JOIN BOOKINGTICKET bt ON b.booking_id   = bt.booking_id
JOIN TICKET        t  ON bt.ticket_id   = t.ticket_id
                      AND t.attraction_id = a.attraction_id
ORDER BY r.rating DESC, r.review_date DESC;
```

*[Run this query in pgAdmin and attach a screenshot of the execution and up to 5 result rows]*

---

## DELETE Queries

### DELETE 1 — Remove Expired Tickets Not Linked to Confirmed Bookings

**Description:** מחק כרטיסים שתאריך התוקף שלהם עבר ושלא שייכים להזמנה פעילה.

Cleans up stale ticket records by removing tickets whose `valid_date` is in the past and that are not referenced by any `Confirmed` booking. The deletion is done in two steps to respect the foreign key from `BOOKINGTICKET` to `TICKET`.

Used on the **Ticket Management** screen during periodic data maintenance.

**State before deletion:**
```sql
SELECT t.ticket_id, t.valid_date, a.name AS attraction
FROM TICKET t
JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
WHERE t.valid_date < CURRENT_DATE
ORDER BY t.valid_date
LIMIT 10;
```

*[Attach screenshot of the table state before deletion]*

**Deletion query:**
```sql
-- Step 1: Remove BookingTicket references for expired, unconfirmed tickets
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
```

**Verify after deletion:**
```sql
SELECT COUNT(*) AS remaining_expired
FROM TICKET
WHERE valid_date < CURRENT_DATE;
-- Expected: 0
```

*[Attach screenshot of the table state after deletion]*

---

### DELETE 2 — Remove Reviews Older Than One Year

**Description:** מחק ביקורות שנכתבו לפני יותר משנה — ניקוי ביקורות ישנות שכבר לא רלוונטיות.

Removes all review records whose `review_date` is more than 1 year in the past. Old reviews are less relevant for current attraction quality assessments and add unnecessary noise to rating calculations. Used on the **Review Management** screen.

**State before deletion:**
```sql
SELECT r.review_id, r.review_date, r.rating,
       c.first_name || ' ' || c.last_name AS reviewer,
       a.name AS attraction
FROM REVIEW r
JOIN CUSTOMER   c ON r.customer_id  = c.customer_id
JOIN ATTRACTION a ON r.attraction_id = a.attraction_id
WHERE r.review_date < CURRENT_DATE - INTERVAL '1 year'
ORDER BY r.review_date
LIMIT 10;
```

*[Attach screenshot of the table state before deletion]*

**Deletion query:**
```sql
DELETE FROM REVIEW
WHERE review_date < CURRENT_DATE - INTERVAL '1 year';
```

**Verify after deletion:**
```sql
SELECT COUNT(*) AS old_reviews_remaining
FROM REVIEW
WHERE review_date < CURRENT_DATE - INTERVAL '1 year';
-- Expected: 0
```

*[Attach screenshot of the table state after deletion]*

---

### DELETE 3 — Remove Cancelled Bookings and Their Booking Tickets

**Description:** מחק הזמנות שבוטלו (סטטוס 'Cancelled') יחד עם כרטיסי ההזמנה המשויכים אליהם.

Purges all cancelled bookings and their associated `BOOKINGTICKET` rows. Cancelled bookings are no longer operationally relevant and their removal keeps the booking table lean for reporting queries. Used on the **Booking Management** screen.

**State before deletion:**
```sql
SELECT b.booking_id, b.booking_status, b.booking_date,
       c.first_name || ' ' || c.last_name AS customer
FROM BOOKING b
JOIN CUSTOMER c ON b.customer_id = c.customer_id
WHERE b.booking_status = 'Cancelled'
ORDER BY b.booking_date DESC
LIMIT 10;
```

*[Attach screenshot of the table state before deletion]*

**Deletion query:**
```sql
-- Step 1: Delete the child records in BOOKINGTICKET first (FK constraint)
DELETE FROM BOOKINGTICKET
WHERE booking_id IN (
    SELECT booking_id FROM BOOKING
    WHERE booking_status = 'Cancelled'
);

-- Step 2: Delete the cancelled BOOKING rows
DELETE FROM BOOKING
WHERE booking_status = 'Cancelled';
```

**Verify after deletion:**
```sql
SELECT COUNT(*) AS cancelled_remaining
FROM BOOKING
WHERE booking_status = 'Cancelled';
-- Expected: 0
```

*[Attach screenshot of the table state after deletion]*

---

## UPDATE Queries

### UPDATE 1 — Increase Ticket Prices by 10% for High-Demand Attractions

**Description:** העלה את מחיר הכרטיסים ב-10% לאטרקציות שיש להן יותר מ-2 הזמנות (ביקוש גבוה).

Applies a 10% price increase to all tickets whose underlying attraction has been booked more than twice (high demand). This is a dynamic pricing rule used on the **Pricing Management** screen.

**State before update:**
```sql
SELECT t.ticket_id, a.name AS attraction, t.ticket_type, t.price
FROM TICKET t
JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
WHERE t.ticket_id IN (
    SELECT bt.ticket_id
    FROM BOOKINGTICKET bt
    GROUP BY bt.ticket_id
    HAVING COUNT(bt.booking_id) >= 2
)
ORDER BY t.price DESC
LIMIT 10;
```

*[Attach screenshot of the table state before update]*

**Update query:**
```sql
UPDATE TICKET
SET price = ROUND((price * 1.10)::numeric, 2)
WHERE ticket_id IN (
    SELECT bt.ticket_id
    FROM BOOKINGTICKET bt
    GROUP BY bt.ticket_id
    HAVING COUNT(bt.booking_id) >= 2
);
```

**Verify after update:**
```sql
SELECT t.ticket_id, a.name AS attraction, t.ticket_type, t.price
FROM TICKET t
JOIN ATTRACTION a ON t.attraction_id = a.attraction_id
WHERE t.ticket_id IN (
    SELECT bt.ticket_id
    FROM BOOKINGTICKET bt
    GROUP BY bt.ticket_id
    HAVING COUNT(bt.booking_id) >= 2
)
ORDER BY t.price DESC
LIMIT 10;
```

*[Attach screenshot of the table state after update]*

---

### UPDATE 2 — Auto-Confirm Recent Pending Bookings

**Description:** עדכן את סטטוס ההזמנה ל-'Confirmed' עבור הזמנות מ-30 הימים האחרונים שעדיין בסטטוס 'Pending'.

Automatically confirms bookings that were placed within the last 30 days and are still in `Pending` status. This simulates an automated nightly job used on the **Booking Management** screen to reduce manual processing.

**State before update:**
```sql
SELECT b.booking_id, b.booking_date, b.booking_status,
       c.first_name || ' ' || c.last_name AS customer
FROM BOOKING b
JOIN CUSTOMER c ON b.customer_id = c.customer_id
WHERE b.booking_status = 'Pending'
  AND b.booking_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY b.booking_date DESC
LIMIT 10;
```

*[Attach screenshot of the table state before update]*

**Update query:**
```sql
UPDATE BOOKING
SET booking_status = 'Confirmed'
WHERE booking_status = 'Pending'
  AND booking_date >= CURRENT_DATE - INTERVAL '30 days';
```

**Verify after update:**
```sql
SELECT b.booking_id, b.booking_date, b.booking_status,
       c.first_name || ' ' || c.last_name AS customer
FROM BOOKING b
JOIN CUSTOMER c ON b.customer_id = c.customer_id
WHERE b.booking_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY b.booking_date DESC
LIMIT 10;
```

*[Attach screenshot of the table state after update]*

---

### UPDATE 3 — Apply a 15% Discount to All Museum Category Attractions

**Description:** החל הנחה של 15% על כל האטרקציות בקטגוריית 'Museum'. מסך ניהול אטרקציות — מבצעים וקידום מכירות.

Reduces the base price of every attraction in the `Museum` category by 15% to simulate a seasonal promotional campaign. Used on the **Attraction Management / Promotions** screen.

**State before update:**
```sql
SELECT attraction_id, name, category, price, location
FROM ATTRACTION
WHERE category = 'Museum'
ORDER BY attraction_id
LIMIT 10;
```

*[Attach screenshot of the table state before update]*

**Update query:**
```sql
UPDATE ATTRACTION
SET price = ROUND((price * 0.85)::numeric, 2)
WHERE category = 'Museum';
```

**Verify after update:**
```sql
SELECT attraction_id, name, category, price, location
FROM ATTRACTION
WHERE category = 'Museum'
ORDER BY attraction_id
LIMIT 10;
```

*[Attach screenshot of the table state after update]*

---

## Constraints

Three new constraints were added using `ALTER TABLE` only (no table recreation). Each section below describes the business motivation, the SQL command, and a demonstration that a violating insert is correctly rejected.

---

### Constraint 1 — Booking Date Cannot Be in the Future (`chk_booking_date_not_future`)

**Change description:**  
A booking date records *when* the booking was made. It cannot logically be a future date. Without this constraint, a data-entry error (e.g., typing `2030` instead of `2026`) would silently corrupt financial reports and booking timelines.

**Business need:**  
Guarantees that all booking-date-based aggregations (monthly revenue, seasonal analysis) reflect real past events. Critical for the **Booking Management** and **Financial Reports** screens.

**SQL — Add the constraint:**
```sql
ALTER TABLE BOOKING
ADD CONSTRAINT chk_booking_date_not_future
CHECK (booking_date <= CURRENT_DATE);
```

**Test — Insert a booking with a future date (must fail):**
```sql
-- Setup: a payment is required before the booking (FK)
INSERT INTO PAYMENT (payment_id, booking_id, amount)
VALUES (99999, 99999, 50.00);

-- Attempt to insert a booking dated in the future
INSERT INTO BOOKING (booking_id, customer_id, booking_date, booking_status, total_price, payment_id)
VALUES (99999, 1, '2030-01-01', 'CONFIRMED', 50.00, 99999);
```

**Expected error:**
```
ERROR:  new row for relation "booking" violates check constraint "chk_booking_date_not_future"
```

*[Attach screenshot of the error message from pgAdmin]*

```sql
-- Cleanup the payment since the booking insert failed
DELETE FROM PAYMENT WHERE payment_id = 99999;
```

---

### Constraint 2 — Ticket Available Quantity Cannot Exceed 1000 (`chk_ticket_max_quantity`)

**Change description:**  
No single ticket type should list more than 1,000 available seats. This prevents obvious typos (e.g., entering `10000` instead of `100`) and enforces a realistic capacity ceiling.

**Business need:**  
Protects inventory integrity on the **Ticket Management** screen and prevents inflated availability figures from misleading customers or distorting demand analytics.

**SQL — Add the constraint:**
```sql
ALTER TABLE TICKET
ADD CONSTRAINT chk_ticket_max_quantity
CHECK (available_quantity <= 1000);
```

**Test — Insert a ticket with quantity > 1000 (must fail):**
```sql
INSERT INTO TICKET (ticket_id, attraction_id, price, valid_date, ticket_type, available_quantity)
VALUES (99999, 1, 50.00, '2027-01-01', 'Adult', 5000);
```

**Expected error:**
```
ERROR:  new row for relation "ticket" violates check constraint "chk_ticket_max_quantity"
```

*[Attach screenshot of the error message from pgAdmin]*

---

### Constraint 3 — Attraction Price Cannot Exceed 500 (`chk_attraction_max_price`)

**Change description:**  
Attraction base prices are expected to fall within a sensible range. A price above 500 is almost certainly a data-entry error (e.g., an extra zero) that would affect customer-facing pricing, revenue calculations, and promotional discount logic.

**Business need:**  
Maintains pricing consistency on the **Attraction Booking** screen and ensures that the 15% discount UPDATE (see above) cannot produce results that look unrealistic.

**SQL — Add the constraint:**
```sql
ALTER TABLE ATTRACTION
ADD CONSTRAINT chk_attraction_max_price
CHECK (price <= 500);
```

**Test — Insert an attraction with price > 500 (must fail):**
```sql
INSERT INTO ATTRACTION (attraction_id, name, location, description, opening_hours, category, price)
VALUES (99999, 'LuxuryTour', 'TelAviv', 'Test description', '09:00:00', 'Museum', 999.99);
```

**Expected error:**
```
ERROR:  new row for relation "attraction" violates check constraint "chk_attraction_max_price"
```

*[Attach screenshot of the error message from pgAdmin]*

---

## Rollback & Commit Demonstrations

### Demonstration 1 — ROLLBACK

**Scenario:** Increase all Museum attraction prices by 25%, observe the change inside the transaction, then roll back and verify the database returns to its original state.

**Step 1 — Show original state (before any changes):**
```sql
SELECT attraction_id, name, category, price, location
FROM ATTRACTION
WHERE category = 'Museum'
ORDER BY attraction_id
LIMIT 10;
```
*[Attach screenshot — original prices]*

**Step 2 — Begin transaction:**
```sql
BEGIN;
```

**Step 3 — Apply the update:**
```sql
UPDATE ATTRACTION
SET price = ROUND((price * 1.25)::numeric, 2)
WHERE category = 'Museum';
```

**Step 4 — Show state after update (still inside transaction):**
```sql
SELECT attraction_id, name, category, price, location
FROM ATTRACTION
WHERE category = 'Museum'
ORDER BY attraction_id
LIMIT 10;
```
*[Attach screenshot — prices are 25% higher]*

**Step 5 — Rollback:**
```sql
ROLLBACK;
```

**Step 6 — Verify original state is restored:**
```sql
SELECT attraction_id, name, category, price, location
FROM ATTRACTION
WHERE category = 'Museum'
ORDER BY attraction_id
LIMIT 10;
```
*[Attach screenshot — prices match Step 1, confirming ROLLBACK succeeded]*

---

### Demonstration 2 — COMMIT

**Scenario:** Confirm all recent Pending bookings, observe the change, commit, and verify the changes persist after the transaction closes.

**Step 1 — Show original state (before any changes):**
```sql
SELECT booking_id, customer_id, booking_date, booking_status, total_price
FROM BOOKING
WHERE booking_status = 'Pending'
ORDER BY booking_id
LIMIT 10;
```
*[Attach screenshot — bookings are still 'Pending']*

**Step 2 — Begin transaction:**
```sql
BEGIN;
```

**Step 3 — Apply the update:**
```sql
UPDATE BOOKING
SET booking_status = 'Confirmed'
WHERE booking_status = 'Pending'
  AND booking_date >= CURRENT_DATE - INTERVAL '60 days';
```

**Step 4 — Show state after update (still inside transaction):**
```sql
SELECT booking_id, customer_id, booking_date, booking_status, total_price
FROM BOOKING
WHERE booking_date >= CURRENT_DATE - INTERVAL '60 days'
ORDER BY booking_id
LIMIT 10;
```
*[Attach screenshot — relevant bookings now show 'Confirmed']*

**Step 5 — Commit:**
```sql
COMMIT;
```

**Step 6 — Verify changes persisted after commit:**
```sql
SELECT booking_id, customer_id, booking_date, booking_status, total_price
FROM BOOKING
WHERE booking_date >= CURRENT_DATE - INTERVAL '60 days'
ORDER BY booking_id
LIMIT 10;
```
*[Attach screenshot — result is identical to Step 4, confirming COMMIT persisted the changes]*

---

## Indexes

Three new indexes were added to improve the performance of the most frequent query patterns. For each index we ran `EXPLAIN ANALYZE` **before** and **after** creation to measure the effect.

---

### Index 1 — `idx_customer_country` on `CUSTOMER(country)`

**Motivation:**  
Country-based filtering and grouping is used in multiple business intelligence queries (e.g., "which countries generate the most bookings?", "filter customers by region for a marketing campaign"). Without an index, every such query performs a full sequential scan across 20,000+ customer rows.

**Benefit:**  
Speeds up `WHERE country IN (...)` filters, `GROUP BY country` aggregations, and any join that includes a country predicate. Directly improves the **Customer Management** and **Analytics Dashboard** screens.

**Before — measure performance:**
```sql
EXPLAIN ANALYZE
SELECT
    c.country,
    COUNT(*)                              AS num_customers,
    COUNT(DISTINCT b.booking_id)          AS num_bookings,
    ROUND(AVG(b.total_price)::numeric, 2) AS avg_spending
FROM CUSTOMER c
LEFT JOIN BOOKING b ON c.customer_id = b.customer_id
WHERE c.country IN ('Israel', 'USA', 'France')
GROUP BY c.country
ORDER BY num_bookings DESC;
```

*[Attach EXPLAIN ANALYZE output — before]*  
Expected plan: **Seq Scan** on CUSTOMER (all 20,000+ rows read, then filtered).

**Create the index:**
```sql
CREATE INDEX idx_customer_country ON CUSTOMER(country);
```

**After — measure performance again (same query):**

*[Attach EXPLAIN ANALYZE output — after]*  
Expected plan: **Bitmap Index Scan** on `idx_customer_country`, reading only the pages for the three matching countries.

**Analysis:**  
Before the index, PostgreSQL must read every customer row to check the country. After, it navigates the B-tree directly to matching entries. If the three countries represent ~30% of rows the speedup is ~2–3×; for <10% it can be 5–10×, because the heap pages for non-matching countries are never touched.

---

### Index 2 — `idx_ticket_valid_date` on `TICKET(valid_date)`

**Motivation:**  
Ticket validity date is filtered in a range condition by multiple queries and by the DELETE that cleans up expired tickets. Without an index, every date-range query must scan the entire ticket table.

**Benefit:**  
Enables B-tree range navigation (`BETWEEN`, `<`, `>=`) so only matching rows are read. Also eliminates the Sort step for queries that already `ORDER BY valid_date`, because the index is sorted. Critical for the **Ticket Management** screen and the expired-ticket cleanup job.

**Before — measure performance:**
```sql
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
```

*[Attach EXPLAIN ANALYZE output — before]*  
Expected plan: **Seq Scan** on TICKET + separate Sort node.

**Create the index:**
```sql
CREATE INDEX idx_ticket_valid_date ON TICKET(valid_date);
```

**After — measure performance again (same query):**

*[Attach EXPLAIN ANALYZE output — after]*  
Expected plan: **Index Scan** on `idx_ticket_valid_date` (range navigation, no separate Sort).

**Analysis:**  
The index provides a dual benefit: it eliminates both the full table scan and the sort operation for range queries ordered by date. For the DELETE of expired tickets (`valid_date < CURRENT_DATE`) it allows PostgreSQL to pinpoint target rows without touching any future-dated ticket pages.

---

### Index 3 — `idx_booking_status` on `BOOKING(booking_status)`

**Motivation:**  
Booking status is the most common filter in booking-management operations: "show all cancelled bookings", "confirm pending bookings", "delete cancelled bookings". Without an index, each filter requires a full sequential scan of the entire booking table.

**Benefit:**  
Directly accelerates the DELETE query that removes cancelled bookings and the UPDATE query that confirms pending ones, both of which are defined in this stage. Also speeds up the **Booking Management** screen's status-filter views.

**Before — measure performance:**
```sql
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
JOIN PAYMENT  p ON b.payment_id  = p.payment_id
WHERE b.booking_status = 'CANCELLED'
ORDER BY b.booking_date DESC;
```

*[Attach EXPLAIN ANALYZE output — before]*  
Expected plan: **Seq Scan** on BOOKING with a row filter on booking_status.

**Create the index:**
```sql
CREATE INDEX idx_booking_status ON BOOKING(booking_status);
```

**After — measure performance again (same query):**

*[Attach EXPLAIN ANALYZE output — after]*  
Expected plan: **Index Scan** or **Bitmap Index Scan** on `idx_booking_status`.

**Analysis:**  
The efficiency gain depends on the cardinality of each status value. If `CANCELLED` represents ~20% of bookings, the index eliminates ~80% of the heap pages that would otherwise be read. As the booking table grows over time, the relative gain increases because the proportion of irrelevant rows that must be skipped grows. For the DELETE of cancelled bookings, the index is especially important: it allows the database engine to identify and lock only the target rows without scanning unrelated records.

---
