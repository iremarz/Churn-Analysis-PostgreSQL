# Churn-Analysis-PostgreSQL
A comprehensive data analysis project using PostgreSQL (Neon.tech) to identify key factors behind customer churn and provide actionable business insights.

Project Objective

This project analyzes customer churn behavior using a telecom dataset.
The goal is to identify high-risk customer segments and understand the impact of tenure and pricing on churn.

Technologies Used

PostgreSQL
SQL (CTE, Subquery, Window Functions)
Data Cleaning (TRIM, NULLIF, Casting)
Key Analyses Performed
Overall churn rate calculation
Churn rate by contract type
Churn rate by gender
Average tenure comparison by churn status
Data cleaning for total charges column
Tenure and monthly charge segmentation
Risk ranking using window functions

Key Insights

Overall churn rate: 26.54%
Month-to-month contracts show the highest churn (~42%)
Customers with high monthly charges churn more frequently
Customers with low tenure are more likely to churn
The highest-risk segment identified: New customers with high monthly charges.

Business Interpretation

The analysis suggests that early-stage customers paying high monthly charges are significantly more likely to churn.
Retention strategies should prioritize onboarding experience and pricing incentives for new high-paying customers.
