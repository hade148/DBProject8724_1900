-- Method A: direct INSERT statements
-- This file demonstrates manual inserts with correct dependency order.

INSERT INTO CUSTOMER (first_name, email, phone, customer_id, last_name, password, country) VALUES
('Noa', 'noa.levi1@example.com', '0501110001', 1, 'Levi', 'PwdNoa001', 'Israel'),
('Yael', 'yael.cohen2@example.com', '0501110002', 2, 'Cohen', 'PwdYael002', 'Israel'),
('Liam', 'liam.dan3@example.com', '0501110003', 3, 'Dan', 'PwdLiam003', 'Israel'),
('Maya', 'maya.barak4@example.com', '0501110004', 4, 'Barak', 'PwdMaya004', 'Israel'),
('Omer', 'omer.katz5@example.com', '0501110005', 5, 'Katz', 'PwdOmer005', 'Israel');

INSERT INTO ATTRACTION (attraction_id, name, location, description, opening_hours, category, price) VALUES
(1, 'OldPortWalk', 'TelAviv', 'Guided walk at the old port area', '09:00:00', 'Tour', 79.90),
(2, 'CityMuseum', 'Haifa', 'Modern city museum entrance ticket', '10:00:00', 'Museum', 55.00),
(3, 'NegevSafari', 'Beersheba', 'Open safari with family activities', '08:30:00', 'Nature', 120.00),
(4, 'AquaPark', 'Eilat', 'Water park full day access', '09:30:00', 'Water', 140.00),
(5, 'FoodMarket', 'Jerusalem', 'Tasting tour in local food market', '11:00:00', 'Food', 95.50);

INSERT INTO PAYMENT (payment_id, booking_id, amount) VALUES
(1, 1, 79.90),
(2, 2, 55.00),
(3, 3, 120.00),
(4, 4, 140.00),
(5, 5, 95.50);

INSERT INTO BOOKING (booking_id, customer_id, booking_date, booking_status, total_price, payment_id) VALUES
(1, 1, '2026-03-10', 'PAID', 79.90, 1),
(2, 2, '2026-03-11', 'PAID', 55.00, 2),
(3, 3, '2026-03-12', 'PAID', 120.00, 3),
(4, 4, '2026-03-13', 'PAID', 140.00, 4),
(5, 5, '2026-03-14', 'PAID', 95.50, 5);

INSERT INTO TICKET (ticket_id, attraction_id, price, valid_date, ticket_type, available_quantity) VALUES
(1, 1, 79.90, '2026-04-01', 'REGULAR', 300),
(2, 2, 55.00, '2026-04-01', 'REGULAR', 250),
(3, 3, 120.00, '2026-04-02', 'FAMILY', 150),
(4, 4, 140.00, '2026-04-02', 'VIP', 100),
(5, 5, 95.50, '2026-04-03', 'REGULAR', 220);

INSERT INTO REVIEW (review_id, customer_id, attraction_id, rating, comment, review_date) VALUES
(1, 1, 1, 4.8, 'Great guided route and atmosphere', '2026-03-15'),
(2, 2, 2, 4.3, 'Interesting exhibits and easy access', '2026-03-16'),
(3, 3, 3, 4.6, 'Kids enjoyed the whole day', '2026-03-17'),
(4, 4, 4, 4.1, 'Fun slides but crowded at noon', '2026-03-18'),
(5, 5, 5, 4.7, 'Excellent food and local stories', '2026-03-19');

INSERT INTO BOOKINGTICKET (quantity, booking_id, ticket_id) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(2, 4, 4),
(1, 5, 5);
