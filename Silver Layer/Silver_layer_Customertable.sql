DROP TABLE IF EXISTS silver.clean_customers;

CREATE TABLE silver.clean_customers (
    
  customer_id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT,
  email TEXT, phone TEXT, country TEXT, city TEXT,
  signup_date DATE, loyalty_tier TEXT, marketing_opt_in INTEGER
);

INSERT INTO silver.clean_customers (
  customer_id, first_name, last_name, email, phone, country, city,
  signup_date, loyalty_tier, marketing_opt_in
) 
SELECT customer_id, first_name, last_name, email, phone, country, city,
       signup_date, loyalty_tier, marketing_opt_in
FROM bronze.customers

UPDATE silver.clean_customers
SET phone = REGEXP_REPLACE(phone, '[^0-9]', '', 'g');

UPDATE silver.clean_customers
SET phone = coalesce(phone, 'No Phone Provided')
WHERE phone IS NULL;

SELECT DISTINCT phone FROM silver.clean_customers;

SELECT customer_id,first_name,last_name, loyalty_tier FROM silver.clean_customers ORDER BY loyalty_tier DESC;
