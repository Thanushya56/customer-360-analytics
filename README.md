# 🚀 Customer 360 Analytics & Segmentation System

## 📌 Overview

This project builds a complete **Customer 360 Analytics system** by integrating transactional data, performing advanced customer segmentation, analyzing churn behavior, and visualizing insights through an interactive dashboard.

The goal is to help businesses **understand customers, reduce churn, and maximize revenue** using data-driven insights.

---

## 🎯 Problem Statement

Customer data is often scattered across multiple systems (transactions, behavior, support, etc.), making it difficult to:

* Understand customer value
* Identify at-risk users
* Improve retention strategies

This project solves that by creating a **unified customer view** and applying analytics techniques like:

* RFM Segmentation
* Churn Analysis
* Cohort Retention Analysis

---

## 🛠️ Tech Stack

| Category      | Tools Used                  |
| ------------- | --------------------------- |
| Programming   | Python (Pandas, SQLAlchemy) |
| Database      | PostgreSQL                  |
| Analytics     | SQL (RFM, Cohort Analysis)  |
| Visualization | Power BI                    |
| Dataset       | UCI Online Retail II        |

---

## ⚙️ Project Architecture

```text
Excel Dataset → Python ETL → PostgreSQL → SQL Transformations → Power BI Dashboard
```

---

## 📊 Dashboard Preview

### 🔹 Overview Dashboard

![Overview](screenshots/Overview.png)

**Key Insights:**

* Total Customers: 5,878
* Total Revenue: 17.74M
* Churn Rate: ~50%
* Champions contribute the highest revenue

---

### 🔹 Customer Segmentation (RFM)

![Segments](screenshots/Segments.png)

**Key Insights:**

* Customers grouped into segments: Champions, Loyal, At Risk, Lost, etc.
* Champions show highest frequency and monetary value
* At-risk customers show declining engagement

---

### 🔹 Churn Analysis

![Churn](screenshots/Churn.png)

**Key Insights:**

* High churn observed in low-frequency segments
* At-risk customers can be targeted for retention campaigns
* Lost revenue due to churn: ~3.47M

---

### 🔹 Cohort Retention Analysis

![Cohort](screenshots/Cohort.png)

**Key Insights:**

* Retention drops significantly after Month 3
* Best-performing cohort: Dec 2011
* Strong early engagement but long-term retention challenges

---

## 🔄 Data Pipeline (ETL)

The pipeline is implemented in Python:

* Load Excel data (multiple sheets)
* Clean and preprocess data
* Convert data types (dates, IDs)
* Remove invalid transactions
* Load data into PostgreSQL

📄 Script: `scripts/load_data.py`

---

## 🧮 SQL Analysis

Key SQL transformations include:

* Customer Profiling (Recency, Frequency, Monetary)
* RFM Scoring
* Customer Segmentation
* Cohort Analysis
* Churn Identification

📄 File: `sql/transformations.sql`

---

## 📁 Project Structure

```text
customer-360-analytics/
│
├── data/
│   └── sample_data.csv
│
├── scripts/
│   └── load_data.py
│
├── sql/
│   └── transformations.sql
│
├── dashboard/
│   └── customer360.pbix
│
├── screenshots/
│   ├── overview.png
│   ├── segments.png
│   ├── churn.png
│   └── cohort.png
│
├── README.md
├── requirements.txt
└── .gitignore
```

---

## ▶️ How to Run

### 1️⃣ Install dependencies

```bash
pip install -r requirements.txt
```

### 2️⃣ Set database connection

```bash
setx DB_URL "postgresql://username:password@localhost:5432/customer360"
```

### 3️⃣ Run ETL pipeline

```bash
python scripts/load_data.py
```

---

## 📌 Dataset

* **Source:** UCI Machine Learning Repository
* **Name:** Online Retail II Dataset
* **Size:** 1M+ transactions
* **Period:** 2009–2011

---

## 💡 Key Learnings

* Data cleaning and preprocessing at scale
* Building ETL pipelines using Python
* Writing advanced SQL queries for analytics
* Implementing RFM segmentation
* Performing cohort and churn analysis
* Designing business-focused dashboards

---

## 📈 Business Impact

* Identified high-value customer segments
* Highlighted churn patterns and risk groups
* Provided actionable insights for retention strategies
* Enabled data-driven decision making

---

## 👩‍💻 Author

**Thanushya**

---

## ⭐ If you found this useful

Give this repo a ⭐ on GitHub!
# customer-360-analytics
fcecd265927f50ac29115084d4dfcef3b83da2db
