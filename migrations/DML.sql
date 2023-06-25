-- заполняем таблицу shipping_country_rates
INSERT INTO public.shipping_country_rates (shipping_country, shipping_country_base_rate)
SELECT DISTINCT
       shipping_country,
       shipping_country_base_rate
FROM public.shipping;

-- check 
-- SELECT * FROM public.shipping_country_rates LIMIT 10;

-- заполняем таблицу shipping_agreement
INSERT INTO public.shipping_agreement(agreement_id, agreement_number, agreement_rate, agreement_commission)
SELECT DISTINCT
       (regexp_split_to_array(vendor_agreement_description, ':'))[1]::bigint AS agreement_id,
       (regexp_split_to_array(vendor_agreement_description, ':'))[2]::text AS agreement_number,
       (regexp_split_to_array(vendor_agreement_description, ':'))[3]::numeric AS agreement_rate,
       (regexp_split_to_array(vendor_agreement_description, ':'))[4]::numeric AS agreement_commission
FROM shipping;

-- check
-- SELECT * FROM public.shipping_agreement LIMIT 10;

-- заполняем таблицу public.shipping_transfer
INSERT INTO public.shipping_transfer(transfer_type, transfer_model, shipping_transfer_rate)
SELECT DISTINCT
       (regexp_split_to_array(shipping_transfer_description, ':'))[1]::text AS transfer_type,
       (regexp_split_to_array(shipping_transfer_description, ':'))[2]::text AS transfer_model,
       shipping_transfer_rate
FROM shipping

-- check SELECT * FROM public.shipping_transfer LIMIT 10;

-- заполняем таблицу public.shipping_info
INSERT INTO public.shipping_info(shipping_id, vendor_id, payment_amount, shipping_plan_datetime, shipping_transfer_id, shipping_agreement_id, shipping_country_rate_id)
SELECT DISTINCT
       s.shipping_id AS shipping_id,
       s.vendor_id AS vendor_id,
       s.payment_amount AS payment_amount,
       s.shipping_plan_datetime AS shipping_plan_datetime,
       st.id AS shipping_transfer_id,
       (regexp_split_to_array(vendor_agreement_description, ':'))[1]::bigint AS agreement_id,
       scr.id AS shipping_country_rate_id
FROM shipping AS s
LEFT JOIN public.shipping_transfer AS st ON s.shipping_transfer_description = concat_ws(':', st.transfer_type, st.transfer_model)
LEFT JOIN public.shipping_country_rates AS scr ON s.shipping_country = scr.shipping_country AND s.shipping_country_base_rate = scr.shipping_country_base_rate;

-- check SELECT * FROM public.shipping_info LIMIT 10;

-- заполняем таблицу public.shipping_status
INSERT INTO public.shipping_status(shipping_id, status, state, shipping_start_fact_datetime, shipping_end_fact_datetime)
