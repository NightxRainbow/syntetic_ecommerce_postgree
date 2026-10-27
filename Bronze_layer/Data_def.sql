SELECT * from bronze.customers LIMIT 5;
SELECT * from bronze.order_items LIMIT 5;
SELECT * from bronze.orders LIMIT 5;
SELECT * from bronze.payments LIMIT 5;
SELECT * from bronze.products LIMIT 5;
SELECT * from bronze.returns LIMIT 5;
SELECT * from bronze.shipments LIMIT 5;

SELECT customer_id, COUNT(*) AS duplicate_count FROM bronze.customers GROUP BY customer_id HAVING COUNT(*) > 1;
SELECT order_id, COUNT(*) AS duplicate_count FROM bronze.orders GROUP BY order_id HAVING COUNT(*) > 1;
SELECT order_item_id, COUNT(*) AS duplicate_count FROM bronze.order_items GROUP BY order_item_id HAVING COUNT(*) > 1;
SELECT payment_id, COUNT(*) AS duplicate_count FROM bronze.payments GROUP BY payment_id HAVING COUNT(*) > 1;
SELECT shipment_id, COUNT(*) AS duplicate_count FROM bronze.shipments GROUP BY shipment_id HAVING COUNT(*) > 1;
SELECT return_id, COUNT(*) AS duplicate_count FROM bronze.returns GROUP BY return_id HAVING COUNT(*) > 1;
SELECT product_id, COUNT(*) AS duplicate_count FROM bronze.products GROUP BY product_id HAVING COUNT(*) > 1;

--there is no duplicate value in all the tables in bronze schema

SELECT 
    count(*) filter(WHERE customer_id isnull) as customer_id_NA,
    count(*) filter(WHERE first_name isnull) as first_name_NA,
    count(*) filter(WHERE last_name isnull) as last_name_NA,
    count(*) filter(WHERE email isnull) as email_NA,
    count(*) filter(WHERE phone isnull) as phone_NA,
    count(*) filter(WHERE country isnull) as country_NA,
    count(*) filter(WHERE city isnull) as city_NA,
    count(*) filter(WHERE signup_date isnull) as signup_date_NA,
    count(*) filter(WHERE loyalty_tier isnull) as loyalty_tier_NA,
    count(*) filter(WHERE marketing_opt_in isnull) as marketing_opt_in_NA
from bronze.customers 

-- THERE IS 865 null in column phone in customer table

SELECT 
    count(*) filter(WHERE product_id isnull) as product_id_NA,
    count(*) filter(WHERE sku isnull) as sku_NA,
    count(*) filter(WHERE product_name isnull) as product_name_NA,
    count(*) filter(WHERE category isnull) as category_NA,
    count(*) filter(WHERE brand isnull) as brand_NA,
    count(*) filter(WHERE unit_price isnull) as unit_price_NA,
    count(*) filter(WHERE unit_cost isnull) as unit_cost_NA,
    count(*) filter(WHERE weight_kg isnull) as weight_kg_NA,
    count(*) filter(WHERE is_active isnull) as is_active_NA,
    count(*) filter(WHERE created_at isnull) as created_at_NA
from bronze.products

-- THERE IS 78 NULL in Weight_kg column in product table

SELECT 
    count(*) filter(WHERE order_id isnull) as order_id_NA,
    count(*) filter(WHERE customer_id isnull) as customer_id_NA,
    count(*) filter(WHERE order_date isnull) as order_date_NA,
    count(*) filter(WHERE status isnull) as status_NA,
    count(*) filter(WHERE channel isnull) as channel_NA,
    count(*) filter(WHERE subtotal isnull) as subtotal_NA,
    count(*) filter(WHERE discount_amount isnull) as discount_amount_NA,
    count(*) filter(WHERE shipping_fee isnull) as shipping_fee_NA,
    count(*) filter(WHERE tax_amount isnull) as tax_amount_NA,
    count(*) filter(WHERE total_amount isnull) as total_amount_NA,
    count(*) filter(WHERE currency isnull) as currency_NA
from bronze.orders

-- THERE IS no null value in order table

SELECT 
    count(*) filter(WHERE order_item_id isnull) as order_item_id_NA,
    count(*) filter(WHERE order_id isnull) as order_id_NA,
    count(*) filter(WHERE product_id isnull) as product_id_NA,
    count(*) filter(WHERE quantity isnull) as quantity_NA,
    count(*) filter(WHERE unit_price isnull) as unit_price_NA,
    count(*) filter(WHERE line_total isnull) as line_total_NA
FROM bronze.order_items

--- THERE IS no null value in order_items table

SELECT 
    count(*) filter(WHERE payment_id isnull) as payment_id_NA,
    count(*) filter(WHERE order_id isnull) as order_id_NA,
    count(*) filter(WHERE method isnull) as method_NA,
    count(*) filter(WHERE amount isnull) as amount_NA,
    count(*) filter(WHERE paid_at isnull) as paid_at_NA,
    count(*) filter(WHERE status isnull) as status_NA
FROM bronze.payments

--- THERE IS no null value in payments table

SELECT 
    count(*) filter(WHERE shipment_id isnull) as shipment_id_NA,
    count(*) filter(WHERE order_id isnull) as order_id_NA,
    count(*) filter(WHERE carrier isnull) as carrier_NA,
    count(*) filter(WHERE tracking_number isnull) as tracking_number_NA,
    count(*) filter(WHERE shipped_at isnull) as shipped_at_NA,
    count(*) filter(WHERE delivered_at isnull) as delivered_at_NA,
    count(*) filter(WHERE status isnull) as status_NA
FROM bronze.shipments

--- THERE IS 714 null value in delivered_at column in shipments table

SELECT 
    count(*) filter(WHERE return_id isnull) as return_id_NA,
    count(*) filter(WHERE order_item_id isnull) as order_item_id_NA,
    count(*) filter(WHERE reason isnull) as reason_NA,
    count(*) filter(WHERE refund_amount isnull) as refund_amount_NA,
    count(*) filter(WHERE requested_at isnull) as requested_at_NA,
    count(*) filter(WHERE status isnull) as status_NA
FROM bronze.returns

--- THERE IS no null value in returns table

select * from bronze.customers where phone is null;
SELECT * FROM bronze.products WHERE weight_kg IS NULL;
SELECT status, delivered_at, COUNT(*) as countdelivered FROM bronze.shipments GROUP BY status, delivered_at HAVING delivered_at IS NULL;

SELECT weight_kg from bronze.products ORDER BY weight_kg DESC;

-- Checking null values done, go next for silver layer null fill and data quality check

SELECT COUNT(*) from bronze.customers as c
LEFT JOIN bronze.orders as o on o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Checking an orphan/no parent, so the logic is to count all row in customer table and left join it into a orders table that has the same customer_id, so its left join the orders table(all) to customer table(slice) so when the customer_id is null in the orders table, it means that there is no parent in the customer table, so the count of that will be the orphan/no parent.

SELECT COUNT(*) from bronze.orders as o
LEFT JOIN bronze.order_items as oi on oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) from bronze.orders as o
LEFT JOIN bronze.payments as p on p.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) from bronze.orders as o
LEFT JOIN bronze.shipments as s on s.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) from bronze.order_items as oi
LEFT JOIN bronze.products as p on p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

--- Checking orphan/no parent done, go next for silver layer null fill and data quality check

SELECT total_amount, subtotal, discount_amount, shipping_fee, tax_amount from bronze.orders ORDER BY total_amount asc;
SELECT MAX(total_amount) as maxval,MIN(total_amount) as minval FROM bronze.orders;

SELECT 
SUM(total_amount) as total_amount_sum,
AVG(total_amount) as total_amount_avg
FROM bronze.orders;

SELECT
max(order_date) as maxval,
min(order_date) as minval
FROM bronze.orders

SELECT
MAX(quantity) as maxval, 
MIN(quantity) as minval,
AVG(quantity) as avgval 
FROM bronze.order_items;

SELECT
count(*) as countedrow,
Max(refund_amount) as maxval,
Min(refund_amount) as minval,
AVG(refund_amount) as avgval
FROM bronze.returns



select
    count(*), oi.order_item_id
from bronze.returns as r
    LEFT JOIN bronze.order_items as oi on oi.order_item_id = r.order_item_id
--- Checking outlier done, go next for silver layer null fill and data quality check

SELECT COUNT(DISTINCT status) AS raw_values,
       COUNT(DISTINCT LOWER(TRIM(status))) AS normalized_values,
       COUNT(DISTINCT channel) AS raw_values_channel,
       COUNT(DISTINCT LOWER(TRIM(channel))) AS normalized_values_channel, 
       count(DISTINCT currency) AS raw_values_currency,
       COUNT(DISTINCT LOWER(TRIM(currency))) AS normalized_values_currency
FROM bronze.orders;

SELECT COUNT(DISTINCT city ) AS raw_values,
       COUNT(DISTINCT LOWER(TRIM(city))) AS normalized_values,
       Count(DISTINCT country) AS raw_values_country,
       COUNT(DISTINCT LOWER(TRIM(country))) AS normalized_values_country,
       Count(DISTINCT first_name) AS raw_values_firstname,
       COUNT(DISTINCT LOWER(TRIM(first_name))) AS normalized_values_firstname,
       count(DISTINCT last_name) AS raw_values_lastname,
       COUNT(DISTINCT LOWER(TRIM(last_name))) AS normalized_values_lastname,
       COUNT(DISTINCT email) AS raw_values_email,
       COUNT(DISTINCT LOWER(TRIM(email))) AS normalized_values_email
FROM bronze.customers;

SELECT COUNT(DISTINCT sku ) AS raw_values,
       COUNT(DISTINCT LOWER(TRIM(sku))) AS normalized_values,
       Count(DISTINCT product_name) AS raw_values_productname,
       COUNT(DISTINCT LOWER(TRIM(product_name))) AS normalized_values_productname,
       Count(DISTINCT category) AS raw_values_category,
       COUNT(DISTINCT LOWER(TRIM(category))) AS normalized_values_category,
       count(DISTINCT brand) AS raw_values_brand,
       COUNT(DISTINCT LOWER(TRIM(brand))) AS normalized_values_brand
FROM bronze.products;


--- Checking inconsistent data done, go next for silver layer null fill and data quality check

--start checking the column balance between line_total and quantity * unit_price in order_items table, if there is a difference more than 0.01, then it will be counted as an error

select 
    COUNT(*) as countedline
from bronze.order_items WHERE ABS(line_total - quantity * unit_price) > 0.01;

---start checking the column balance between total_amount and subtotal + shipping_fee + tax_amount - discount_amount in orders table, if there is a difference more than 0.01, then it will be counted as an error
SELECT
count(*)
FROM bronze.orders WHERE ABS(total_amount - (subtotal + shipping_fee + tax_amount - discount_amount)) > 0.01;

SELECT
count(*)
FROM bronze.shipments WHERE shipped_at > delivered_at;

SELECT
count(order_item_id)
from bronze.order_items

select 
    count(order_item_id)
from bronze.returns

