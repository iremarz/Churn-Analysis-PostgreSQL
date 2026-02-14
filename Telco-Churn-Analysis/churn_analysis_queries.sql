-- Database: PostgreSQL (Neon.tech)
-- Dataset: Telco Customer Churn

SELECT COUNT(*) FROM telco_customers;

SELECT *
FROM telco_customers
LIMIT 10;

SELECT
    churn,
    COUNT(*)
FROM telco_customers
GROUP BY 1;

-- Genel churn oranı yüzde kaçtır?
-- What is the overall churn rate?
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percentage
FROM telco_customers;

-- Sözleşme türüne göre churn oranı nasıl değişiyor?
-- How does the churn rate vary by contract type?
SELECT
    contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2 ) AS churn_rate_percentage
FROM telco_customers
GROUP BY contract
ORDER BY churn_rate_percentage DESC;

-- Monthly_charges arttıkça churn artıyor mu?
-- Does the churn rate increase as monthly charges increase?
SELECT
    churn,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge
FROM telco_customers
GROUP BY 1;

-- Gender'a göre churn oranı nasıl değişiyor?
-- How does the churn rate vary by gender?
SELECT
    gender,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2 ) AS churn_rate_percentage
FROM telco_customers
GROUP BY gender
ORDER BY churn_rate_percentage DESC;

-- Sadece month-to-month müşteriler için aylık ücrete göre churn oranı nasıldır?
-- What is the churn rate by monthly charges for month-to-month customers only?
SELECT
    CASE
        WHEN monthly_charges < 40 THEN 'Low'
        WHEN monthly_charges BETWEEN 40 AND 80 THEN 'Medium'
        ELSE 'High'
    END AS charge_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2 ) AS churn_rate_percentage
FROM telco_customers
WHERE contract = 'month-to-month'
GROUP BY charge_segment
ORDER BY churn_rate_percentage DESC;

-- Churn eden müşterilerin ortalama tenure'u churn etmeyenlere göre nasıldır?
-- What is the average tenure of churned customers compared to non-churned customers?
SELECT
    churn,
    COUNT(*) AS total_customers,
    ROUND(AVG(tenure)::numeric, 2) as avg_tenure
FROM telco_customers
GROUP BY churn
ORDER BY churn;

-- Ortalama tenure’dan daha düşük tenure’a sahip churn eden müşteriler kaç kişidir?
-- How many churned customers have a tenure lower than the average tenure?
SELECT
    COUNT(*) AS risky_churned_customers
FROM telco_customers
WHERE churn = 'Yes'
AND tenure < (
               SELECT
                   AVG(tenure) as avg_tenure
               FROM telco_customers
);

-- CTE ile
-- Using CTE
WITH avg_tenure AS (
               SELECT
                   AVG(tenure) as avg_tenure
               FROM telco_customers
)
SELECT
    COUNT(*) AS risky_churned_customers
FROM  telco_customers tc
JOIN avg_tenure at on tc.tenure < at.avg_tenure
WHERE tc.churn = 'Yes';

-- Churn eden müşterilerin ortalama total_charges değeri nedir?
-- How does the churn rate vary by gender?
SELECT
    churn,
    ROUND(AVG(NULLIF(TRIM(total_charges), '')::numeric),2) AS avg_total_charges
FROM telco_customers
GROUP BY churn;

-- Tenure ve monthly_charges birlikte churn’ü nasıl etkiliyor?
-- How do tenure and monthly charges combined affect churn?
WITH segmented_customers AS (
    SELECT
        CASE
            WHEN tenure < 12 THEN 'New'
            WHEN tenure BETWEEN 12 AND 48 THEN 'Mid'
            ELSE 'Loyal'
        END AS tenure_segment,

        CASE
            WHEN monthly_charges < 40 THEN 'Low'
            WHEN monthly_charges BETWEEN 40 AND 80 THEN 'Medium'
            ELSE 'High'
        END AS charge_segment,

        churn

    FROM telco_customers
)

SELECT
    tenure_segment,
    charge_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS churn_rate
FROM segmented_customers
GROUP BY tenure_segment, charge_segment
ORDER BY churn_rate DESC;


-- Her contract tipi içinde müşterileri tenure’a göre büyükten küçüğe sıralayıp sıra numarası verelim.
-- Rank customers by tenure within each contract type using window functions.
SELECT
    contract,
    tenure,
    ROW_NUMBER() OVER (PARTITION BY contract ORDER BY tenure DESC) AS tenure_rank
FROM telco_customers;

-- Her tenure segmenti içinde churn oranı en yüksek olan charge segmenti hangisidir?
-- Which charge segment has the highest churn rate within each tenure segment?
WITH segmented_customers AS (
    SELECT
        CASE
            WHEN tenure < 12 THEN 'New'
            WHEN tenure BETWEEN 12 AND 48 THEN 'Mid'
            ELSE 'Loyal'
        END AS tenure_segment,

        CASE
            WHEN monthly_charges < 40 THEN 'Low'
            WHEN monthly_charges BETWEEN 40 AND 80 THEN 'Medium'
            ELSE 'High'
        END AS charge_segment,

        churn

    FROM telco_customers
),

segment_churn AS (
    SELECT
        tenure_segment,
        charge_segment,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
        ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS churn_rate
    FROM segmented_customers
    GROUP BY tenure_segment, charge_segment
)

SELECT
    *,
    RANK() OVER (PARTITION BY tenure_segment ORDER BY churn_rate DESC) AS risk_rank
FROM segment_churn
ORDER BY tenure_segment, risk_rank;















