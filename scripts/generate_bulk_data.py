import argparse
import csv
import random
from datetime import date, timedelta
from pathlib import Path


COUNTRIES = [
    "Israel", "USA", "UK", "France", "Germany", "Italy", "Spain", "Canada", "Japan", "Brazil"
]
ATTRACTION_CATEGORIES = ["Museum", "Nature", "Food", "Tour", "Water", "History", "Culture", "Adventure"]
BOOKING_STATUSES = ["PAID", "CONFIRMED", "COMPLETED"]
TICKET_TYPES = ["REGULAR", "VIP", "FAMILY", "STUDENT"]


def random_phone(index: int) -> str:
    # Keep fixed 10-digit formatting for VARCHAR(10).
    return f"05{index % 100000000:08d}"[:10]


def build_customer_row(i: int):
    first = f"First{i}"
    last = f"Last{i}"
    return [
        first[:20],
        f"user{i}@example.com"[:50],
        random_phone(i),
        i,
        last[:20],
        f"Pwd{i:06d}"[:20],
        COUNTRIES[i % len(COUNTRIES)][:20],
    ]


def build_attraction_row(i: int):
    category = ATTRACTION_CATEGORIES[i % len(ATTRACTION_CATEGORIES)]
    return [
        i,
        f"Attr{i}"[:20],
        f"City{i % 200}"[:20],
        f"Attraction number {i} in category {category}",
        f"{8 + (i % 6):02d}:00:00",
        category[:20],
        round(30 + (i % 300) * 0.75, 2),
    ]


def build_payment_row(i: int):
    return [
        i,
        i,
        round(40 + (i % 400) * 0.9, 2),
    ]


def build_booking_row(i: int):
    start = date(2025, 1, 1)
    booking_day = start + timedelta(days=(i % 365))
    return [
        i,
        i,
        booking_day.isoformat(),
        BOOKING_STATUSES[i % len(BOOKING_STATUSES)],
        round(40 + (i % 400) * 0.9, 2),
        i,
    ]


def build_ticket_row(i: int):
    valid = date(2026, 4, 1) + timedelta(days=(i % 60))
    return [
        i,
        i,
        round(30 + (i % 300) * 0.75, 2),
        valid.isoformat(),
        TICKET_TYPES[i % len(TICKET_TYPES)][:20],
        100 + (i % 900),
    ]


def build_review_row(i: int):
    review_day = date(2026, 1, 1) + timedelta(days=(i % 90))
    return [
        i,
        i,
        i,
        round(3 + (i % 20) * 0.1, 1),
        f"Review text for attraction {i}"[:100],
        review_day.isoformat(),
    ]


def build_bookingticket_row(i: int):
    return [
        1 + (i % 5),
        i,
        i,
    ]


def write_csv(path: Path, header, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)


def generate_csv(output_dir: Path, counts):
    write_csv(
        output_dir / "customer.csv",
        ["first_name", "email", "phone", "customer_id", "last_name", "password", "country"],
        (build_customer_row(i) for i in range(1, counts["customer"] + 1)),
    )
    write_csv(
        output_dir / "attraction.csv",
        ["attraction_id", "name", "location", "description", "opening_hours", "category", "price"],
        (build_attraction_row(i) for i in range(1, counts["attraction"] + 1)),
    )
    write_csv(
        output_dir / "payment.csv",
        ["payment_id", "booking_id", "amount"],
        (build_payment_row(i) for i in range(1, counts["payment"] + 1)),
    )
    write_csv(
        output_dir / "booking.csv",
        ["booking_id", "customer_id", "booking_date", "booking_status", "total_price", "payment_id"],
        (build_booking_row(i) for i in range(1, counts["booking"] + 1)),
    )
    write_csv(
        output_dir / "ticket.csv",
        ["ticket_id", "attraction_id", "price", "valid_date", "ticket_type", "available_quantity"],
        (build_ticket_row(i) for i in range(1, counts["ticket"] + 1)),
    )
    write_csv(
        output_dir / "review.csv",
        ["review_id", "customer_id", "attraction_id", "rating", "comment", "review_date"],
        (build_review_row(i) for i in range(1, counts["review"] + 1)),
    )
    write_csv(
        output_dir / "bookingticket.csv",
        ["quantity", "booking_id", "ticket_id"],
        (build_bookingticket_row(i) for i in range(1, counts["bookingticket"] + 1)),
    )


def generate_sql_inserts(sql_output: Path, counts):
    sql_output.parent.mkdir(parents=True, exist_ok=True)
    with sql_output.open("w", encoding="utf-8") as f:
        f.write("-- Generated INSERT file\\n")

        for i in range(1, counts["customer"] + 1):
            row = build_customer_row(i)
            f.write(
                "INSERT INTO CUSTOMER (first_name, email, phone, customer_id, last_name, password, country) "
                f"VALUES ('{row[0]}', '{row[1]}', '{row[2]}', {row[3]}, '{row[4]}', '{row[5]}', '{row[6]}');\\n"
            )

        for i in range(1, counts["attraction"] + 1):
            row = build_attraction_row(i)
            f.write(
                "INSERT INTO ATTRACTION (attraction_id, name, location, description, opening_hours, category, price) "
                f"VALUES ({row[0]}, '{row[1]}', '{row[2]}', '{row[3]}', '{row[4]}', '{row[5]}', {row[6]});\\n"
            )

        for i in range(1, counts["payment"] + 1):
            row = build_payment_row(i)
            f.write(
                "INSERT INTO PAYMENT (payment_id, booking_id, amount) "
                f"VALUES ({row[0]}, {row[1]}, {row[2]});\\n"
            )

        for i in range(1, counts["booking"] + 1):
            row = build_booking_row(i)
            f.write(
                "INSERT INTO BOOKING (booking_id, customer_id, booking_date, booking_status, total_price, payment_id) "
                f"VALUES ({row[0]}, {row[1]}, '{row[2]}', '{row[3]}', {row[4]}, {row[5]});\\n"
            )

        for i in range(1, counts["ticket"] + 1):
            row = build_ticket_row(i)
            f.write(
                "INSERT INTO TICKET (ticket_id, attraction_id, price, valid_date, ticket_type, available_quantity) "
                f"VALUES ({row[0]}, {row[1]}, {row[2]}, '{row[3]}', '{row[4]}', {row[5]});\\n"
            )

        for i in range(1, counts["review"] + 1):
            row = build_review_row(i)
            f.write(
                "INSERT INTO REVIEW (review_id, customer_id, attraction_id, rating, comment, review_date) "
                f"VALUES ({row[0]}, {row[1]}, {row[2]}, {row[3]}, '{row[4]}', '{row[5]}');\\n"
            )

        for i in range(1, counts["bookingticket"] + 1):
            row = build_bookingticket_row(i)
            f.write(
                "INSERT INTO BOOKINGTICKET (quantity, booking_id, ticket_id) "
                f"VALUES ({row[0]}, {row[1]}, {row[2]});\\n"
            )


def main():
    parser = argparse.ArgumentParser(description="Generate bulk data for DBProject tables")
    parser.add_argument("--mode", choices=["csv", "sql"], default="csv", help="Output format")
    parser.add_argument(
        "--output-dir",
        default="init-db/generated-data",
        help="Directory for CSV output or directory containing SQL output",
    )
    parser.add_argument(
        "--sql-output",
        default="init-db/generated-data/generated_inserts.sql",
        help="Target SQL file when mode=sql",
    )

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

    if args.mode == "csv":
        generate_csv(Path(args.output_dir), counts)
        print(f"CSV files generated under: {args.output_dir}")
    else:
        generate_sql_inserts(Path(args.sql_output), counts)
        print(f"SQL insert file generated at: {args.sql_output}")


if __name__ == "__main__":
    random.seed(42)
    main()
