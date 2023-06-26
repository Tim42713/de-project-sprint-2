-- заполняем таблицу shipping_country_rates
INSERT INTO public.shipping_country_rates (shipping_country, shipping_country_base_rate)
SELECT DISTINCT
       shipping_country,
       shipping_country_base_rate
FROM public.shipping;

-- check 
SELECT * FROM public.shipping_country_rates LIMIT 10;

-- заполняем таблицу shipping_agreement
INSERT INTO public.shipping_agreement(agreement_id, agreement_number, agreement_rate, agreement_commission)
SELECT DISTINCT
       (regexp_split_to_array(vendor_agreement_description, ':'))[1]::bigint AS agreement_id,
       (regexp_split_to_array(vendor_agreement_description, ':'))[2]::text AS agreement_number,
       (regexp_split_to_array(vendor_agreement_description, ':'))[3]::numeric AS agreement_rate,
       (regexp_split_to_array(vendor_agreement_description, ':'))[4]::numeric AS agreement_commission
FROM shipping;

-- check
SELECT * FROM public.shipping_agreement LIMIT 10;

-- заполняем таблицу public.shipping_transfer
INSERT INTO public.shipping_transfer(transfer_type, transfer_model, shipping_transfer_rate)
SELECT DISTINCT
       (regexp_split_to_array(shipping_transfer_description, ':'))[1]::varchar AS transfer_type,
       (regexp_split_to_array(shipping_transfer_description, ':'))[2]::varchar AS transfer_model,
       shipping_transfer_rate
FROM shipping

-- check 
SELECT * FROM public.shipping_transfer LIMIT 10;

-- заполняем таблицу public.shipping_info
INSERT INTO public.shipping_info(shipping_id, vendor_id, payment_amount, shipping_plan_datetime, shipping_transfer_id, shipping_agreement_id, shipping_country_rate_id)
SELECT DISTINCT
       s.shippingid AS shipping_id,
       s.vendorid AS vendor_id,
       s.payment_amount AS payment_amount,
       s.shipping_plan_datetime AS shipping_plan_datetime,
       st.id AS shipping_transfer_id,
       (regexp_split_to_array(vendor_agreement_description, ':'))[1]::bigint AS agreement_id,
       scr.id AS shipping_country_rate_id
FROM shipping AS s
LEFT JOIN public.shipping_transfer AS st ON s.shipping_transfer_description = concat_ws(':', st.transfer_type, st.transfer_model)
LEFT JOIN public.shipping_country_rates AS scr ON s.shipping_country = scr.shipping_country AND s.shipping_country_base_rate = scr.shipping_country_base_rate;

-- check
SELECT * FROM public.shipping_info LIMIT 10;

-- заполняем таблицу public.shipping_status
WITH ms AS (
       SELECT DISTINCT ON(shippingid)
       shippingid,
       status,
       state,
       state_datetime,
       ROW_NUMBER() OVER (PARTITION BY shippingid ORDER BY state_datetime DESC) AS r
       FROM public.shipping
       ORDER BY shippingid, state_datetime DESC
),
fd AS (
       SELECT shippingid,
              MAX(CASE WHEN state = 'booked' THEN state_datetime END) AS shipping_start_fact_datetime,
              MAX(CASE WHEN state = 'recieved' THEN state_datetime END) AS shipping_end_fact_datetime
              FROM public.shipping
              GROUP BY shippingid
)
INSERT INTO public.shipping_status(shipping_id, status, state, shipping_start_fact_datetime, shipping_end_fact_datetime)
SELECT m.shippingid AS shipping_id,
       m.status AS status,
       m.state AS state,
       f.shipping_start_fact_datetime AS shipping_start_fact_datetime,
       f.shipping_end_fact_datetime AS shipping_end_fact_datetime
FROM ms AS m
LEFT JOIN fd AS f ON m.shippingid = f.shippingid
WHERE m.r = 1;

-- check
SELECT * FROM public.shipping_status LIMIT 10;

-- создаем представление shipping_datamart
CREATE OR REPLACE VIEW public.shipping_datamart AS(
SELECT si.shipping_id,
       si.vendor_id,
       st.transfer_type, 
	EXTRACT (DAY FROM (ss.shipping_end_fact_datetime - ss.shipping_start_fact_datetime)) AS full_day_at_shipping,
	(CASE WHEN ss.shipping_end_fact_datetime > si.shipping_plan_datetime THEN 1 ELSE NULL END) AS is_delay,
	(CASE WHEN status = 'finished' THEN 1 ELSE 0 END) AS is_shipping_finish,
       (CASE WHEN ss.shipping_end_fact_datetime > si.shipping_plan_datetime THEN 
	EXTRACT(DAY FROM (ss.shipping_end_fact_datetime - si.shipping_plan_datetime)) ELSE 0 END) AS delay_day_at_shipping,
       si.payment_amount,
	(si.payment_amount * (scr.shipping_country_base_rate + sa.agreement_rate + st.shipping_transfer_rate)) AS vat,
	si.payment_amount * sa.agreement_commission AS profit
FROM shipping_info si
LEFT JOIN shipping_transfer st ON si.shipping_transfer_id = st.id 
LEFT JOIN shipping_status ss ON si.shipping_id = ss.shipping_id 
LEFT JOIN shipping_country_rates scr ON si.shipping_country_rate_id = scr.id 
LEFT JOIN shipping_agreement sa ON si.shipping_agreement_id = sa.agreement_id 
);