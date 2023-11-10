
EXPLAIN ANALYZE
SELECT date_trunc('month'::text, ord.order_datetime) AS order_month,
			prd.product_name ,
            count(DISTINCT ord.id) AS orders,
            ((count(DISTINCT oi.order_id))::numeric / ( max(ord_mnth.orders))::numeric) AS share_of_orders,
            sum(oi.quantity) AS total_quantity,
            sum((prd.product_price * (oi.quantity)::double precision)) AS total_price
FROM PUBLIC.order_items oi
left join public.orders ord on ORD.id = OI.order_id 
left join PUBLIC.products prd on oi.product_id = prd.id 
left join (
SELECT date_trunc('month'::text, orders.order_datetime) AS order_month,
            count(DISTINCT orders.id) AS orders
           FROM public.orders
          GROUP BY (date_trunc('month'::text, orders.order_datetime))
)ord_mnth on ord_mnth.order_month = date_trunc('month'::text, ord.order_datetime)
GROUP BY (date_trunc('month'::text, ord.order_datetime)),prd.product_name
order by order_month, prd.product_name;
----------------------------------------------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT date_trunc('month'::text, ord.order_datetime) AS order_month,
			prd.product_name ,
            count(DISTINCT ord.id) AS orders,
            ((count(DISTINCT oi.order_id))::numeric / ( max(ord_mnth.orders))::numeric) AS share_of_orders,
            sum(oi.quantity) AS total_quantity,
            sum((prd.product_price * (oi.quantity)::double precision)) AS total_price
FROM (select order_id,product_id, quantity from PUBLIC.order_items) oi
left join (select id,order_datetime from public.orders )ord on ORD.id = OI.order_id 
left join (select id,product_name,product_price from public.products) prd on oi.product_id = prd.id 
left join (
SELECT date_trunc('month'::text, orders.order_datetime) AS order_month,
            count(DISTINCT orders.id) AS orders
           FROM public.orders
          GROUP BY (date_trunc('month'::text, orders.order_datetime))
)ord_mnth on ord_mnth.order_month = date_trunc('month'::text, ord.order_datetime)
GROUP BY (date_trunc('month'::text, ord.order_datetime)),prd.product_name
order by order_month, prd.product_name;

----------------------------------------------------------------------------------------------------------
EXPLAIN ANALYZE
with ord_mnth as(
SELECT date_trunc('month'::text, orders.order_datetime) AS order_month,
            count(DISTINCT orders.id) AS orders
           FROM public.orders
          GROUP BY (date_trunc('month'::text, orders.order_datetime))
)
SELECT date_trunc('month'::text, ord.order_datetime) AS order_month,
			prd.product_name ,
            count(DISTINCT ord.id) AS orders,
            ((count(DISTINCT oi.order_id))::numeric / ( max(ord_mnth.orders))::numeric) AS share_of_orders,
            sum(oi.quantity) AS total_quantity,
            sum((prd.product_price * (oi.quantity)::double precision)) AS total_price
FROM public.order_items oi
left join public.products prd on oi.product_id = prd.id 
left join public.orders ord on ORD.id = OI.order_id 
left join ord_mnth on ord_mnth.order_month = date_trunc('month'::text, ord.order_datetime)
GROUP BY (date_trunc('month'::text, ord.order_datetime)),prd.product_name
order by order_month, prd.product_name;
------------------------------------------------------------------------------------------------

CREATE INDEX idx_order_items_prd_id
ON order_items (product_id);

CREATE INDEX idx_order_items_ord_id
ON order_items (order_id);

CREATE INDEX idx_products_id
ON products (id);

CREATE INDEX idx_products_product_name
ON products (product_name);

CREATE INDEX idx_orders_id
ON orders(id);

-----------------------------------------------------------
SELECT 'DROP INDEX IF EXISTS ' || indexname || ' CASCADE;'
FROM pg_indexes
WHERE tablename = 'order_items';


DROP INDEX IF EXISTS idx_order_items_prd_id CASCADE;
DROP INDEX IF EXISTS idx_order_items_ord_id CASCADE;
DROP INDEX IF EXISTS idx_products_id CASCADE;
DROP INDEX IF EXISTS idx_orders_id CASCADE;

-----------------------------------------------------------------
CREATE  INDEX idx_order_items_ord_prd_id
ON order_items (order_id,product_id);
CLUSTER order_items USING idx_order_items_ord_prd_id;


create  INDEX idx_products_id
ON products (id);
CLUSTER products USING idx_products_id;


CREATE INDEX idx_products_product_name
ON products (product_name);

CREATE INDEX idx_orders_id
ON orders(id);
CLUSTER orders USING idx_orders_id;


