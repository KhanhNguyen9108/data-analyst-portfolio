/* COHORT ANALYSIS: */

with cohort as (
SELECT Customer_ID,
		CAST(DATETRUNC(MONTH,Date) AS date) AS month_order,
		Sales_Amount
FROM scanner_trans),

first_order as (
SELECT Customer_ID,
		MIN(month_order) AS first_month
FROM cohort
GROUP BY Customer_ID),

cohort2 as (
SELECT c.Customer_ID,
		f.first_month,
		c.month_order,
		DATEDIFF(MONTH,f.first_month,c.month_order) AS month_index,
		Sales_Amount
FROM cohort AS c
INNER JOIN first_order AS f
ON c.Customer_ID = f.Customer_ID),

cohort3 as (
SELECT first_month,
		month_index,
		COUNT(DISTINCT(Customer_ID)) AS cust0,
		SUM(Sales_Amount) AS sales0
FROM cohort2
WHERE month_index = 0
GROUP BY first_month, month_index)

-- Customer, Revenue Retention in Number, Percentage:
SELECT c2.first_month,
		c2.month_index,
		COUNT(DISTINCT(c2.Customer_ID)) AS TotalCust,
		SUM(c2.Sales_Amount) AS TotalSales,
		COUNT(DISTINCT(c2.Customer_ID))/c3.cust0 AS PercCust,
		SUM(c2.Sales_Amount)/c3.sales0 AS PercSales
FROM cohort2 AS c2
LEFT JOIN cohort3 AS c3
ON c2.first_month = c3.first_month
GROUP BY c2.first_month, c2.month_index, c3.cust0, c3.sales0
ORDER BY c2.first_month, c2.month_index;

/* RFM Analysis: */
with rfm as (
SELECT Customer_ID,
		CAST(DATE as date) AS Date,
		Transaction_ID,
		Sales_Amount
FROM scanner_trans),

rfm2 as (
SELECT Customer_ID,
		DATEDIFF(DAY,MAX(Date),CAST('2017-01-01' AS date)) AS r_value,
		COUNT(DISTINCT(Transaction_ID)) AS f_value,
		SUM(Sales_Amount) AS m_value
FROM rfm
GROUP BY Customer_ID)

SELECT *,
		r_score*100 + f_score*10 + m_score AS rfm_score
FROM(
SELECT *,
		NTILE(5) OVER(ORDER BY r_value) AS r_score,
		NTILE(5) OVER(ORDER BY f_value) AS f_score,
		NTILE(5) OVER(ORDER BY m_value) AS m_score
FROM rfm2) AS rfm3;






		
