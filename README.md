# AttraTicket — Attraction Booking System

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white)
![License](https://img.shields.io/badge/License-Academic-lightgrey)

> A relational database project for managing attraction bookings, ticket inventory, payments, and customer reviews — built with PostgreSQL and Docker.

**Prepared by:** Hadasa Esther Elbaz & Tamar Rozen  
**System Name:** AttraTicket  
**Module:** Attraction Booking & Ticketing

---

## Table of Contents

- [Introduction](#introduction)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [AI-Generated Prototype](#ai-generated-prototype)
- [Schema Design](#schema-design)
  - [ERD & DSD Diagrams](#erd--dsd-diagrams)
  - [Table Overview](#table-overview)
- [SQL Scripts](#sql-scripts)
- [Data Population](#data-population)
  - [Method 1 — Mockaroo CSV Generation](#method-1--mockaroo-csv-generation)
  - [Method 2 — pgAdmin CSV Import](#method-2--pgadmin-csv-import)
  - [Method 3 — Python Direct Insert](#method-3--python-direct-insert)
- [Backup & Recovery](#backup--recovery)

---

## Introduction

The **AttraTicket Database** is a booking and ticket management system for tourist attractions.  
It connects customers, attractions, ticket inventory, bookings, payments, and reviews in one normalized relational schema (3NF).

### Purpose

| Goal | Description |
|---|---|
| **Manage Customers** | Registration details, contact information, and identity records |
| **Manage Attractions** | Location, category, opening hours, descriptions, and base pricing |
| **Manage Ticketing** | Ticket type, validity date, available quantity, and attraction linkage |
| **Manage Transactions** | Booking records, payment linkage, and booking status |
| **Collect Feedback** | Customer ratings and comments per attraction |
| **Enable Reporting** | SQL-based analysis over bookings, reviews, and attraction demand |

### Potential Use Cases

- **Customers** — book attractions, purchase tickets, and submit reviews.
- **Business Managers** — analyze popular attractions and customer satisfaction.
- **Support Teams** — track booking/payment relationships and resolve issues quickly.

---

## Quick Start

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (includes Docker Compose)
- [Python 3.10+](https://www.python.org/downloads/) *(optional — only needed for the Python data-seeder)*

### 1. Configure Environment Variables

Create a `.env` file in the project root (it is git-ignored):

```env
# PostgreSQL
DB_USER_SECRET=your_db_user
DB_PASSWORD_SECRET=your_db_password
DB_NAME_SECRET=attraticket
DB_HOST_SECRET=localhost
DB_PORT_SECRET=5432

# pgAdmin
PGADMIN_EMAIL=admin@attraticket.com
PGADMIN_PASSWORD=your_pgadmin_password

# Python seeder (optional)
SEED_ROWS=100
RESET_TABLES=false
```

### 2. Start the Database Stack

```bash
docker compose up -d
```

| Service | URL | Credentials |
|---|---|---|
| PostgreSQL | `localhost:5432` | values from `.env` |
| pgAdmin 4 | http://localhost:8080 | values from `.env` |

### 3. Initialize the Schema

Run the SQL scripts in order inside pgAdmin (or via `psql`):

```bash
# Drop existing tables (if any)
psql -h localhost -U $DB_USER_SECRET -d $DB_NAME_SECRET -f phase1/SQLscripts/01-dropTables.sql

# Create schema
psql -h localhost -U $DB_USER_SECRET -d $DB_NAME_SECRET -f phase1/SQLscripts/02-createTables.sql

# Load sample data
psql -h localhost -U $DB_USER_SECRET -d $DB_NAME_SECRET -f phase1/SQLscripts/03-insertTables.sql
```

### 4. (Optional) Seed Data with Python

```bash
cd phase1/programingData
pip install psycopg2-binary python-dotenv
python insert_data.py
```

---

## Project Structure

```
DBProject8724_1900/
├── docker-compose.yml          # PostgreSQL + pgAdmin stack
├── .env                        # Environment variables (git-ignored)
├── .gitignore
├── README.md
└── phase1/
    ├── SQLscripts/
    │   ├── 01-dropTables.sql   # Drop all tables (safe teardown)
    │   ├── 02-createTables.sql # Create all 7 tables with constraints
    │   ├── 03-insertTables.sql # Sample INSERT statements (5 rows/table)
    │   └── 04-selectAll.sql    # SELECT * + COUNT(*) for all tables
    ├── ERDandDSDfiles/
    │   ├── ERD.png             # Entity-Relationship Diagram
    │   ├── DSD.png             # Data Structure Diagram
    │   └── DSD2.png
    ├── mockData/               # Mockaroo-generated CSV files (raw)
    ├── importData/             # Cleaned CSV files imported via pgAdmin
    ├── programingData/
    │   └── insert_data.py      # Python script for direct DB seeding
    ├── googleAIstudio/         # AI Studio prototype screenshots
    └── Backup/
        └── backup14_04_2026    # Full PostgreSQL backup
```

---

## AI-Generated Prototype

The system was planned using a **Top-Down approach** with UI characterization generated in **Google AI Studio**.

🔗 **[Live Demo (AI Studio)](https://ai.studio/apps/22d49e6f-06a0-43ed-933f-a033e8c625c5)**

<img width="1845" height="789" alt="Home screen" src="https://github.com/user-attachments/assets/a3711a36-d6a5-4b26-aca7-46caf8a6759f" />
<img width="1751" height="789" alt="Booking screen" src="https://github.com/user-attachments/assets/a201985f-9863-4d41-849d-6635a77eb7fb" />
<img width="1729" height="785" alt="Attractions screen" src="https://github.com/user-attachments/assets/5e76834b-3dc5-4299-9342-ad1fefb62e46" />
<img width="1668" height="796" alt="Review screen" src="https://github.com/user-attachments/assets/d3a10604-6b76-43fd-aef0-ce5a609cabdb" />

---

## Schema Design

The schema follows **3NF (Third Normal Form)** to minimize redundancy and enforce referential integrity.

### ERD & DSD Diagrams

| ERD (Entity-Relationship Diagram) | DSD (Data Structure Diagram) |
|:---:|:---:|
| ![ERD](./phase1/ERDandDSDfiles/ERD.png) | ![DSD](./phase1/ERDandDSDfiles/DSD.png) |

### Table Overview

| Table | Primary Key | Foreign Keys | Key Columns |
|---|---|---|---|
| `CUSTOMER` | `customer_id` | — | first_name, last_name, email, phone, country |
| `ATTRACTION` | `attraction_id` | — | name, location, category, price, opening_hours |
| `TICKET` | `ticket_id` | `attraction_id → ATTRACTION` | ticket_type, price, valid_date, available_quantity |
| `PAYMENT` | `payment_id` | — | booking_id (unique), amount |
| `BOOKING` | `booking_id` | `customer_id → CUSTOMER`, `payment_id → PAYMENT` | booking_date, booking_status, total_price |
| `REVIEW` | `review_id` | `customer_id → CUSTOMER`, `attraction_id → ATTRACTION` | rating (1–5), comment, review_date |
| `BOOKINGTICKET` | `(booking_id, ticket_id)` | `booking_id → BOOKING`, `ticket_id → TICKET` | quantity |

---

## SQL Scripts

| Script | Description | Link |
|---|---|---|
| `01-dropTables.sql` | Drops all tables in dependency-safe order | [View](phase1/SQLscripts/01-dropTables.sql) |
| `02-createTables.sql` | Creates all 7 tables with constraints & FKs | [View](phase1/SQLscripts/02-createTables.sql) |
| `03-insertTables.sql` | Sample data — 5 rows per table | [View](phase1/SQLscripts/03-insertTables.sql) |
| `04-selectAll.sql` | SELECT * and COUNT(*) for all tables | [View](phase1/SQLscripts/04-selectAll.sql) |

---

## Data Population

Three separate methods were used to populate the database with realistic data.

### Method 1 — Mockaroo CSV Generation

[Mockaroo](https://www.mockaroo.com/) was used to generate realistic CSV datasets matching each table's schema. Column names, data types, and value ranges were configured per table, and the output was exported as **CSV with header** (Windows CRLF) for smooth import into PostgreSQL.

<details>
<summary><strong>ATTRACTION — field mapping</strong></summary>

| Mockaroo Field | Generator |
|---|---|
| `attraction_id` | Row Number |
| `name` | Product Name |
| `location` | Street Name |
| `description` | Product Description |
| `opening_hours` | Time (12-hour) |
| `category` | Product Category |
| `price` | Product Price |

<img width="1282" height="632" alt="Mockaroo ATTRACTION config" src="https://github.com/user-attachments/assets/f3157410-3879-4921-a2dc-d89b9f81408b" />
</details>

<details>
<summary><strong>CUSTOMER — field mapping</strong></summary>

| Mockaroo Field | Generator |
|---|---|
| `customer_id` | Row Number |
| `first_name` / `last_name` | First / Last Name |
| `email` | Email Address |
| `phone` | Phone (formatted) |
| `password` | Password (mixed characters) |
| `country` | Country |

<img width="1796" height="641" alt="Mockaroo CUSTOMER config" src="https://github.com/user-attachments/assets/0eaeba06-1eae-4348-a6aa-8d0c0be348f2" />
</details>

<details>
<summary><strong>TICKET — field mapping</strong></summary>

| Mockaroo Field | Generator |
|---|---|
| `ticket_id` | Row Number |
| `attraction_id` | Row Number (matches ATTRACTION) |
| `price` | Product Price |
| `valid_date` | Datetime (project date range) |
| `ticket_type` | Custom List (general_admission, VIP, student, senior) |
| `available_quantity` | Number (1–100) |

<img width="1806" height="577" alt="Mockaroo TICKET config" src="https://github.com/user-attachments/assets/d7d62a22-a114-47e3-9e9c-f4b7b3944bdc" />
</details>

<details>
<summary><strong>BOOKING — field mapping</strong></summary>

| Mockaroo Field | Generator |
|---|---|
| `booking_id` | Row Number |
| `customer_id` | Row Number (matches CUSTOMER) |
| `booking_date` | Datetime (defined range) |
| `total_price` | Product Price |
| `payment_id` | Row Number (matches PAYMENT) |

<img width="1389" height="524" alt="Mockaroo BOOKING config" src="https://github.com/user-attachments/assets/a2e7cf32-2f92-4765-bae8-a3eafd74b858" />
</details>

Generated CSV files are stored in [`phase1/mockData/`](phase1/mockData/).

---

### Method 2 — pgAdmin CSV Import

Cleaned CSV files (stored in [`phase1/importData/`](phase1/importData/)) were imported directly through the pgAdmin GUI import window.

<img width="1041" height="375" alt="pgAdmin import dialog" src="https://github.com/user-attachments/assets/96ac8bb0-b8ef-4aa2-8689-a4601fc09bb7" />

pgAdmin confirmed successful import:

<img width="971" height="389" alt="pgAdmin import success" src="https://github.com/user-attachments/assets/ac1b9d4c-b288-4e80-a1da-e487ffdfc5a9" />

#### Row Count Validation

```sql
SELECT COUNT(*) FROM CUSTOMER;
```

<img width="183" height="111" alt="COUNT result" src="https://github.com/user-attachments/assets/f13716d4-8084-40f0-a62c-0859346dbe8c" />

**Result:** ✅ `20,000` rows successfully loaded into the `CUSTOMER` table.

---

### Method 3 — Python Direct Insert

[`insert_data.py`](phase1/programingData/insert_data.py) connects directly to PostgreSQL via `psycopg2` and generates + inserts rows for all 7 tables in the correct FK dependency order — no intermediate CSV files needed.

**Key features:**
- Reads all connection details from `.env` (supports `DB_*_SECRET` and `DB_*` fallbacks)
- `SEED_ROWS` env var controls how many rows to generate (default: `10`)
- `RESET_TABLES=true` truncates all tables before inserting (safe cascade)
- Fully transactional — rolls back on any error

<img width="1018" height="447" alt="Python script run output" src="https://github.com/user-attachments/assets/e4bcc1e1-9120-4dcc-b9db-28ee4c35f068" />
<img width="1486" height="656" alt="Python script success" src="https://github.com/user-attachments/assets/d9410b93-70e0-49f1-bbfb-0cf26d4f1cba" />

---

## Backup & Recovery

A full PostgreSQL backup was created with date-stamped naming to ensure data safety and reproducibility.

| Step | Details |
|---|---|
| **Backup** | Full dump created via pgAdmin → [`phase1/Backup/backup14_04_2026`](phase1/Backup/backup14_04_2026) |
| **Restore** | Tested on a clean DB instance using pgAdmin Restore |
| **Validation** | Post-restore row-count queries confirmed data integrity |

📁 [Go to Backup Folder](phase1/Backup)

**Backup process:**

<img width="1050" height="830" alt="pgAdmin backup dialog" src="https://github.com/user-attachments/assets/04c34005-5214-4de4-87d3-7cfa4428a844" />
<img width="870" height="397" alt="Backup progress" src="https://github.com/user-attachments/assets/3df95fad-846b-4226-9242-d19aac69427c" />

**Restore process:**

<img width="1050" height="601" alt="pgAdmin restore dialog" src="https://github.com/user-attachments/assets/364fa4d9-a3a1-4692-b9da-1aa06636da41" />
<img width="565" height="391" alt="Restore success" src="https://github.com/user-attachments/assets/cde294f5-97bc-4d23-b1d4-ae58a5db1b7b" />

---
