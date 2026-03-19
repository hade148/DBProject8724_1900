CREATE TABLE CUSTOMER
(
  first_name VARCHAR(20) NOT NULL,
  email VARCHAR(50) NOT NULL,
  phone VARCHAR(10) NOT NULL,
  customer_id INT NOT NULL,
  last_name VARCHAR(20) NOT NULL,
  password VARCHAR(20) NOT NULL,
  country VARCHAR(20) NOT NULL,
  PRIMARY KEY (customer_id)
);

CREATE TABLE ATTRACTION
(
  attraction_id INT NOT NULL,
  name VARCHAR(20) NOT NULL,
  location VARCHAR(20) NOT NULL,
  description VARCHAR(1000),
  opening_hours TIME NOT NULL,
  category VARCHAR(20) NOT NULL,
  price FLOAT NOT NULL,
  PRIMARY KEY (attraction_id)
);

CREATE TABLE TICKET
(
  ticket_id INT NOT NULL,
  attraction_id INT NOT NULL,
  price FLOAT NOT NULL,
  valid_date DATE NOT NULL,
  ticket_type VARCHAR(20) NOT NULL,
  available_quantity INT,
  PRIMARY KEY (ticket_id),
  FOREIGN KEY (attraction_id) REFERENCES ATTRACTION(attraction_id),
  UNIQUE (attraction_id)
);

CREATE TABLE PAYMENT
(
  payment_id INT NOT NULL,
  booking_id INT NOT NULL,
  amount FLOAT NOT NULL,
  PRIMARY KEY (payment_id),
  UNIQUE (booking_id)
);

CREATE TABLE BOOKING
(
  booking_id INT NOT NULL,
  customer_id INT NOT NULL,
  booking_date DATE NOT NULL,
  booking_status VARCHAR(20),
  total_price FLOAT NOT NULL,
  payment_id INT NOT NULL,
  PRIMARY KEY (booking_id),
  FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
  FOREIGN KEY (payment_id) REFERENCES PAYMENT(payment_id),
  UNIQUE (customer_id)
);

CREATE TABLE REVIEW
(
  review_id INT NOT NULL,
  customer_id INT NOT NULL,
  attraction_id INT NOT NULL,
  rating FLOAT NOT NULL,
  comment VARCHAR(100) NOT NULL,
  review_date DATE NOT NULL,
  PRIMARY KEY (review_id),
  FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
  FOREIGN KEY (attraction_id) REFERENCES ATTRACTION(attraction_id),
  UNIQUE (customer_id),
  UNIQUE (attraction_id)
);

CREATE TABLE BOOKINGTICKET
(
  quantity INT NOT NULL,
  booking_id INT NOT NULL,
  ticket_id INT NOT NULL,
  PRIMARY KEY (booking_id, ticket_id),
  FOREIGN KEY (booking_id) REFERENCES BOOKING(booking_id),
  FOREIGN KEY (ticket_id) REFERENCES TICKET(ticket_id)
);