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
  - [SELECT Queries (8 total)](#select-queries-8-total)
  - [DELETE Queries (3 total)](#delete-queries-3-total)
  - [UPDATE Queries (3 total)](#update-queries-3-total)
  - [Constraints (3 via ALTER TABLE)](#constraints-3-via-alter-table)
  - [Rollback & Commit Demonstrations](#rollback--commit-demonstrations)
  - [Indexes (3) + Performance Comparison](#indexes-3--performance-comparison)
  - [Data Dictionary Additions (Motivation/Benefit)](#data-dictionary-additions-motivationbenefit)

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

## Introduction
בשלב זה בוצע תשאול מתקדם של בסיס הנתונים, כולל כתיבת שאילתות מורכבות, עדכונים ומחיקות, עבודה עם טרנזקציות (`ROLLBACK`/`COMMIT`), הוספת אילוצים באמצעות `ALTER TABLE`, והוספת אינדקסים לצורך שיפור ביצועים.

העבודה מותאמת למסכים שהוגדרו במערכת (ניהול לקוחות, ניהול הזמנות, ניהול כרטיסים, דשבורד ניהולי), כך שניתן יהיה לחבר את השאילתות ישירות לשכבת ה-GUI בשלב הסופי.

---

## Deliverables

תיקיית שלב ב בפרויקט:

- **Queries.sql**  
  [View File](phase2/Queries.sql)

- **Constraints.sql**  
  [View File](phase2/Constraints.sql)

- **RollbackCommit.sql**  
  [View File](phase2/RollbackCommit.sql)

- **Index.sql**  
  [View File](phase2/Index.sql)

- **backup2**  
  יש להעלות קובץ גיבוי מעודכן בשם `backup2` לתיקיית `phase2`.

---

## SELECT Queries (8 total)

קובץ השאילתות כולל:
- 4 שאילתות SELECT כפולות (שתי גרסאות לכל שאילתה) עם השוואת יעילות.
- 4 שאילתות SELECT נוספות ברמת מורכבות לא טריוויאלית.
- שימוש ב-`JOIN`, `GROUP BY`, `HAVING`, `ORDER BY`, תתי-שאילתות, וניתוח תאריכים (`EXTRACT` יום/חודש/שנה/רבעון).

### 4 שאילתות SELECT כפולות (Dual Form)
1. Top-Rated Attractions by Category  
2. Customers Above Monthly Average Spend  
3. Monthly Revenue Above Average  
4. Attractions With No Bookings

בכל אחת מהשאילתות הכפולות יש:
- תיאור בעברית  
- שתי גרסאות SQL  
- הסבר מה יעיל יותר ולמה

### 4 שאילתות SELECT נוספות
5. Full Customer Booking History  
6. Ticket Availability by Month & Category  
7. Revenue per Category per Quarter  
8. Customers Who Reviewed Attractions They Booked

---

## DELETE Queries (3 total)

1. מחיקת כרטיסים שפג תוקפם (עם טיפול בתלויות)  
2. מחיקת ביקורות ישנות (מעל שנה)  
3. מחיקת הזמנות מבוטלות ורשומות קשורות

---

## UPDATE Queries (3 total)

1. העלאת מחיר כרטיסים לאטרקציות בביקוש גבוה  
2. עדכון סטטוס הזמנות `Pending` ל-`Confirmed` בתקופה מוגדרת  
3. הנחה על אטרקציות בקטגוריית `Museum`

---

## Constraints (3 via ALTER TABLE)

האילוצים נוספו באמצעות `ALTER TABLE` בלבד:

1. `chk_booking_date_not_future` — תאריך הזמנה לא יכול להיות בעתיד  
2. `chk_ticket_max_quantity` — כמות זמינה מקסימלית לכרטיס  
3. `chk_attraction_max_price` — מחיר אטרקציה מקסימלי

בנוסף, בוצעו ניסיונות הכנסה שמפרים את האילוץ כדי להראות שגיאת הרצה.

---

## Rollback & Commit Demonstrations

קובץ `RollbackCommit.sql` כולל שני תרחישים מלאים:

1. **ROLLBACK**  
   עדכון נתונים → הצגת מצב מעודכן → `ROLLBACK` → הצגת מצב קודם (חזרה לקדמותו).

2. **COMMIT**  
   עדכון נתונים → הצגת מצב מעודכן → `COMMIT` → הצגה נוספת המאשרת שהשינוי נשמר.

---

## Indexes (3) + Performance Comparison

הוספת 3 אינדקסים:

1. `idx_customer_country` על `CUSTOMER(country)`  
2. `idx_ticket_valid_date` על `TICKET(valid_date)`  
3. `idx_booking_status` על `BOOKING(booking_status)`

עבור כל אינדקס בוצעו בדיקות `EXPLAIN ANALYZE` לפני ואחרי ההוספה, כולל ניתוח תוצאות והשוואת זמני ריצה.

---

## Data Dictionary Additions (Motivation/Benefit)

לכל אילוץ ולכל אינדקס נוספו הסברים של:
- **מוטיבציה עסקית/טכנית**
- **תועלת צפויה**
- **לאיזה מסך במערכת זה רלוונטי**

הסברים אלה נמצאים בקבצי:
- [Constraints.sql](phase2/Constraints.sql)
- [Index.sql](phase2/Index.sql)

---

## Stage 2 Report Submission Notes

לצורך ההגשה הסופית בדו"ח (README):

- עבור כל אחת מ-4 השאילתות הכפולות:  
  תיאור בעברית + קוד + צילום הרצה + צילום תוצאה (עד 5 שורות) + הסבר יעילות.

- עבור 4 שאילתות SELECT הנוספות:  
  תיאור בעברית + קוד + צילום הרצה + צילום תוצאה.

- עבור כל UPDATE/DELETE:  
  תיאור בעברית + צילום לפני + צילום הרצה + צילום אחרי.

- עבור אילוצים:  
  תיאור שינוי + הרצה + ניסיון קלט שגוי + צילום שגיאה.

- עבור ROLLBACK/COMMIT:  
  צילום מצב בסיס הנתונים בכל שלב.

- עבור אינדקסים:  
  צילום/תיעוד זמני ריצה לפני ואחרי + הסבר.

---
