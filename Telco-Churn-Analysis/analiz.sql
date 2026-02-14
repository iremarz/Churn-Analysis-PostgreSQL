SELECT COUNT(*) FROM telco_customers;

SELECT *
FROM telco_customers
LIMIT 10;

SELECT
    churn,
    COUNT(*)
FROM telco_customers
GROUP BY 1;

--Genel churn oranı yüzde kaç?
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percentage
FROM telco_customers;

--Sözleşme türüne göre churn oranı nasıl değişiyor?
SELECT
    contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2 ) AS churn_rate_percentage
FROM telco_customers
GROUP BY contract
ORDER BY churn_rate_percentage DESC;

--monthly_charges arttıkça churn artıyor mu?
SELECT
    churn,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge
FROM telco_customers
GROUP BY 1;

--gender'a göre churn oranı nasıl değişiyor?
SELECT
    gender,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2 ) AS churn_rate_percentage
FROM telco_customers
GROUP BY gender
ORDER BY churn_rate_percentage DESC;

--Sadece month-to-month müşteriler için aylık ücrete göre churn oranı nasıl?
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
WHERE contract = 'Month-to-month'
GROUP BY charge_segment
ORDER BY churn_rate_percentage DESC;

--churn eden müşterilerin ortalama tenure'u churn etmeyenlere göre nasıldır?
SELECT
    churn,
    COUNT(*) AS total_customers,
    ROUND(AVG(tenure)::numeric, 2) as avg_tenure
FROM telco_customers
GROUP BY churn
ORDER BY churn;

--Ortalama tenure’dan daha düşük tenure’a sahip churn eden müşteriler kaç kişi?
SELECT
    COUNT(*) AS risky_churned_customers
FROM telco_customers
WHERE churn = 'Yes'
AND tenure < (
               SELECT
                   AVG(tenure) as avg_tenure
               FROM telco_customers
);

--CTE ile
WITH avg_tenure AS (
               SELECT
                   AVG(tenure) as avg_tenure
               FROM telco_customers
)
SELECT
    COUNT(*)
FROM  telco_customers tc
JOIN avg_tenure at on tc.tenure < at.avg_tenure
WHERE tc.churn = 'Yes';

--churn eden müşterilerin ortalama total_charges değeri nedir?
SELECT
    churn,
    ROUND(AVG(NULLIF(TRIM(total_charges), '')::numeric),2) AS avg_total_charges
FROM telco_customers
GROUP BY churn;

--tenure ve monthly_charges birlikte churn’ü nasıl etkiliyor?
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


--Her contract tipi içinde müşterileri tenure’a göre büyükten küçüğe sıralayıp sıra numarası verelim.
SELECT
    contract,
    tenure,
    ROW_NUMBER() OVER (PARTITION BY contract ORDER BY tenure DESC) AS tenure_rank
FROM telco_customers;

--Her tenure segmenti içinde churn oranı en yüksek olan charge segmenti hangisi?
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














