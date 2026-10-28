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

DROP TABLE IF EXISTS gold.orders_growthyearly;
CREATE TABLE gold.orders_growthyearly AS
WITH yearly AS(
       SELECT
              date_trunc('year', order_date)::date as year,
              SUM(total_amount) as yearlyrevenue
       FROM bronze.orders
       WHERE status <> 'cancelled'
       GROUP BY 1
),
growthyearly as (
       SELECT year, yearlyrevenue,
              LAG(yearlyrevenue) OVER(ORDER BY year)as lastyear_rev,
              LEAD(yearlyrevenue) OVER(ORDER BY year)as nextyear_rev,
              ROUND(100.00 * (yearlyrevenue - LAG(yearlyrevenue) OVER(ORDER BY year)) /
                     NULLIF(LAG(yearlyrevenue) OVER(ORDER BY year), 0),2) AS yearoveryear_pct,
              ROUND(AVG(yearlyrevenue) OVER(ORDER BY year ROWS BETWEEN 1 PRECEDING AND CURRENT ROW), 2) AS yearaverage_2yearseach,
              FIRST_VALUE(yearlyrevenue) OVER(ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS firstyear,
              LAST_VALUE(yearlyrevenue) OVER (ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lastyear
       FROM yearly
)
SELECT * FROM growthyearly ORDER BY year;

SELECT * from gold.orders_growthyearly;


DROP TABLE IF EXISTS gold.orders_growthmonthly;
CREATE TABLE gold.orders_growthmonthly AS
WITH monthly AS (
       SELECT date_trunc('month', order_date)::date AS month,
              SUM(total_amount) AS monthlyrevenue
       FROM bronze.orders
       WHERE status <> 'cancelled'
       GROUP BY 1
),
growthmonth AS (
       SELECT month, monthlyrevenue,
              LAG(monthlyrevenue) OVER (ORDER BY month) AS prevmonth_revenue,
              LEAD(monthlyrevenue) OVER (ORDER BY month) AS nextmonth_revenue,
              ROUND(100.0 * (monthlyrevenue - LAG(monthlyrevenue) OVER (ORDER BY month))/ 
                     NULLIF(LAG(monthlyrevenue) OVER (ORDER BY month), 0), 2) AS monthovermonth_pct,
              ROUND(AVG(monthlyrevenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS monthaverage_3montheach,
              FIRST_VALUE(monthlyrevenue) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)   AS first_month,
              LAST_VALUE(monthlyrevenue)  OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)  AS last_month
       FROM monthly
)
SELECT * FROM growthmonth ORDER BY month;

SELECT * FROM gold.orders_growthmonthly

/*
THE lOGIC
monthly--

this is advanced cte, so what its do, its create 2 window for a funct name monthly and growth that shows the monthly revenue growth. we can use subqueries on this but its actualy so confusing to read so let me explain this
1. create window monthly: select the per year date ( not use YEAR() bcs its just return the numbers not the actual date ) as month, sum the total amount ( for each rows created ) as monthlyrevenue,
from bronze.order table where the order status is not(<>) canceled and group it by the first select value.
2. create windows growthmonth: select month(from window month), monthly revenue ( from window month too), Search the last monthlyrev over(row by row its need to use bcs if not last row we serach will need to be gruped by monthly revenue and its result is only groupped per rev but if we use over(order by)) it will recognize the last value bcs it return the row(n) 
and order it by month as prev_month revenue,
search the next monthlyrev over(row by row ) order by month as nextmonth revenue, round<by 2 0 before ,> 100.00 * (monthlyrev(current row) - the last month value(its ordered already by month and over) devided by null if(the last month value , if not have last month value devided by 0)
<so its check the current row, if the current row has more rev than lasmonth then the pct of the month over month is positive otherwise its will return negative>
,round<by 2 0 before ,> average of monthly value over( order row by month-- the row that its between 2 row before current row and current row<so its will return 3 month (now, 1st last month, and 2nd last month))

*/