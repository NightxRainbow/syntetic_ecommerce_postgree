/*
Q3.1: Month-over-month growth. Build a CTE of monthly revenue, then use LAG() to show the previous month’s revenue, the % change,
 and a 3-month moving average (AVG() OVER (... ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)). 
 Which months had negative growth?

Q3.2: Running total and top customers. For each customer, compute lifetime revenue, 
then use SUM() OVER (ORDER BY revenue DESC) for a cumulative share. 
What percentage of customers produce 80% of revenue? (Pareto check.)
Bonus: use NTILE(10) to split customers into deciles.

Q3.3: Repeat-purchase behavior. For each customer, 
use LAG(order_date) to find the days between consecutive orders. 
Show the average gap by loyalty_tier. Do higher tiers actually buy more often?

Q3.4: Best product per category. Use RANK() or ROW_NUMBER() with PARTITION BY category to get the 
top 3 products by revenue in each category. 
Then add a subquery that flags products whose return rate is above their category’s average.

Q3.5: Capstone, “at-risk” customers. Using CTEs, find customers who ordered 3+ times, 
but whose last order was more than 180 days before the dataset’s MAX(order_date). Show their lifetime value, 
favorite category (ROW_NUMBER trick), and whether they have marketing_opt_in = 1. 
The CEO wants this list for a win-back campaign.
*/

--q3.1
WITH monthly AS (
  SELECT date_trunc('month', order_date)::date AS month,
         SUM(total_amount) AS revenue
  FROM bronze.orders
  WHERE status <> 'cancelled'
  GROUP BY 1
),
growth AS (
  SELECT month, revenue,
         LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
         LEAD(revenue) OVER (ORDER BY month) AS next_revenue,
         ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
               / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2) AS mom_pct,
         ROUND(AVG(revenue) OVER (ORDER BY month
               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS ma_3m,
        FIRST_VALUE(revenue) OVER (ORDER BY month
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)       AS first_month,
        LAST_VALUE(revenue)  OVER (ORDER BY month
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)       AS last_month
  FROM monthly
)
SELECT * FROM growth ORDER BY month;
