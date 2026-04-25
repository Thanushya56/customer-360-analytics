-- ============================================================
-- STEP 1: CREATE CLEAN TRANSACTIONS TABLE
-- ============================================================
CREATE TABLE clean_transactions AS
SELECT *
FROM raw_transactions
WHERE
    customer_id IS NOT NULL
    AND quantity > 0
    AND price > 0
    AND invoice NOT LIKE 'C%';

-- Add total_amount column
ALTER TABLE clean_transactions ADD COLUMN total_amount NUMERIC;
UPDATE clean_transactions SET total_amount = quantity * price;

SELECT COUNT(*) AS clean_row_count FROM clean_transactions;
-- Expected: around 800,000 rows


-- ============================================================
-- STEP 2: CREATE CUSTOMER PROFILES
-- (Using dataset's own max date — NOT today's date)
-- ============================================================
CREATE TABLE customer_profiles AS
SELECT
    customer_id,

    (SELECT MAX(invoice_date::date) 
     FROM clean_transactions)
     - MAX(invoice_date::date)             AS recency_days,

    COUNT(DISTINCT invoice)                AS frequency,
    ROUND(SUM(total_amount)::numeric, 2)   AS monetary,
    COUNT(DISTINCT stock_code)             AS unique_products_bought,
    MAX(invoice_date)                      AS last_purchase_date,
    MIN(invoice_date)                      AS first_purchase_date,
    COUNT(DISTINCT country)                AS countries_bought_from

FROM clean_transactions
GROUP BY customer_id;

SELECT COUNT(*) AS total_customers FROM customer_profiles;
-- Expected: around 5,000 customers

-- Quick sanity check on recency
SELECT
    MIN(recency_days)          AS min_days,
    MAX(recency_days)          AS max_days,
    ROUND(AVG(recency_days),0) AS avg_days
FROM customer_profiles;
-- min should be 0, max around 300-370


-- ============================================================
-- STEP 3: RFM SCORING
-- ============================================================
CREATE TABLE rfm_scores AS
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,

    -- Lower recency = bought recently = better score
    NTILE(5) OVER (ORDER BY recency_days DESC)  AS r_score,

    -- Higher frequency = buys more often = better score
    NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,

    -- Higher monetary = spends more = better score
    NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score

FROM customer_profiles;

SELECT * FROM rfm_scores LIMIT 5;


-- ============================================================
-- STEP 4: CUSTOMER SEGMENTATION
-- ============================================================
CREATE TABLE customer_segments AS
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS total_rfm_score,

    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
            THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3
            THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2
            THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3
            THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2
            THEN 'Lost Customers'
        ELSE
            'Potential Loyalists'
    END AS segment

FROM rfm_scores;

-- Check all segments appeared
SELECT
    segment,
    COUNT(*)                       AS customer_count,
    ROUND(AVG(monetary), 2)        AS avg_spend,
    ROUND(AVG(recency_days), 0)    AS avg_days_since_purchase
FROM customer_segments
GROUP BY segment
ORDER BY customer_count DESC;


-- ============================================================
-- STEP 5: COHORT ANALYSIS
-- ============================================================
WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(invoice_date)) AS cohort_month
    FROM clean_transactions
    GROUP BY customer_id
),
monthly_activity AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', invoice_date) AS activity_month
    FROM clean_transactions
    GROUP BY customer_id, DATE_TRUNC('month', invoice_date)
)
SELECT
    f.cohort_month,
    COUNT(DISTINCT f.customer_id)  AS cohort_size,

    COUNT(DISTINCT CASE WHEN m.activity_month = f.cohort_month
        THEN m.customer_id END)    AS month_0,

    COUNT(DISTINCT CASE WHEN m.activity_month = f.cohort_month
        + INTERVAL '1 month'
        THEN m.customer_id END)    AS month_1,

    COUNT(DISTINCT CASE WHEN m.activity_month = f.cohort_month
        + INTERVAL '3 months'
        THEN m.customer_id END)    AS month_3,

    COUNT(DISTINCT CASE WHEN m.activity_month = f.cohort_month
        + INTERVAL '6 months'
        THEN m.customer_id END)    AS month_6

FROM first_purchase f
LEFT JOIN monthly_activity m ON f.customer_id = m.customer_id
GROUP BY f.cohort_month
ORDER BY f.cohort_month;


-- ============================================================
-- STEP 6: CHURN FLAGGING
-- ============================================================
ALTER TABLE customer_segments ADD COLUMN churn_flag VARCHAR(20);

UPDATE customer_segments
SET churn_flag =
    CASE
        WHEN recency_days > 90 THEN 'Churned'
        WHEN recency_days > 30 THEN 'At Risk of Churn'
        ELSE                        'Active'
    END;

-- Final summary
SELECT
    churn_flag,
    COUNT(*)                    AS customers,
    ROUND(AVG(monetary), 2)     AS avg_lifetime_value,
    ROUND(AVG(recency_days), 0) AS avg_days_since_purchase
FROM customer_segments
GROUP BY churn_flag
ORDER BY customers DESC;

-- -----------------------------------------------------------------------------
-- One last SQL query to run before the dashboard
-- This gives you a beautiful complete summary — perfect for your dashboard and screenshots:
------------------------------------------------------------------------------------------
-- Complete business summary
SELECT
    cs.segment,
    cs.churn_flag,
    COUNT(*)                        AS total_customers,
    ROUND(AVG(cs.monetary), 2)      AS avg_lifetime_spend,
    ROUND(SUM(cs.monetary), 2)      AS total_revenue,
    ROUND(AVG(cs.frequency), 1)     AS avg_orders,
    ROUND(AVG(cs.recency_days), 0)  AS avg_days_since_purchase

FROM customer_segments cs
GROUP BY cs.segment, cs.churn_flag
ORDER BY total_revenue DESC;