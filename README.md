# Churn-Analysis-PostgreSQL
A comprehensive data analysis project using PostgreSQL (Neon.tech) to identify key factors behind customer churn and provide actionable business insights.

### Project Objective

This project analyzes customer churn behavior using a telecom dataset.
The goal is to identify high-risk customer segments and understand the impact of tenure and pricing on churn.

### Technologies Used

* **Database:** PostgreSQL (Cloud-hosted via Neon.tech)
* **SQL Power Techniques:**
    * **Advanced Aggregations:** Complex groupings and math to derive precise churn percentages.
    * **Window Functions:** Implemented `RANK()` and `OVER(PARTITION BY...)` for granular risk ranking across segments.
    * **CTE (Common Table Expressions):** Optimized multi-step logic for cleaner and more readable queries.
* **Data Engineering & Cleaning:**
    * **Data Transformation:** Managed string-to-numeric casting and handled dirty data using `NULLIF` and `TRIM`.
    * **Conditional Logic:** Built custom business segments (Tenure & Charge tiers) using `CASE WHEN` statements.
* **Environment:** DataGrip (Professional SQL IDE)

### Key Analyses Performed

* **Overall Metrics:** Calculation of general churn rate.
* **Segment Analysis:** Churn rates by contract type, gender, and tenure.
* **Pricing Impact:** Correlation between monthly charges and churn behavior.
* **Risk Ranking:** Identifying high-risk segments using advanced window functions.
* **Data Prep:** Cleaning the `total_charges` column and handling data type conversions.

### Key Insights

* **Overall Churn Rate:** 26.54%
* **Contract Impact:** Month-to-month contracts show the highest churn (~42%).
* **Tenure Effect:** Customers with low tenure (new customers) are significantly more likely to churn.
* **Pricing Effect:** Customers with high monthly charges churn more frequently.

### Deep Dive: Tenure vs. Charge Segments

| Tenure Segment | Charge Segment | Churn Rate (%) | Risk Rank |
| :--- | :--- | :--- | :--- |
| **New** | **High** | **73.12%** | **1** |
| **Mid** | **High** | **40.14%** | **1** |
| **Loyal** | **High** | **14.25%** | **1** |

### Business Interpretation

The analysis suggests that early-stage customers paying high monthly charges are the most vulnerable group. 
* **Recommendation:** Retention strategies should prioritize onboarding experiences and pricing incentives for new high-paying customers to reduce early-stage churn.
