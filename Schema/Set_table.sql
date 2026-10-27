CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT,
  email TEXT, phone TEXT, country TEXT, city TEXT,
  signup_date DATE, loyalty_tier TEXT, marketing_opt_in INTEGER);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY, sku TEXT, product_name TEXT,
  category TEXT, brand TEXT, unit_price NUMERIC(12,2), unit_cost NUMERIC(12,2),
  weight_kg NUMERIC(8,3), is_active INTEGER, created_at DATE);

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY, customer_id INTEGER, order_date DATE,
  status TEXT, channel TEXT, subtotal NUMERIC(12,2), discount_amount NUMERIC(12,2),
  shipping_fee NUMERIC(12,2), tax_amount NUMERIC(12,2),
  total_amount NUMERIC(12,2), currency TEXT);

CREATE TABLE order_items (
  order_item_id INTEGER PRIMARY KEY, order_id INTEGER, product_id INTEGER,
  quantity INTEGER, unit_price NUMERIC(12,2), line_total NUMERIC(12,2));

CREATE TABLE payments (
  payment_id INTEGER PRIMARY KEY, order_id INTEGER, method TEXT,
  amount NUMERIC(12,2), paid_at DATE, status TEXT);

CREATE TABLE shipments (
  shipment_id INTEGER PRIMARY KEY, order_id INTEGER, carrier TEXT,
  tracking_number TEXT, shipped_at DATE, delivered_at DATE, status TEXT);

CREATE TABLE returns (
  return_id INTEGER PRIMARY KEY, order_item_id INTEGER, reason TEXT,
  refund_amount NUMERIC(12,2), requested_at DATE, status TEXT);