import psycopg2
from datetime import date, time
import os
from dotenv import load_dotenv

# ─────────────────────────────────────────────
#  Load environment variables from .env file
# ─────────────────────────────────────────────
load_dotenv()  # reads the .env file in the same directory

DB_CONFIG = {
    "host":     "localhost",
    "port":     5432,
    "dbname":   os.getenv("DB_NAME_SECRET"),
    "user":     os.getenv("DB_USER_SECRET"),
    "password": os.getenv("DB_PASSWORD_SECRET"),
}

def get_connection():
    return psycopg2.connect(**DB_CONFIG)


# ─────────────────────────────────────────────
#  Insert functions (10 rows per table)
# ─────────────────────────────────────────────

def insert_customers(cur):
    customers = [
        (1,  "Liam",    "Cohen",     "liam.cohen@gmail.com",    "0521234567", "Israel123",  "Israel"),
        (2,  "Emma",    "Levy",      "emma.levy@gmail.com",     "0532345678", "Emma@456",   "Israel"),
        (3,  "Noah",    "Mizrahi",   "noah.mizrahi@yahoo.com",  "0543456789", "Noah#789",   "USA"),
        (4,  "Olivia",  "Peretz",    "olivia.p@outlook.com",    "0554567890", "Oliv!012",   "France"),
        (5,  "James",   "Shapiro",   "james.s@gmail.com",       "0565678901", "Jam3s@345",  "UK"),
        (6,  "Sophia",  "Klein",     "sophia.k@gmail.com",      "0576789012", "Soph#678",   "Germany"),
        (7,  "Lucas",   "Friedman",  "lucas.f@gmail.com",       "0587890123", "Luc@s901",   "Brazil"),
        (8,  "Ava",     "Goldberg",  "ava.g@yahoo.com",         "0598901234", "Ava$234",    "Canada"),
        (9,  "Mason",   "Ben-David", "mason.bd@gmail.com",      "0509012345", "Mason!567",  "Israel"),
        (10, "Isabella","Katz",      "isabella.k@outlook.com",  "0521112233", "Isa@890",    "Spain"),
    ]
    cur.executemany("""
        INSERT INTO CUSTOMER (customer_id, first_name, last_name, email, phone, password, country)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
    """, customers)
    print(f"  ✔ CUSTOMER: {cur.rowcount} rows inserted")


def insert_attractions(cur):
    attractions = [
        (1,  "Eiffel Tower",    "Paris",        "Iconic iron lattice tower",       time(9,0),  "Landmark",    25.0),
        (2,  "Colosseum",       "Rome",         "Ancient amphitheater",            time(8,30), "Historical",  18.0),
        (3,  "Central Park",    "New York",     "Large urban park",                time(6,0),  "Nature",       0.0),
        (4,  "Sagrada Familia", "Barcelona",    "Gaudi basilica masterpiece",      time(9,0),  "Religious",   26.0),
        (5,  "Big Ben",         "London",       "Famous clock tower",              time(10,0), "Landmark",    30.0),
        (6,  "Masada",          "Israel",       "Ancient fortress on a plateau",   time(8,0),  "Historical",  15.0),
        (7,  "Louvre Museum",   "Paris",        "Worlds largest art museum",       time(9,0),  "Museum",      17.0),
        (8,  "Petra",           "Jordan",       "Rose-red city carved in rock",    time(7,0),  "Historical",  50.0),
        (9,  "Dead Sea",        "Israel",       "Lowest point on Earth",           time(7,30), "Nature",      20.0),
        (10, "Acropolis",       "Athens",       "Ancient citadel above Athens",    time(8,0),  "Historical",  20.0),
    ]
    cur.executemany("""
        INSERT INTO ATTRACTION (attraction_id, name, location, description, opening_hours, category, price)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
    """, attractions)
    print(f"  ✔ ATTRACTION: {cur.rowcount} rows inserted")


def insert_tickets(cur):
    # Each ticket linked to a unique attraction (UNIQUE constraint on attraction_id)
    tickets = [
        (1,  1,  25.0,  date(2025, 6, 1),  "Adult",   100),
        (2,  2,  18.0,  date(2025, 6, 5),  "Adult",   200),
        (3,  3,   0.0,  date(2025, 6, 10), "Free",    500),
        (4,  4,  26.0,  date(2025, 6, 15), "Adult",   150),
        (5,  5,  30.0,  date(2025, 6, 20), "Adult",   120),
        (6,  6,  15.0,  date(2025, 7, 1),  "Adult",   300),
        (7,  7,  17.0,  date(2025, 7, 5),  "Child",   250),
        (8,  8,  50.0,  date(2025, 7, 10), "Adult",    80),
        (9,  9,  20.0,  date(2025, 7, 15), "Senior",  100),
        (10, 10, 20.0,  date(2025, 7, 20), "Adult",   200),
    ]
    cur.executemany("""
        INSERT INTO TICKET (ticket_id, attraction_id, price, valid_date, ticket_type, available_quantity)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
    """, tickets)
    print(f"  ✔ TICKET: {cur.rowcount} rows inserted")


def insert_payments(cur):
    # PAYMENT has no FK – insert before BOOKING
    payments = [
        (1,  1,  25.0),
        (2,  2,  18.0),
        (3,  3,   0.0),
        (4,  4,  52.0),
        (5,  5,  30.0),
        (6,  6,  15.0),
        (7,  7,  34.0),
        (8,  8,  50.0),
        (9,  9,  40.0),
        (10, 10, 20.0),
    ]
    cur.executemany("""
        INSERT INTO PAYMENT (payment_id, booking_id, amount)
        VALUES (%s, %s, %s)
        ON CONFLICT DO NOTHING
    """, payments)
    print(f"  ✔ PAYMENT: {cur.rowcount} rows inserted")


def insert_bookings(cur):
    # BOOKING references CUSTOMER and PAYMENT
    # UNIQUE on customer_id → each customer appears once
    bookings = [
        (1,  1,  date(2025, 5, 10), "Confirmed", 25.0,  1),
        (2,  2,  date(2025, 5, 11), "Confirmed", 18.0,  2),
        (3,  3,  date(2025, 5, 12), "Pending",    0.0,  3),
        (4,  4,  date(2025, 5, 13), "Confirmed", 52.0,  4),
        (5,  5,  date(2025, 5, 14), "Cancelled", 30.0,  5),
        (6,  6,  date(2025, 5, 15), "Confirmed", 15.0,  6),
        (7,  7,  date(2025, 5, 16), "Confirmed", 34.0,  7),
        (8,  8,  date(2025, 5, 17), "Pending",   50.0,  8),
        (9,  9,  date(2025, 5, 18), "Confirmed", 40.0,  9),
        (10, 10, date(2025, 5, 19), "Confirmed", 20.0, 10),
    ]
    cur.executemany("""
        INSERT INTO BOOKING (booking_id, customer_id, booking_date, booking_status, total_price, payment_id)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
    """, bookings)
    print(f"  ✔ BOOKING: {cur.rowcount} rows inserted")


def insert_reviews(cur):
    # UNIQUE on customer_id AND attraction_id → each appears once
    reviews = [
        (1,  1,  1,  4.5, "Amazing view, totally worth it!",  date(2025, 5, 20)),
        (2,  2,  2,  5.0, "Breathtaking historical site.",     date(2025, 5, 21)),
        (3,  3,  3,  4.0, "Relaxing and beautiful park.",      date(2025, 5, 22)),
        (4,  4,  4,  4.8, "Gaudi is a true genius.",           date(2025, 5, 23)),
        (5,  5,  5,  4.2, "Iconic London landmark.",           date(2025, 5, 24)),
        (6,  6,  6,  5.0, "Masada sunrise is unforgettable.",  date(2025, 5, 25)),
        (7,  7,  7,  4.7, "Best museum in the world.",         date(2025, 5, 26)),
        (8,  8,  8,  4.9, "Petra is absolutely magical.",      date(2025, 5, 27)),
        (9,  9,  9,  3.8, "Unique experience, very salty!",    date(2025, 5, 28)),
        (10, 10, 10, 4.6, "Ancient history at its finest.",    date(2025, 5, 29)),
    ]
    cur.executemany("""
        INSERT INTO REVIEW (review_id, customer_id, attraction_id, rating, comment, review_date)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
    """, reviews)
    print(f"  ✔ REVIEW: {cur.rowcount} rows inserted")


def insert_bookingtickets(cur):
    # Links bookings to tickets (PK is composite: booking_id + ticket_id)
    bookingtickets = [
        (1, 1,  1),
        (1, 2,  2),
        (2, 3,  3),
        (2, 4,  4),
        (3, 5,  5),
        (1, 6,  6),
        (3, 7,  7),
        (2, 8,  8),
        (1, 9,  9),
        (2, 10, 10),
    ]
    cur.executemany("""
        INSERT INTO BOOKINGTICKET (quantity, booking_id, ticket_id)
        VALUES (%s, %s, %s)
        ON CONFLICT DO NOTHING
    """, bookingtickets)
    print(f"  ✔ BOOKINGTICKET: {cur.rowcount} rows inserted")


# ─────────────────────────────────────────────
#  Main
# ─────────────────────────────────────────────

def main():
    print("Connecting to PostgreSQL...")
    conn = get_connection()
    conn.autocommit = False
    cur = conn.cursor()

    try:
        print("\nInserting data (order respects FK dependencies):")
        insert_customers(cur)
        insert_attractions(cur)
        insert_tickets(cur)
        insert_payments(cur)   # must come before BOOKING
        insert_bookings(cur)
        insert_reviews(cur)
        insert_bookingtickets(cur)

        conn.commit()
        print("\n✅ All data committed successfully!")

    except Exception as e:
        conn.rollback()
        print(f"\n❌ Error – transaction rolled back.\nDetails: {e}")

    finally:
        cur.close()
        conn.close()
        print("Connection closed.")


if __name__ == "__main__":
    main()
