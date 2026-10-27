SELECT * from bronze.orders;

SELECT distinct status
from bronze.orders;

SELECT distinct currency
from bronze.orders

SeLECT distinct channel
from bronze.orders;

--end

SELECT * from bronze.products;

SELECT CORR(p.weight_kg, oi.unit_price) as correlation
from bronze.products as p LEFT JOIN bronze.order_items as oi on 
p.product_id = oi.product_id;

-- no meaning full corelation between weight and price so we can fill weight with "not informed" for null values

DROP TABLE IF EXISTS silver.products_fillna;

CREATE TABLE silver.products_fillna(
    product_id INT primary key not null, sku Text, product_name TEXT, category TEXT,
    brand TEXT, unit_cost Numeric(12,2), unit_price NUMERIC(12,2), weight_kg Numeric(8,3), is_active INT, created_at DATE 
);

INSERT into silver.products_fillna( 
     product_id,sku,product_name,category,brand,unit_price,unit_cost,
     is_active,created_at, weight_kg
)
SELECT 
     product_id,sku,product_name,category,brand,unit_price,unit_cost,
     is_active,created_at, weight_kg
FROM bronze.products;

UPDATE  silver.products_fillna
SET weight_kg = coalesce(weight_kg, (select AVG(weight_kg) from silver.products_fillna where weight_kg is not null) )
where weight_kg is null

SELECT * from silver.products_fillna

--fill missing value with avg weight_kg bcs its 0 cor and not make the outcome different


