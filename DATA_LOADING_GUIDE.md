Data Loading Guide (3 required methods)

Requirement Summary:
- At least 500 rows in every table.
- At least 20,000 rows in at least 2 tables.
- Use 3 different methods:
1) External data website.
2) Python script that inserts directly into DB.
3) Loading from files.

Files prepared in this repository:
- init-db/03-load-from-csv.sql
- init-db/generated-data/README.txt
- init-db/insertTables.sql
- scripts/generate_bulk_data.py
- scripts/insert_direct_to_db.py

Default row counts in prepared Python scripts:
- CUSTOMER: 20000
- ATTRACTION: 20000
- PAYMENT: 500
- BOOKING: 500
- TICKET: 500
- REVIEW: 500
- BOOKINGTICKET: 500

Method 1: External website (Mockaroo / Generatedata)

Goal:
- Create realistic CSV files externally and import them.

What you need to do:
1) Open a generator website (Mockaroo or Generatedata).
2) For each table, create CSV with exact column names and compatible types.
3) Use exact file names:
   customer.csv, attraction.csv, payment.csv, booking.csv, ticket.csv, review.csv, bookingticket.csv
4) Save all files into init-db/generated-data/.
5) Load into DB using init-db/03-load-from-csv.sql.

Important mapping notes:
- booking.csv must reference existing customer_id and payment_id values.
- ticket.csv must reference existing attraction_id values.
- review.csv must reference existing customer_id and attraction_id values.
- bookingticket.csv must reference existing booking_id and ticket_id values.

Method 2: Python script that inserts directly into DB

Goal:
- Insert data directly from Python into PostgreSQL without an intermediate SQL/CSV load step.

What is ready:
- scripts/insert_direct_to_db.py inserts rows directly using psycopg2.

What you need to do:
1) Install dependency:
   py -m pip install psycopg2-binary
2) Run from repository root:
   py scripts/insert_direct_to_db.py --db-name <DB_NAME> --db-user <DB_USER> --db-password <DB_PASSWORD>
3) Optional flags:
   --truncate-first
   --customer 20000 --attraction 20000 --payment 500 --booking 500 --ticket 500 --review 500 --bookingticket 500

Method 3: Loading from files (CSV/SQL file)

Goal:
- Generate data to files and load from files.

Option A: Generate CSV then load with COPY
1) Generate CSV files:
   py scripts/generate_bulk_data.py --mode csv --output-dir init-db/generated-data
2) Load CSV into DB:
   Run init-db/03-load-from-csv.sql

Option B: Generate SQL insert file
1) Generate SQL file:
   py scripts/generate_bulk_data.py --mode sql --sql-output init-db/generated-data/generated_inserts.sql
2) Run generated SQL file.

Run order recommendation (clean run):
1) init-db/dropTables.sql
2) init-db/01-create-tables.sql
3) Choose one method from above
4) init-db/selectAll.sql

Validation queries:
- SELECT COUNT(*) FROM CUSTOMER;
- SELECT COUNT(*) FROM ATTRACTION;
- SELECT COUNT(*) FROM PAYMENT;
- SELECT COUNT(*) FROM BOOKING;
- SELECT COUNT(*) FROM TICKET;
- SELECT COUNT(*) FROM REVIEW;
- SELECT COUNT(*) FROM BOOKINGTICKET;

Schema constraints to remember:
- BOOKING has UNIQUE(customer_id), so each customer can appear once in BOOKING.
- TICKET has UNIQUE(attraction_id), so each attraction can appear once in TICKET.
- REVIEW has UNIQUE(customer_id) and UNIQUE(attraction_id), so each customer and attraction can appear once in REVIEW.

Extra note:
- init-db/insertTables.sql is a small manual sample for demonstration only.
