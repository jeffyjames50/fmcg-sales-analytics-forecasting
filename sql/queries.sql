-- =========================================
-- FMCG SALES ANALYTICS - ADVANCED SQL KPI QUERIES
-- =========================================

-- 1. OVERALL BUSINESS KPIs
-- Total revenue, transactions, avg order value, total units sold

SELECT
    ROUND(SUM(revenue)::numeric, 2) AS total_revenue,
    COUNT(*) AS total_transactions,
    ROUND(AVG(revenue)::numeric, 2) AS avg_transaction_value,
    SUM(units_sold) AS total_units_sold
FROM sales;

-- =========================================

-- 2. MONTHLY REVENUE + MOM GROWTH (WINDOW FUNCTION)

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(revenue) AS revenue
    FROM sales
    GROUP BY 1
),

growth AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS prev_revenue
    FROM monthly_sales
)

SELECT
    month,

    ROUND(revenue::numeric, 2) AS revenue,

    ROUND((revenue - prev_revenue)::numeric, 2) AS mom_change,

    ROUND(
        (
            (revenue - prev_revenue)
            / NULLIF(prev_revenue, 0)
        )::numeric * 100,
        2
    ) AS mom_growth_percent

FROM growth
ORDER BY month;

-- =========================================

-- 3. TOP PRODUCTS WITH RANKING

WITH product_revenue AS (
    SELECT
        p.product_name,
        SUM(s.revenue) AS revenue
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY p.product_name
)

SELECT
    product_name,
    ROUND(revenue::numeric, 2) AS revenue,
    RANK() OVER (ORDER BY revenue DESC) AS rank
FROM product_revenue;

-- =========================================

-- 4. TOP PRODUCT PER REGION (ADVANCED PARTITION RANKING)

WITH region_product AS (
    SELECT
        st.region,
        p.product_name,
        SUM(s.revenue) AS revenue
    FROM sales s
    JOIN stores st ON s.store_id = st.store_id
    JOIN products p ON s.product_id = p.product_id
    GROUP BY st.region, p.product_name
),

ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY region ORDER BY revenue DESC) AS rnk
    FROM region_product
)

SELECT
    region,
    product_name,
    ROUND(revenue::numeric, 2) AS revenue
FROM ranked
WHERE rnk = 1;

-- =========================================

-- 5. RUNNING TOTAL REVENUE (CUMULATIVE GROWTH)

SELECT
    sale_date,
    SUM(revenue) AS daily_revenue,
    SUM(SUM(revenue)) OVER (ORDER BY sale_date) AS running_total_revenue
FROM sales
GROUP BY sale_date
ORDER BY sale_date;

-- =========================================

-- 6. MOVING AVERAGE (4-DAY SMOOTHED TREND)

SELECT
    sale_date,
    SUM(revenue) AS daily_revenue,
    AVG(SUM(revenue)) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS moving_avg_4_days
FROM sales
GROUP BY sale_date
ORDER BY sale_date;

-- =========================================

-- 7. CATEGORY REVENUE SHARE (% CONTRIBUTION)

SELECT
    p.category,
    SUM(s.revenue) AS category_revenue,

    ROUND(
        (
            (SUM(s.revenue)::numeric
            / SUM(SUM(s.revenue)) OVER ()::numeric
            ) * 100
        ),
        2
    ) AS revenue_share_percent

FROM sales s
JOIN products p
    ON s.product_id = p.product_id

GROUP BY p.category
ORDER BY category_revenue DESC;

-- =========================================

-- 8. STORE PERFORMANCE RANKING

SELECT
    st.store_name,
    SUM(s.revenue) AS revenue,
    RANK() OVER (ORDER BY SUM(s.revenue) DESC) AS store_rank
FROM sales s
JOIN stores st ON s.store_id = st.store_id
GROUP BY st.store_name;

-- =========================================