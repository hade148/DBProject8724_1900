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
---

## AI-Generated Prototype
### System Screens
The system was planned using a **Top-Down approach** with UI characterization in Google AI Studio.

 **[Live Demo (AI Studio Link)](https://ai.studio/apps/22d49e6f-06a0-43ed-933f-a033e8c625c5)**


<img width="1845" height="789" alt="Screenshot 2026-04-13 225842" src="https://github.com/user-attachments/assets/a3711a36-d6a5-4b26-aca7-46caf8a6759f" />
<img width="1751" height="789" alt="Screenshot 2026-04-13 230115" src="https://github.com/user-attachments/assets/a201985f-9863-4d41-849d-6635a77eb7fb" />
<img width="1729" height="785" alt="Screenshot 2026-04-13 225957" src="https://github.com/user-attachments/assets/5e76834b-3dc5-4299-9342-ad1fefb62e46" />
<img width="1668" height="796" alt="Screenshot 2026-04-13 230142" src="https://github.com/user-attachments/assets/d3a10604-6b76-43fd-aef0-ce5a609cabdb" />


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
  **[View Create Tables](phase1/SQLscripts/02-create-tables.sql)**

- **Drop Tables Script**  
  **[View Drop Tables](phase1/SQLscripts/01-dropTables.sql)**

- **Insert Data Script**  
  **[View Insert Data](phase1/SQLscripts/03-insertTables.sql)**

- **Select All Data Script**  
  **[View Select All](phase1/SQLscripts/04-selectAll.sql)**

---

### Data  

#### First tool: using [Mockaroo](https://www.mockaroo.com/) / external generator to create CSV files
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

##### Output files
The generated CSV files were exported and saved in the project repository for loading/import.

Example CSV from repository:  
 **[View `attraction_MOCK_DATA.csv`](phase1/mockData/attraction_MOCK_DATA.csv)**

> Add here (optional, recommended like in the lecturer example):
> - screenshots of the CSV files after download  
> - screenshots of the import process into PostgreSQL (pgAdmin Import / COPY)  
> - screenshots of `SELECT COUNT(*)` verification results for each populated table

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
