# AttraTicket: Attraction Booking System

## Project Information
**Prepared by:** [Your Name], [Partner Name]  
**System Name:** AttraTicket  
**Module:** Attraction Booking, Ticketing & Customer Reviews

---

## Table of Contents
- [Stage 1: Design and Build the Database](#stage-1-design-and-build-the-database)
  - [Introduction](#introduction)
  - [AI-Generated Prototype](#ai-generated-prototype)
  - [Logical Design](#logical-design)
  - [Data Dictionary](#data-dictionary)
  - [SQL Scripts](#sql-scripts)
  - [Data Population Methods](#data-population-methods)
  - [Backup & Recovery](#backup--recovery)

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

<img width="1845" height="789" alt="Screenshot 2026-04-13 225842" src="https://github.com/user-attachments/assets/a3711a36-d6a5-4b26-aca7-46caf8a6759f" />
<img width="1751" height="789" alt="Screenshot 2026-04-13 230115" src="https://github.com/user-attachments/assets/a201985f-9863-4d41-849d-6635a77eb7fb" />
<img width="1729" height="785" alt="Screenshot 2026-04-13 225957" src="https://github.com/user-attachments/assets/5e76834b-3dc5-4299-9342-ad1fefb62e46" />
<img width="1668" height="796" alt="Screenshot 2026-04-13 230142" src="https://github.com/user-attachments/assets/d3a10604-6b76-43fd-aef0-ce5a609cabdb" />

---

## AI-Generated Prototype
### System Screens
The system was planned using a **Top-Down approach** with UI characterization in Google AI Studio.

- **[Live Demo (AI Studio Link)](https://ai.studio/apps/22d49e6f-06a0-43ed-933f-a033e8c625c5)**


---

## Logical Design
### ERD (Entity-Relationship Diagram) & DSD (Data Structure Diagram)
The database schema was designed according to **3NF (Third Normal Form)** to reduce redundancy and enforce consistency.

| Type | Diagram |
| :--- | :--- |
| **ERD** | ![ERD](phase1/ERDAndDSTFiles/ERD.png) |
| **DSD** | ![DSD](phase1/ERDAndDSTFiles/DSD.png) |

---

## Data Dictionary

### 1. CUSTOMER Table
**Role:** Stores customer profile and account details.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| first_name | VARCHAR(20) | NOT NULL | Customer first name |
| last_name | VARCHAR(20) | NOT NULL | Customer last name |
| email | VARCHAR(50) | NOT NULL | Customer email |
| phone | VARCHAR(10) | NOT NULL | Customer phone number |
| password | VARCHAR(20) | NOT NULL | Customer password |
| country | VARCHAR(20) | NOT NULL | Country of residence |
| customer_id | INT | PRIMARY KEY | Unique customer ID |

---

### 2. ATTRACTION Table
**Role:** Stores attraction catalog information.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| attraction_id | INT | PRIMARY KEY | Unique attraction ID |
| name | VARCHAR(20) | NOT NULL | Attraction name |
| location | VARCHAR(20) | NOT NULL | Attraction location |
| description | VARCHAR(1000) | - | Attraction description |
| opening_hours | TIME | NOT NULL | Daily opening time |
| category | VARCHAR(20) | NOT NULL | Attraction category |
| price | FLOAT | NOT NULL | Base attraction price |

---

### 3. TICKET Table
**Role:** Stores ticket definitions per attraction.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| ticket_id | INT | PRIMARY KEY | Unique ticket ID |
| attraction_id | INT | FOREIGN KEY, UNIQUE | Linked attraction |
| price | FLOAT | NOT NULL | Ticket price |
| valid_date | DATE | NOT NULL | Ticket validity date |
| ticket_type | VARCHAR(20) | NOT NULL | Ticket type |
| available_quantity | INT | - | Remaining quantity |

---

### 4. PAYMENT Table
**Role:** Stores payment transactions.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| payment_id | INT | PRIMARY KEY | Unique payment ID |
| booking_id | INT | UNIQUE | Linked booking ID |
| amount | FLOAT | NOT NULL | Paid amount |

---

### 5. BOOKING Table
**Role:** Stores booking operations made by customers.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| booking_id | INT | PRIMARY KEY | Unique booking ID |
| customer_id | INT | FOREIGN KEY, UNIQUE | Linked customer |
| booking_date | DATE | NOT NULL | Booking creation date |
| booking_status | VARCHAR(20) | - | Booking status |
| total_price | FLOAT | NOT NULL | Total booking price |
| payment_id | INT | FOREIGN KEY | Linked payment |

---

### 6. REVIEW Table
**Role:** Stores customer feedback per attraction.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| review_id | INT | PRIMARY KEY | Unique review ID |
| customer_id | INT | FOREIGN KEY, UNIQUE | Reviewer customer |
| attraction_id | INT | FOREIGN KEY, UNIQUE | Reviewed attraction |
| rating | FLOAT | NOT NULL | Numeric rating |
| comment | VARCHAR(100) | NOT NULL | Written review |
| review_date | DATE | NOT NULL | Review date |

---

### 7. BOOKINGTICKET Table
**Role:** Junction table between bookings and tickets.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| booking_id | INT | PK (composite), FOREIGN KEY | Related booking |
| ticket_id | INT | PK (composite), FOREIGN KEY | Related ticket |
| quantity | INT | NOT NULL | Number of tickets in booking |

---

## SQL Scripts
Provide the following SQL scripts:

- **Create Tables Script**  
  **[View Create Tables](init-db/02-create-tables.sql)**

- **Drop Tables Script**  
  **[View Drop Tables](init-db/dropTables.sql)**

- **Insert Data Script**  
  **[View Insert Data](init-db/insertTables.sql)**

- **Select All Data Script**  
  **[View Select All](init-db/selectAll.sql)**

- **CSV Loading Script**  
  **[View CSV Loader](init-db/03-load-from-csv.sql)**

---

## Data Population Methods

### First Method: External Data Generator (Mockaroo / GenerateData)
Used to generate CSV data files for core tables.

Example file from repository:  
- **[View attraction mock data](mockData/attraction_MOCK_DATA.csv)**

> Add screenshots: generator setup, CSV export, import process, count results.

---

### Second Method: CSV / Direct Data Import
Used for loading pre-generated files into PostgreSQL.

- Input folder: `init-db/generated-data/`
- Loader script: **[03-load-from-csv.sql](init-db/03-load-from-csv.sql)**

> Add screenshots: CSV files, pgAdmin import / SQL load execution, success output.

---

### Third Method: Python Scripts
Used for large-scale synthetic generation and direct insertion.

- **Direct DB insert script:**  
  **[insert_direct_to_db.py](scripts/insert_direct_to_db.py)**

- **Bulk generator script (CSV/SQL modes):**  
  **[generate_bulk_data.py](scripts/generate_bulk_data.py)**

Default prepared volume profile:
- CUSTOMER: 20,000  
- ATTRACTION: 20,000  
- PAYMENT: 500  
- BOOKING: 500  
- TICKET: 500  
- REVIEW: 500  
- BOOKINGTICKET: 500  

> Add screenshots: script execution and output counts.

---

### Validation Queries
```sql
SELECT COUNT(*) FROM CUSTOMER;
SELECT COUNT(*) FROM ATTRACTION;
SELECT COUNT(*) FROM PAYMENT;
SELECT COUNT(*) FROM BOOKING;
SELECT COUNT(*) FROM TICKET;
SELECT COUNT(*) FROM REVIEW;
SELECT COUNT(*) FROM BOOKINGTICKET;
```

> Add screenshots of each query result.

---

## Backup & Recovery
Backup and restore were executed to ensure data safety and reproducibility.

- A full backup file was created with date/time naming.
- Restore was tested on a clean DB instance.
- Post-restore validation was performed using row-count queries.

> Add screenshots: backup command/result, restore process, validation output.

---
