import pandas as pd
import os
import logging
from sqlalchemy import create_engine

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def load_data():
    try:
        logging.info("📥 Loading Excel data...")

        # Load Excel sheets
        df1 = pd.read_excel("data/online_retail_II.xlsx", sheet_name="Year 2009-2010")
        df2 = pd.read_excel("data/online_retail_II.xlsx", sheet_name="Year 2010-2011")

        # Combine datasets
        df = pd.concat([df1, df2], ignore_index=True)

        logging.info(f"✅ Loaded {df.shape[0]} rows")

        # Rename columns (SQL-friendly)
        df.columns = [
            "invoice", "stock_code", "description",
            "quantity", "invoice_date", "price",
            "customer_id", "country"
        ]

        # Convert data types
        df["invoice_date"] = pd.to_datetime(df["invoice_date"], errors="coerce")
        df["customer_id"] = df["customer_id"].astype("Int64")

        # Data cleaning
        df = df.dropna(subset=["customer_id", "invoice_date"])
        df = df[(df["quantity"] > 0) & (df["price"] > 0)]

        if df.empty:
            raise ValueError("❌ Data is empty after cleaning")

        logging.info(f"🧹 Cleaned data: {df.shape[0]} rows remaining")

        # Get DB connection from environment variable
        db_url = os.getenv("DB_URL")
        if not db_url:
            raise ValueError("❌ DB_URL not set. Please configure environment variable.")

        logging.info("🔗 Connecting to PostgreSQL...")

        # Create engine and upload data
        with create_engine(db_url).begin() as conn:
            logging.info("📤 Uploading data to PostgreSQL...")

            df.to_sql(
                "raw_transactions",
                conn,
                schema="public",
                if_exists="replace",   # change to 'append' for incremental loads
                index=False,
                method="multi",
                chunksize=10000
            )

        logging.info("🎉 Upload successful!")

    except Exception as e:
        logging.exception("❌ Error occurred during data load")


if __name__ == "__main__":
    load_data()