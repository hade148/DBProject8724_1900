import argparse
import random
from typing import Iterable, List, Tuple

import psycopg2
from psycopg2.extras import execute_values

from generate_bulk_data import (
    build_attraction_row,
    build_booking_row,
    build_bookingticket_row,
    build_customer_row,
    build_payment_row,
    build_review_row,
    build_ticket_row,
)


def chunked_rows(generator: Iterable[List], chunk_size: int):
    chunk = []
    for row in generator:
        chunk.append(tuple(row))
        if len(chunk) >= chunk_size:
            yield chunk
            chunk = []
    if chunk:
        yield chunk


def insert_table(cur, table: str, columns: str, rows: Iterable[List], chunk_size: int):
    sql = f"INSERT INTO {table} ({columns}) VALUES %s"
    total = 0
    for chunk in chunked_rows(rows, chunk_size):
        execute_values(cur, sql, chunk)
        total += len(chunk)
    return total


def maybe_truncate(cur):
    cur.execute(
        "TRUNCATE TABLE BOOKINGTICKET, REVIEW, BOOKING, TICKET, PAYMENT, ATTRACTION, CUSTOMER RESTART IDENTITY CASCADE"
    )


def main():
    parser = argparse.ArgumentParser(description="Insert bulk data directly into PostgreSQL")
    parser.add_argument("--db-host", default="localhost")
    parser.add_argument("--db-port", type=int, default=5432)
    parser.add_argument("--db-name", required=True)
    parser.add_argument("--db-user", required=True)
    parser.add_argument("--db-password", required=True)
    parser.add_argument("--chunk-size", type=int, default=1000)
    parser.add_argument("--truncate-first", action="store_true")

    parser.add_argument("--customer", type=int, default=20000)
    parser.add_argument("--attraction", type=int, default=20000)
    parser.add_argument("--payment", type=int, default=500)
    parser.add_argument("--booking", type=int, default=500)
    parser.add_argument("--ticket", type=int, default=500)
    parser.add_argument("--review", type=int, default=500)
    parser.add_argument("--bookingticket", type=int, default=500)

    args = parser.parse_args()

    counts = {
        "customer": args.customer,
        "attraction": args.attraction,
        "payment": args.payment,
        "booking": args.booking,
        "ticket": args.ticket,
        "review": args.review,
        "bookingticket": args.bookingticket,
    }

    conn = psycopg2.connect(
        host=args.db_host,
        port=args.db_port,
        dbname=args.db_name,
        user=args.db_user,
        password=args.db_password,
    )
    conn.autocommit = False

    try:
        with conn.cursor() as cur:
            if args.truncate_first:
                maybe_truncate(cur)

            print("Inserting CUSTOMER...")
            inserted = insert_table(
                cur,
                "CUSTOMER",
                "first_name, email, phone, customer_id, last_name, password, country",
                (build_customer_row(i) for i in range(1, counts["customer"] + 1)),
                args.chunk_size,
            )
            print(f"Inserted CUSTOMER: {inserted}")

            print("Inserting ATTRACTION...")
            inserted = insert_table(
                cur,
                "ATTRACTION",
                "attraction_id, name, location, description, opening_hours, category, price",
                (build_attraction_row(i) for i in range(1, counts["attraction"] + 1)),
                args.chunk_size,
            )
            print(f"Inserted ATTRACTION: {inserted}")

            print("Inserting PAYMENT...")
            inserted = insert_table(
                cur,
                "PAYMENT",
                "payment_id, booking_id, amount",
                (build_payment_row(i) for i in range(1, counts["payment"] + 1)),
                args.chunk_size,
            )
            print(f"Inserted PAYMENT: {inserted}")

            print("Inserting BOOKING...")
            inserted = insert_table(
                cur,
                "BOOKING",
                "booking_id, customer_id, booking_date, booking_status, total_price, payment_id",
                (build_booking_row(i) for i in range(1, counts["booking"] + 1)),
                args.chunk_size,
            )
            print(f"Inserted BOOKING: {inserted}")

            print("Inserting TICKET...")
            inserted = insert_table(
                cur,
                "TICKET",
                "ticket_id, attraction_id, price, valid_date, ticket_type, available_quantity",
                (build_ticket_row(i) for i in range(1, counts["ticket"] + 1)),
                args.chunk_size,
            )
            print(f"Inserted TICKET: {inserted}")

            print("Inserting REVIEW...")
            inserted = insert_table(
                cur,
                "REVIEW",
                "review_id, customer_id, attraction_id, rating, comment, review_date",
                (build_review_row(i) for i in range(1, counts["review"] + 1)),
                args.chunk_size,
            )
            print(f"Inserted REVIEW: {inserted}")

            print("Inserting BOOKINGTICKET...")
            inserted = insert_table(
                cur,
                "BOOKINGTICKET",
                "quantity, booking_id, ticket_id",
                (build_bookingticket_row(i) for i in range(1, counts["bookingticket"] + 1)),
                args.chunk_size,
            )
            print(f"Inserted BOOKINGTICKET: {inserted}")

        conn.commit()
        print("All inserts committed successfully.")
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    random.seed(42)
    main()
