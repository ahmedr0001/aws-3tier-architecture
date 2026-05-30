import os

from flask import Flask, jsonify
import psycopg2
from psycopg2 import OperationalError

app = Flask(__name__)

TIER_NAME = "Backend (Python API — Private Subnet)"


@app.route("/api/status", methods=["GET"])
def api_status():
    db_host = os.environ.get("DB_HOST")
    db_name = os.environ.get("DB_NAME")
    db_user = os.environ.get("DB_USER")
    db_pass = os.environ.get("DB_PASS")

    payload = {
        "tier": TIER_NAME,
        "database_connected": False,
        "message": None,
    }

    missing = [
        key
        for key, val in (
            ("DB_HOST", db_host),
            ("DB_NAME", db_name),
            ("DB_USER", db_user),
            ("DB_PASS", db_pass),
        )
        if not val
    ]
    if missing:
        payload["message"] = f"Missing environment variable(s): {', '.join(missing)}"
        return jsonify(payload), 200

    try:
        conn = psycopg2.connect(
            host=db_host,
            dbname=db_name,
            user=db_user,
            password=db_pass,
            connect_timeout=5,
        )
        try:
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT message FROM test_table ORDER BY id LIMIT 1;"
                )
                row = cur.fetchone()
            payload["database_connected"] = True
            payload["message"] = row[0] if row else "Connected; test_table returned no rows."
        finally:
            conn.close()
    except OperationalError as exc:
        payload["message"] = f"Database connection failed: {exc}"
    except Exception as exc:
        payload["message"] = f"Query error: {exc}"

    return jsonify(payload), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
