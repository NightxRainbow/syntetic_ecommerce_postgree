/*
Q1.1: How many orders, how much total revenue, and what average order value (AOV) does each sales channel have? Rank channels from highest to lowest revenue.
Use: COUNT, SUM, AVG, GROUP BY, ORDER BY.

Q1.2: Which orders in the last full year had a discount_amount above 10% of subtotal? How many are there per month?
Use: WHERE with a column calculation, GROUP BY on a date part, HAVING.

Q1.3: Which customers are in each loyalty_tier, and what share has marketing_opt_in = 1?
Hint: AVG(marketing_opt_in) gives you the percentage directly.

Q1.4: Which 10 product categories have the highest average gross margin (unit_price - unit_cost), counting only is_active = 1 products?

*/

SELECT * from bronze.orders

--q1.1
DROP TABLE IF EXISTS gold.order_fr_channel;
CREATE TABLE gold.order_fr_channel AS
SELECT
    channel,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS revenue,
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM bronze.orders
GROUP BY channel;   

SELECT * from gold.order_fr_channel

--q1.2
SELECT MAX(order_date) FROM bronze.orders;

DROP TABLE IF EXISTS gold.customers_discounted_newdate;
CREATE TABLE gold.customers_discounted_newdate AS
SELECT 
    order_id,
    date_trunc('month',order_date)::date as month,
    count(*) as "discounted" ,
    discount_amount
    --i do this so the date_trunc not return with time stamp next, if without ::date the return will 2026-10-01 00:00:00
from bronze.orders WHERE discount_amount > 0.10 * subtotal 
  AND order_date > (SELECT MAX(order_date) FROM bronze.orders) - INTERVAL '12 months'
GROUP BY order_id
ORDER BY month desc;
    -- logic : select order id, date(as month), all row from table orders where the discount amount is more than 10% of subtotal and the order_date row that is newer than 12month before the most recent orderdate and group it by the order id and order it by the most newer date
SELECT * from gold.customers_discounted_newdate

--q1.3

DROP TABLE IF EXISTS gold.customers_marketing_optperloyaltytier;
CREATE TABLE gold.customers_marketing_optperloyaltytier AS
select
loyalty_tier,
ROUND(100 * AVG(marketing_opt_in),2) as marketing_percetage,
count(*) as customer
from silver.clean_customers GROUP BY loyalty_tier
    -- logic : select loyalty tier, round the percetage(times 100) of the average marketing_opt_in show 2 numbers after "," as marketing_opt_percentage, count all rows from clean csutomer table group by the loyalty tier

select * from gold.customers_marketing_optperloyaltytier

--q1.4

DROP TABLE IF EXISTS gold.product_activegross;
CREATE TABLE gold.product_activegross AS
select
    category,
    ROUND(AVG(unit_price - unit_cost),2) as "gross"
from silver.products_fillna where is_active = 1
GROUP BY category
ORDER BY gross desc;

SELECT * from gold.product_activegross;

