/*
Q2.1: Revenue by category. Join order_items → products → orders. For each category and brand, show units sold, total line_total, and gross profit 
(quantity * unit_cost subtracted from the line total). Exclude cancelled orders.
Use: INNER JOIN ×2.

Q2.2: Never-bought customers. List customers who signed up but have no orders, grouped by country. How many are there, and what share of each country’s signups?
Use: LEFT JOIN, WHERE o.order_id IS NULL.

Q2.3: Fulfillment gaps. shipments has fewer rows (83,885) than orders (90,000). Join orders → shipments → payments and show the following by channel:

orders with no shipment
average delivery days (delivered_at - shipped_at)
paid amount vs. order total

Use COALESCE to show “Not shipped” in place of NULL carriers.
Use: LEFT JOIN, COALESCE, date arithmetic.

Q2.4: Return rate by product. Join returns → order_items → products. For each category, show the return rate (returned items ÷ items sold) and the total refund_amount. 
Categories with zero returns should still appear.
Use: LEFT JOIN from order_items, COALESCE(SUM(refund_amount), 0)
*/

--q2.1
SELECT DISTINCT(status) from bronze.orders;

DROP TABLE IF EXISTS gold.revenue_bycategory;
CREATE TABLE gold.revenue_bycategory AS
SELECT
    p.category AS "products category",
    p.brand AS "products brand",
    SUM(oi.line_total) AS revenue,
    SUM(oi.quantity * p.unit_cost) AS cogs,
    SUM(oi.line_total - oi.quantity * p.unit_cost) AS gross_profit
FROM bronze.order_items AS oi
INNER JOIN silver.products_fillna AS p ON oi.product_id = p.product_id
INNER JOIN bronze.orders AS o ON oi.order_id = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY p.category, p.brand;     
-- join tips the left one is the from table that likely will be fk on right table so the right is awlays the from table

SELECT * FROM gold.revenue_bycategory
ORDER BY gross_profit desc;

--q2.2

DROP TABLE IF EXISTS gold.customer_nobuypct;
CREATE TABLE gold.customer_nobuypct AS
SELECT 
    c.country,
    COUNT(*) AS customer_count,
    COUNT(*) FILTER(WHERE o.customer_id IS NULL) AS nobuy,
    ROUND(100.0 * COUNT(*) FILTER(WHERE o.customer_id IS NULL) / COUNT(*), 2) AS percentagenobuy
FROM silver.clean_customers c
LEFT JOIN bronze.orders o 
    ON c.customer_id = o.customer_id
GROUP BY c.country
ORDER BY nobuy DESC;   

SELECT * FROM gold.customer_nobuypct;

--q2.3

SELECT * from bronze.payments limit 5;
SELECT * from bronze.orders limit 5;
SELECT * from bronze.shipments limit 5;

SELECT DISTINCT(status), 
    COUNT(*)
from bronze.payments
GROUP BY status;

SELECT DISTINCT(status), 
    COUNT(*)
from bronze.shipments
GROUP BY status;

SELECT DISTINCT(carrier), 
    COUNT(*)
from bronze.shipments
GROUP BY carrier;

DROP TABLE IF EXISTS gold.order_statusshipment;
CREATE TABLE gold.order_statusshipment AS
SELECT
    o.channel,
    COUNT(*) AS orderlist,
    COUNT(*) FILTER (WHERE s.order_id IS NULL) AS noship,
    COALESCE(s.carrier, 'not shipped') as shipmentcomp,
    ROUND(AVG(s.delivered_at - s.shipped_at) FILTER (WHERE s.shipped_at IS NOT NULL),2) AS avgdate,
    SUM(p.amount) as paymentamount,
    SUM(o.total_amount) as ordertotalamount,
    COALESCE(s.status, 'not shipped') as statusdelivery
FROM bronze.orders AS o 
LEFT JOIN bronze.shipments AS s ON o.order_id = s.order_id
LEFT JOIN bronze.payments AS p ON o.order_id = p.order_id   
GROUP BY o.channel, s.carrier,s.status
ORDER BY paymentamount DESC;

SELECT * FROM gold.order_statusshipment;
-- the null value in avg date is kept because it s valid that the delivered date is not available when the status is not shipped or in transit

--Q2.4

SELECT * FROM bronze.returns limit 5;
SELECT COUNT(*) FROM bronze.order_items LIMIT 5;
SELECT * FROM bronze.products limit 5;


DROP TABLE IF EXISTS gold.return_categoryreturn;
CREATE TABLE gold.return_categoryreturn as 
SELECT 
    p.category,
    COUNT(r.return_id) as returnvalue,
    COUNT(oi.order_item_id) as itemsold,
    ROUND(100.00 * COUNT(r.return_id) / COUNT(oi.order_item_id),2) as returnrate,
    COALESCE(SUM(r.refund_amount), 0) as totalrefund
FROM bronze.products as p
LEFT JOIN bronze.order_items as oi
ON p.product_id = oi.product_id 
LEFT JOIN bronze.returns as r
on oi.order_item_id = r.order_item_id
GROUP BY p.category
ORDER BY returnrate
;

SELECT * from gold.return_categoryreturn;