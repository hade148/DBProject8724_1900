# AttraTicket — Attraction Booking System

> **PostgreSQL · Docker · Python · pgAdmin**

A fully normalized relational database for managing attractions, customers, ticketing, bookings, payments, and reviews.

---

## Project Information

| Field | Value |
|---|---|
| **System Name** | AttraTicket |
| **Module** | Attraction Booking & Ticketing |
| **Prepared by** | Hadasa Esther Elbaz, Tamar Rozen |
| **Database** | PostgreSQL 16 |
| **Dev Environment** | Docker Compose + pgAdmin 4 |

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack & Prerequisites](#tech-stack--prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Stage 1: Design and Build the Database](#stage-1-design-and-build-the-database)
  - [Introduction](#introduction)
  - [AI-Generated Prototype](#ai-generated-prototype)
  - [Logical Design](#logical-design)
  - [Schema & Data Dictionary](#schema--data-dictionary)
  - [SQL Scripts](#sql-scripts)
  - [Data Population](#data-population)
  - [Backup & Recovery](#backup--recovery)

---

## Overview

**AttraTicket** is a booking and ticket management system for tourist attractions.  
It connects customers, attractions, ticket inventory, bookings, payments, and reviews in one normalized relational schema.

**Purpose of the database:**
- **Manage Customers** — registration details, contact information, and identity records.
- **Manage Attractions** — location, category, opening hours, descriptions, and base pricing.
- **Manage Ticketing** — ticket type, validity date, available quantity, and attraction linkage.
- **Manage Transactions** — booking records, payment linkage, and booking status.
- **Collect Feedback** — customer ratings and comments per attraction.
- **Enable Reporting** — SQL-based analysis over bookings, reviews, and attraction demand.

**Potential use cases:**
- **Customers** can book attractions, purchase tickets, and submit reviews.
- **Business Managers** can analyze popular attractions and customer satisfaction.
- **Support Teams** can track booking/payment relationships and resolve issues quickly.

---

## Tech Stack & Prerequisites

| Tool | Purpose | Required version |
|---|---|---|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Run PostgreSQL + pgAdmin containers | 24+ |
| [Docker Compose](https://docs.docker.com/compose/) | Container orchestration | v2+ |
| [Python 3](https://www.python.org/) | Programmatic data seeding | 3.10+ |
| [psycopg2](https://pypi.org/project/psycopg2/) | Python ↔ PostgreSQL driver | 2.9+ |
| [python-dotenv](https://pypi.org/project/python-dotenv/) | Load `.env` secrets | 1.0+ |
| [pgAdmin 4](https://www.pgadmin.org/) | GUI database management | bundled via Docker |

---

## Project Structure

```
DBProject8724_1900/
├── docker-compose.yml          # PostgreSQL + pgAdmin services
├── .gitignore
├── README.md
└── phase1/
    ├── ERDandDSDfiles/
    │   ├── ERD.png             # Entity-Relationship Diagram
    │   ├── DSD.png             # Data Structure Diagram
    │   └── DSD2.png
    ├── SQLscripts/
    │   ├── 01-dropTables.sql   # Drop all tables (dependency-safe order)
    │   ├── 02-createTables.sql # Create all tables with constraints
    │   ├── 03-insertTables.sql # Sample INSERT statements
    │   └── 04-selectAll.sql    # SELECT * + COUNT(*) for every table
    ├── importData/             # Production CSV files (20 000 rows each)
    │   ├── customer.csv
    │   ├── attraction.csv
    │   ├── ticket.csv
    │   ├── booking.csv
    │   ├── payment.csv
    │   ├── review.csv
    │   └── bookingticket.csv
    ├── mockData/               # Mockaroo sample CSV files (500 rows each)
    │   └── *_MOCK_DATA.csv
    ├── programingData/
    │   └── insert_data.py      # Python seeder (direct DB insert)
    ├── googleAIstudio/         # UI prototype screenshots
    └── Backup/
        └── backup14_04_2026    # Full PostgreSQL backup
```

---

## Quick Start

### 1. Clone and configure environment variables

Create a `.env` file in the project root (it is git-ignored):

```env
DB_USER_SECRET=attraticket_user
DB_PASSWORD_SECRET=StrongPassword123
DB_NAME_SECRET=attraticket_db
DB_PORT_SECRET=5432
PGADMIN_EMAIL=admin@attraticket.com
PGADMIN_PASSWORD=AdminPass123
```

### 2. Start the containers

```bash
docker compose up -d
```

| Service | URL |
|---|---|
| PostgreSQL | `localhost:5432` |
| pgAdmin 4 | [http://localhost:8080](http://localhost:8080) |

### 3. Initialize the schema

Connect to the database via pgAdmin or `psql` and run the scripts in order:

```bash
# Inside the PostgreSQL container
docker exec -it PostgreSQL_DB psql -U attraticket_user -d attraticket_db \
  -f /path/to/phase1/SQLscripts/01-dropTables.sql \
  -f /path/to/phase1/SQLscripts/02-createTables.sql
```

### 4. Seed data

**Option A — Import CSVs via pgAdmin** (20 000 rows per table):  
Use the pgAdmin import dialog on each `phase1/importData/*.csv` file.

**Option B — Python seeder** (configurable row count):

```bash
pip install psycopg2-binary python-dotenv
# Optional: set number of rows and whether to reset existing data
export SEED_ROWS=1000
export RESET_TABLES=false
python phase1/programingData/insert_data.py
```

---

## Stage 1: Design and Build the Database

### Introduction

The **AttraTicket Database** is a booking and ticket management system for attractions.  
It connects customers, attractions, ticket inventory, bookings, payments, and reviews in one normalized relational schema designed to **3NF (Third Normal Form)**.

---

### AI-Generated Prototype

The system was planned using a **Top-Down approach** with UI characterization in Google AI Studio.

**[Live Demo (AI Studio Link)](https://ai.studio/apps/22d49e6f-06a0-43ed-933f-a033e8c625c5)**

<img width="1845" height="789" alt="Screenshot 2026-04-13 225842" src="https://github.com/user-attachments/assets/a3711a36-d6a5-4b26-aca7-46caf8a6759f" />
<img width="1751" height="789" alt="Screenshot 2026-04-13 230115" src="https://github.com/user-attachments/assets/a201985f-9863-4d41-849d-6635a77eb7fb" />
<img width="1729" height="785" alt="Screenshot 2026-04-13 225957" src="https://github.com/user-attachments/assets/5e76834b-3dc5-4299-9342-ad1fefb62e46" />
<img width="1668" height="796" alt="Screenshot 2026-04-13 230142" src="https://github.com/user-attachments/assets/d3a10604-6b76-43fd-aef0-ce5a609cabdb" />

---

### Logical Design

#### ERD (Entity-Relationship Diagram)
![ERD Diagram](./phase1/ERDandDSDfiles/ERD.png)

#### DSD (Data Structure Diagram)
![DSD Diagram](./phase1/ERDandDSDfiles/DSD.png)

---

### Schema & Data Dictionary

The database contains **7 tables**. All integer primary keys are surrogate IDs assigned sequentially.

| Table | Primary Key | Row Count | Description |
|---|---|---|---|
| `CUSTOMER` | `customer_id` | 20 000 | Registered users with contact details |
| `ATTRACTION` | `attraction_id` | 20 000 | Tourist attractions with location and pricing |
| `TICKET` | `ticket_id` | 500 | Ticket types sold per attraction |
| `PAYMENT` | `payment_id` | 20 000 | Payment records linked 1-to-1 with bookings |
| `BOOKING` | `booking_id` | 20 000 | Booking transactions per customer |
| `REVIEW` | `review_id` | 500 | Customer ratings (1–5) and comments |
| `BOOKINGTICKET` | `(booking_id, ticket_id)` | 500 | Junction table: tickets purchased per booking |

#### Key constraints & design notes

- **CUSTOMER.email** — `CHECK (email LIKE '%_@_%._%')` enforces basic email format.
- **BOOKING** — `UNIQUE (customer_id)` currently limits each customer to one booking; this may be intentional for the prototype but would be removed in production.
- **REVIEW** — `UNIQUE (customer_id)` and `UNIQUE (attraction_id)` prevent multiple reviews by the same customer or for the same attraction.
- **TICKET** — `UNIQUE (attraction_id)` means one ticket type per attraction in the current schema.
- Prices stored as `FLOAT`; consider `NUMERIC(10,2)` for financial precision in future phases.

---

### SQL Scripts

| Script | Purpose | Link |
|---|---|---|
| `01-dropTables.sql` | Drop all tables in dependency-safe order | [View](phase1/SQLscripts/01-dropTables.sql) |
| `02-createTables.sql` | Create all tables with PKs, FKs, and CHECK constraints | [View](phase1/SQLscripts/02-createTables.sql) |
| `03-insertTables.sql` | 5 sample rows per table for smoke-testing | [View](phase1/SQLscripts/03-insertTables.sql) |
| `04-selectAll.sql` | `SELECT *` + `COUNT(*)` for every table | [View](phase1/SQLscripts/04-selectAll.sql) |

---

### Data Population

Three methods were used to populate the database:

#### Method 1 — Mockaroo (CSV generation)

[Mockaroo](https://www.mockaroo.com/) was used to generate realistic CSV datasets matching the schema field names and data types.  
For each table we defined exact column names, selected appropriate generators, and exported as **CSV with header** (Windows CRLF) for smooth import into PostgreSQL.

<details>
<summary>Mockaroo field mappings per table</summary>

**ATTRACTION**
- `attraction_id` → Row Number  
- `name` → Product Name  
- `location` → Street Name  
- `description` → Product Description  
- `opening_hours` → Time (12-hour)  
- `category` → Product Category  
- `price` → Product Price

<img width="1282" height="632" alt="attraction" src="https://github.com/user-attachments/assets/f3157410-3879-4921-a2dc-d89b9f81408b" />

**CUSTOMER**
- `customer_id` → Row Number  
- `first_name` / `last_name` → Name generators  
- `email` → Email Address  
- `phone` → Phone (formatted)  
- `password` → Password (mixed chars)  
- `country` → Country

<img width="1796" height="641" alt="customer" src="https://github.com/user-attachments/assets/0eaeba06-1eae-4348-a6aa-8d0c0be348f2" />

**TICKET**
- `ticket_id` → Row Number  
- `attraction_id` → Row Number  
- `price` → Product Price  
- `valid_date` → Datetime (project date range)  
- `ticket_type` → Custom List (general_admission, VIP, student, senior)  
- `available_quantity` → Number (1–100)

<img width="1806" height="577" alt="ticket" src="https://github.com/user-attachments/assets/d7d62a22-a114-47e3-9e9c-f4b7b3944bdc" />

**BOOKING**
- `booking_id` → Row Number  
- `customer_id` → Row Number  
- `booking_date` → Datetime (defined range)  
- `total_price` → Product Price  
- `payment_id` → Row Number

<img width="1389" height="524" alt="booking" src="https://github.com/user-attachments/assets/a2e7cf32-2f92-4765-bae8-a3eafd74b858" />

</details>

#### Method 2 — pgAdmin CSV Import

The CSV files were imported via the pgAdmin import dialog:

<img width="1041" height="375" alt="pgAdmin import dialog" src="https://github.com/user-attachments/assets/96ac8bb0-b8ef-4aa2-8689-a4601fc09bb7" />

After running the import, pgAdmin confirmed the process completed successfully:

<img width="971" height="389" alt="pgAdmin import success" src="https://github.com/user-attachments/assets/ac1b9d4c-b288-4e80-a1da-e487ffdfc5a9" />

**Row count validation:**

```sql
SELECT COUNT(*) FROM CUSTOMER;
```

<img width="183" height="111" alt="SQL COUNT query result" src="https://github.com/user-attachments/assets/f13716d4-8084-40f0-a62c-0859346dbe8c" />

**Result:** `20 000` rows successfully loaded into the `CUSTOMER` table.

#### Method 3 — Python Seeder (`insert_data.py`)

A Python script connects directly to PostgreSQL and inserts randomly generated data without any intermediate CSV step.

**[View `insert_data.py`](phase1/programingData/insert_data.py)**

Key features:
- Reads DB credentials from `.env` (supports `DB_*_SECRET` and `DB_*` fallbacks)
- Row count controlled by `SEED_ROWS` env variable (default: `10`)
- Optional table reset via `RESET_TABLES=true`
- Inserts in FK-safe order and uses `ON CONFLICT DO NOTHING` for idempotency
- Wraps all inserts in a single transaction with rollback on error

<img width="1018" height="447" alt="insert_data.py output" src="https://github.com/user-attachments/assets/e4bcc1e1-9120-4dcc-b9db-28ee4c35f068" />
<img width="1486" height="656" alt="insert_data.py output continued" src="https://github.com/user-attachments/assets/d9410b93-70e0-49f1-bbfb-0cf26d4f1cba" />

---

### Backup & Recovery

A full database backup was created and a restore was verified on a clean instance.

- Backup file named by date: `backup14_04_2026`
- Restore tested on a clean DB instance
- Post-restore validation done with `COUNT(*)` queries

**[Go to Backup Folder](phase1/Backup)**  
**[View Backup File](phase1/Backup/backup14_04_2026)**

**Backup:**

<img width="1050" height="830" alt="pgAdmin backup dialog" src="https://github.com/user-attachments/assets/04c34005-5214-4de4-87d3-7cfa4428a844" />
<img width="870" height="397" alt="pgAdmin backup success" src="https://github.com/user-attachments/assets/3df95fad-846b-4226-9242-d19aac69427c" />

**Restore:**

<img width="1050" height="601" alt="pgAdmin restore dialog" src="https://github.com/user-attachments/assets/364fa4d9-a3a1-4692-b9da-1aa06636da41" />
<img width="565" height="391" alt="pgAdmin restore success" src="https://github.com/user-attachments/assets/cde294f5-97bc-4d23-b1d4-ae58a5db1b7b" />

---
