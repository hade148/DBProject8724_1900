import os
import random
import string
from datetime import date, time, timedelta

import psycopg2
from dotenv import load_dotenv

load_dotenv()
random.seed()


def env_value(primary_key, fallback_key=None, default=None):
    value = os.getenv(primary_key)
    if value:
        return value
    if fallback_key:
        value = os.getenv(fallback_key)
        if value:
            return value
    return default


DB_CONFIG = {
    "host": env_value("DB_HOST_SECRET", "DB_HOST", "localhost"),
    "port": int(env_value("DB_PORT_SECRET", "DB_PORT", "5432")),
    "dbname": env_value("DB_NAME_SECRET", "DB_NAME"),
    "user": env_value("DB_USER_SECRET", "DB_USER"),
    "password": env_value("DB_PASSWORD_SECRET", "DB_PASSWORD"),
}

DEFAULT_ROWS = int(env_value("SEED_ROWS", default="10"))
RESET_TABLES = env_value("RESET_TABLES", default="false").lower() in {"1", "true", "yes"}

FIRST_NAMES = [
    "Liam", "Emma", "Noah", "Olivia", "James", "Sophia", "Lucas", "Ava", "Mason", "Isabella",
    "Daniel", "Ella", "Yonatan", "Tamar", "David", "Mia", "Oren", "Noga", "Ethan", "Amelia",
]
LAST_NAMES = [
    "Cohen", "Levy", "Mizrahi", "Peretz", "Shapiro", "Klein", "Friedman", "Goldberg", "Katz", "BenDavid",
    "Rosen", "Ashkenazi", "Bar", "Dahan", "Azoulay", "Haddad", "Nissim", "Biton", "Malka", "Ohana",
]
COUNTRIES = ["Israel", "USA", "France", "Germany", "Spain", "Italy", "UK", "Canada", "Brazil", "Jordan"]
ATTRACTION_TYPES = [
    "Museum", "Landmark", "Nature", "Historical", "Religious", "Art", "Science", "Adventure", "Food", "Water",
]
CITIES = [
    "TelAviv", "Jerusalem", "Haifa", "Eilat", "Nazareth", "Paris", "Rome", "Athens", "Barcelona", "London",
]
TICKET_TYPES = ["Adult", "Child", "Senior", "VIP", "Student"]
BOOKING_STATUSES = ["Confirmed", "Pending", "Cancelled"]
REVIEW_COMMENTS = [
    "Amazing experience", "Great value", "Very organized", "Would visit again", "Nice for families",
    "Could be better", "Excellent staff", "Beautiful location", "Highly recommended", "Crowded but worth it",
]


def get_connection():
    missing = [k for k in ("dbname", "user", "password") if not DB_CONFIG.get(k)]
    if missing:
        raise ValueError(
            "Missing DB env vars: "
            + ", ".join(missing)
            + " (set DB_*_SECRET or DB_* in .env)"
        )
    return psycopg2.connect(**DB_CONFIG)


def random_phone():
    return "05" + "".join(random.choices(string.digits, k=8))


def random_password(length=10):
    alphabet = string.ascii_letters + string.digits
    return "".join(random.choices(alphabet, k=length))


def random_opening_hour():
    hour = random.randint(7, 11)
    minute = random.choice([0, 15, 30, 45])
    return time(hour, minute)


def random_future_date(start_offset_days=1, end_offset_days=120):
    day_offset = random.randint(start_offset_days, end_offset_days)
    return date.today() + timedelta(days=day_offset)


def truncate_tables(cur):
    cur.execute("TRUNCATE TABLE BOOKINGTICKET, REVIEW, BOOKING, PAYMENT, TICKET, ATTRACTION, CUSTOMER CASCADE;")
    print("  [OK] Truncated existing rows")


def get_next_id(cur, table_name, id_column):
    cur.execute(f"SELECT COALESCE(MAX({id_column}), 0) + 1 FROM {table_name}")
    return cur.fetchone()[0]


def generate_customers(row_count, start_customer_id=1):
    rows = []
    used_emails = set()

    for customer_id in range(start_customer_id, start_customer_id + row_count):
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        country = random.choice(COUNTRIES)

        email = f"{first_name.lower()}.{last_name.lower()}{customer_id}@example.com"
        if email in used_emails:
            email = f"{first_name.lower()}.{last_name.lower()}{customer_id}_{random.randint(100, 999)}@example.com"
        used_emails.add(email)

        rows.append(
            (
                customer_id,
                first_name,
                last_name,
                email,
                random_phone(),
                random_password(),
                country,
            )
        )

    return rows


def generate_attractions(row_count, start_attraction_id=1):
    rows = []

    for attraction_id in range(start_attraction_id, start_attraction_id + row_count):
        category = random.choice(ATTRACTION_TYPES)
        city = random.choice(CITIES)
        name = f"{category}{attraction_id}"
        description = f"{category} attraction in {city}"
        base_price = round(random.uniform(20.0, 250.0), 2)

        rows.append(
            (
                attraction_id,
                name,
                city,
                description,
                random_opening_hour(),
                category,
                base_price,
            )
        )

    return rows


def generate_tickets(attractions, start_ticket_id=1):
    rows = []

    for ticket_id, attraction in enumerate(attractions, start=start_ticket_id):
        attraction_id = attraction[0]
        attraction_price = attraction[6]
        ticket_price = max(1.0, round(attraction_price * random.uniform(0.8, 1.2), 2))

        rows.append(
            (
                ticket_id,
                attraction_id,
                ticket_price,
                random_future_date(),
                random.choice(TICKET_TYPES),
                random.randint(20, 500),
            )
        )

    return rows


def generate_payments(booking_ids, start_payment_id=1):
    rows = []
    for idx, booking_id in enumerate(booking_ids):
        payment_id = start_payment_id + idx
        rows.append((payment_id, booking_id, round(random.uniform(25.0, 400.0), 2)))
    return rows


def generate_bookings(customers, payments, booking_ids):
    rows = []
    today = date.today()

    for idx, customer in enumerate(customers):
        booking_id = booking_ids[idx]
        customer_id = customer[0]
        payment_id = payments[idx][0]
        total_price = payments[idx][2]

        rows.append(
            (
                booking_id,
                customer_id,
                today - timedelta(days=random.randint(1, 60)),
                random.choice(BOOKING_STATUSES),
                total_price,
                payment_id,
            )
        )

    return rows


def generate_reviews(customers, attractions, start_review_id=1):
    rows = []
    review_count = min(len(customers), len(attractions))
    today = date.today()

    for offset in range(review_count):
        review_id = start_review_id + offset
        customer_id = customers[offset][0]
        attraction_id = attractions[offset][0]

        rows.append(
            (
                review_id,
                customer_id,
                attraction_id,
                round(random.uniform(1.0, 5.0), 1),
                random.choice(REVIEW_COMMENTS),
                today - timedelta(days=random.randint(1, 40)),
            )
        )

    return rows


def generate_bookingtickets(bookings, tickets):
    rows = []
    max_pairs = min(len(bookings), len(tickets))

    for idx in range(max_pairs):
        booking_id = bookings[idx][0]
        ticket_id = tickets[idx][0]
        rows.append((random.randint(1, 4), booking_id, ticket_id))

    return rows


def insert_customers(cur, rows):
    cur.executemany(
        """
        INSERT INTO CUSTOMER (customer_id, first_name, last_name, email, phone, password, country)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
        """,
        rows,
    )
    print(f"  [OK] CUSTOMER: attempted {len(rows)}, inserted {cur.rowcount}")


def insert_attractions(cur, rows):
    cur.executemany(
        """
        INSERT INTO ATTRACTION (attraction_id, name, location, description, opening_hours, category, price)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
        """,
        rows,
    )
    print(f"  [OK] ATTRACTION: attempted {len(rows)}, inserted {cur.rowcount}")


def insert_tickets(cur, rows):
    cur.executemany(
        """
        INSERT INTO TICKET (ticket_id, attraction_id, price, valid_date, ticket_type, available_quantity)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
        """,
        rows,
    )
    print(f"  [OK] TICKET: attempted {len(rows)}, inserted {cur.rowcount}")


def insert_payments(cur, rows):
    cur.executemany(
        """
        INSERT INTO PAYMENT (payment_id, booking_id, amount)
        VALUES (%s, %s, %s)
        ON CONFLICT DO NOTHING
        """,
        rows,
    )
    print(f"  [OK] PAYMENT: attempted {len(rows)}, inserted {cur.rowcount}")


def insert_bookings(cur, rows):
    cur.executemany(
        """
        INSERT INTO BOOKING (booking_id, customer_id, booking_date, booking_status, total_price, payment_id)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
        """,
        rows,
    )
    print(f"  [OK] BOOKING: attempted {len(rows)}, inserted {cur.rowcount}")


def insert_reviews(cur, rows):
    cur.executemany(
        """
        INSERT INTO REVIEW (review_id, customer_id, attraction_id, rating, comment, review_date)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
        """,
        rows,
    )
    print(f"  [OK] REVIEW: attempted {len(rows)}, inserted {cur.rowcount}")


def insert_bookingtickets(cur, rows):
    cur.executemany(
        """
        INSERT INTO BOOKINGTICKET (quantity, booking_id, ticket_id)
        VALUES (%s, %s, %s)
        ON CONFLICT DO NOTHING
        """,
        rows,
    )
    print(f"  [OK] BOOKINGTICKET: attempted {len(rows)}, inserted {cur.rowcount}")


def main():
    print("Connecting to PostgreSQL...")
    conn = get_connection()
    conn.autocommit = False
    cur = conn.cursor()

    try:
        print("Connected successfully")
        print(f"Row target per table: {DEFAULT_ROWS}")

        if RESET_TABLES:
            truncate_tables(cur)

        start_customer_id = get_next_id(cur, "CUSTOMER", "customer_id")
        start_attraction_id = get_next_id(cur, "ATTRACTION", "attraction_id")
        start_ticket_id = get_next_id(cur, "TICKET", "ticket_id")
        start_booking_id = get_next_id(cur, "BOOKING", "booking_id")
        start_payment_id = get_next_id(cur, "PAYMENT", "payment_id")
        start_review_id = get_next_id(cur, "REVIEW", "review_id")

        booking_ids = list(range(start_booking_id, start_booking_id + DEFAULT_ROWS))

        customers = generate_customers(DEFAULT_ROWS, start_customer_id)
        attractions = generate_attractions(DEFAULT_ROWS, start_attraction_id)
        tickets = generate_tickets(attractions, start_ticket_id)
        payments = generate_payments(booking_ids, start_payment_id)
        bookings = generate_bookings(customers, payments, booking_ids)
        reviews = generate_reviews(customers, attractions, start_review_id)
        bookingtickets = generate_bookingtickets(bookings, tickets)

        print("Inserting generated data (FK-safe order):")
        insert_customers(cur, customers)
        insert_attractions(cur, attractions)
        insert_tickets(cur, tickets)
        insert_payments(cur, payments)
        insert_bookings(cur, bookings)
        insert_reviews(cur, reviews)
        insert_bookingtickets(cur, bookingtickets)

        conn.commit()
        print("All data committed successfully")

    except Exception as exc:
        conn.rollback()
        print(f"Error. Transaction rolled back. Details: {exc}")

    finally:
        cur.close()
        conn.close()
        print("Connection closed")


if __name__ == "__main__":
    main()
