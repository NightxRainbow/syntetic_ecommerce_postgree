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

SELECT * FROM gold.orders_growthmonthly;

/*
THE lOGIC
monthly--

this is advanced cte, so what its do, its create 2 window for a funct name monthly and growth that shows the monthly revenue growth. we can use subqueries on this but its actualy so confusing to read so let me explain this
open window
1. create window monthly: select the per year date ( not use YEAR() bcs its just return the numbers not the actual date ) as month, sum the total amount ( for each rows created ) as monthlyrevenue,
from bronze.order table where the order status is not(<>) canceled and group it by the first select value.
2. create windows growthmonth: select month(from window month), monthly revenue ( from window month too), Search the last monthlyrev over(row by row its need to use bcs if not last row we serach will need to be gruped by monthly revenue and its result is only groupped per rev but if we use over(order by)) it will recognize the last value bcs it return the row(n) 
and order it by month as prev_month revenue,
search the next monthlyrev over(row by row ) order by month as nextmonth revenue, round<by 2 0 before ,> 100.00 * (monthlyrev(current row) - the last month value(its ordered already by month and over) devided by null if(the last month value , if not have last month value devided by 0)
<so its check the current row, if the current row has more rev than lasmonth then the pct of the month over month is positive otherwise its will return negative>
,round<by 2 0 before ,> average of monthly value over( order row by month-- the row that its between 2 row before current row and current row<so its will return 3 month (now, 1st last month, and 2nd last month))
, get first value of monthrev over( order row by month-- the row that is ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING this mean the row is add everything, why we not just use over(order by month) that was bcs if we do that the value will be the current row )
, get the last value of month rev over ( same as before this )
from window monthly
close window
select all from cte growthmonth and order it by cte month 
*/

-- Q3.2

with cust as (
SELECT customer_id,
       SUM(total_amount) as cust_rev      
FROM bronze.orders
WHERE status <> 'canceled'
GROUP BY customer_id
)
Select customer_id, cust_rev,
       SUM(cust_rev) OVER (order by cust_rev DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) as running_custrev,
       SUM(cust_rev) OVER ( order by cust_rev desc) as running2_rows,
       ROW_NUMBER() OVER (order by cust_rev DESC)as rn,
       COUNT(*) OVER () as countval,
       NTILE(10) OVER (order by cust_rev)
from cust
ORDER BY ROW_NUMBER() OVER (order by cust_rev DESC)
;

-- this is to show that        SUM(cust_rev) OVER (order by cust_rev DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) as running_custrev,
                        --     SUM(cust_rev) OVER ( order by cust_rev desc) as running2_rows,
                        -- is basicly the same things and why i order by desc again? so the order will be asc

WITH cust as (
SELECT customer_id,
       SUM(total_amount) as cust_rev      
       FROM bronze.orders
       WHERE status <> 'canceled'
       GROUP BY customer_id
),
custrank as (
       SELECT customer_id, cust_rev,
       SUM(cust_rev) OVER (order by cust_rev DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) as running_custrev,
       SUM(cust_rev) OVER ( ) as total_custrev,
       ROW_NUMBER() OVER (order by cust_rev DESC)as rn,
       COUNT(*) OVER () as countval,
       NTILE(10) OVER (order by cust_rev) as decile
from cust 
)
SELECT MIN(rn) AS customers_needed_for_80pct,
       MAX(countval) AS total_customers,
       ROUND(100.0 * MIN(rn) / MAX(countval), 1) AS pct_of_customers
FROM custrank
WHERE running_custrev >= 0.8 * total_custrev;

-- Q3.3

SELECT * FROM silver.clean_customers;
SELECT * FROM bronze.orders;

WITH gap as (
       SELECT 
       customer_id, order_date,
       LAG(order_date) OVER ( PARTITION BY customer_id ORDER BY order_date, order_id) as prev_buy
       FROM  bronze.orders WHERE status <> 'canceled'
)
SELECT 
       c.loyalty_tier,
       COUNT(*) as buycount,
       ROUND(AVG(g.order_date - g.prev_buy),1) as avgbuy
FROM gap as g
LEFT JOIN silver.clean_customers as c
ON g.customer_id = c.customer_id
WHERE g.prev_buy IS NOT NULL
GROUP BY c.loyalty_tier
ORDER BY avgbuy;

-- the gaps for each tier is just 1 day gap from plat altheway to none

-- Q.3.4



SELECT * FROM silver.products_fillna;
SELECT * FROM bronze.order_items;
SELECT * FROM bronze.returns;

WITH cat AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,                          
        SUM(oi.line_total)   AS revsum,
        COUNT(oi.order_item_id) AS ordercount,
        COUNT(r.return_id)   AS returncount
    FROM bronze.order_items AS oi
    LEFT JOIN bronze.returns AS r
        ON oi.order_item_id = r.order_item_id
    LEFT JOIN silver.products_fillna AS p
        ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category   
),
scoreret AS (
    SELECT *,
        ROUND(returncount::numeric / NULLIF(ordercount, 0), 2) AS returnrate,
        ROUND(100.00 * returncount / NULLIF(ordercount, 0), 2) AS returnratepct,
        RANK() OVER (PARTITION BY category ORDER BY revsum DESC) AS rankings
    FROM cat
),
cat_avg AS (                                  
    SELECT 
        category,
        SUM(returncount)::numeric / NULLIF(SUM(ordercount), 0) AS avg_returnrate
    FROM cat
    GROUP BY category
)
SELECT 
    s.*,
    (s.returnrate > ca.avg_returnrate) AS above_avg  
FROM scoreret s
JOIN cat_avg ca ON s.category = ca.category           
WHERE s.rankings <= 3
ORDER BY s.category, s.rankings;                        
-- i use  ::numeric for the integer division is not 0

-- q3.5
WITH cust_orders AS (
  SELECT customer_id,
         COUNT(*)          AS n_orders,
         SUM(total_amount) AS ltv,
         MAX(order_date)   AS last_order
  FROM bronze.orders
  WHERE status <> 'cancelled'
  GROUP BY customer_id
),
fav AS (
  SELECT customer_id, category
  FROM (
    SELECT o.customer_id, p.category,
           ROW_NUMBER() OVER (PARTITION BY o.customer_id
                              ORDER BY SUM(oi.line_total) DESC) AS rn
    FROM bronze.orders o
    JOIN bronze.order_items oi ON oi.order_id   = o.order_id
    JOIN silver.products_fillna p     ON p.product_id  = oi.product_id
    WHERE o.status <> 'cancelled'
    GROUP BY o.customer_id, p.category
  ) x
  WHERE rn = 1
)
SELECT c.customer_id, c.first_name, c.last_name,
       co.n_orders, co.ltv, co.last_order,
       f.category AS favorite_category,
       c.marketing_opt_in
FROM cust_orders co
JOIN silver.clean_customers c ON c.customer_id = co.customer_id
LEFT JOIN fav f  ON f.customer_id = co.customer_id
WHERE co.n_orders >= 3
  AND co.last_order < (SELECT MAX(order_date) FROM bronze.orders) - 180
ORDER BY co.ltv DESC;