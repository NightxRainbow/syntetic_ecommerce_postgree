CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

ALTER TABLE public.customers   SET SCHEMA bronze;
ALTER TABLE public.products    SET SCHEMA bronze;
ALTER TABLE public.orders      SET SCHEMA bronze;
ALTER TABLE public.order_items SET SCHEMA bronze;
ALTER TABLE public.payments    SET SCHEMA bronze;
ALTER TABLE public.shipments   SET SCHEMA bronze;
ALTER TABLE public.returns     SET SCHEMA bronze;