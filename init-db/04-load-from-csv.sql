-- Method C: load data from CSV files
-- Expected CSV location in the repository: init-db/generated-data/
-- Expected mounted location inside PostgreSQL container: /docker-entrypoint-initdb.d/generated-data/

COPY CUSTOMER(first_name, email, phone, customer_id, last_name, password, country)
FROM '/docker-entrypoint-initdb.d/generated-data/customer.csv'
WITH (FORMAT csv, HEADER true);

COPY ATTRACTION(attraction_id, name, location, description, opening_hours, category, price)
FROM '/docker-entrypoint-initdb.d/generated-data/attraction.csv'
WITH (FORMAT csv, HEADER true);

COPY PAYMENT(payment_id, booking_id, amount)
FROM '/docker-entrypoint-initdb.d/generated-data/payment.csv'
WITH (FORMAT csv, HEADER true);

COPY BOOKING(booking_id, customer_id, booking_date, booking_status, total_price, payment_id)
FROM '/docker-entrypoint-initdb.d/generated-data/booking.csv'
WITH (FORMAT csv, HEADER true);

COPY TICKET(ticket_id, attraction_id, price, valid_date, ticket_type, available_quantity)
FROM '/docker-entrypoint-initdb.d/generated-data/ticket.csv'
WITH (FORMAT csv, HEADER true);

COPY REVIEW(review_id, customer_id, attraction_id, rating, comment, review_date)
FROM '/docker-entrypoint-initdb.d/generated-data/review.csv'
WITH (FORMAT csv, HEADER true);

COPY BOOKINGTICKET(quantity, booking_id, ticket_id)
FROM '/docker-entrypoint-initdb.d/generated-data/bookingticket.csv'
WITH (FORMAT csv, HEADER true);
