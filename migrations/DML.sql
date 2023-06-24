-- заполняем таблицу shipping_country_rates
INSERT INTO public.shipping_country_rates (shipping_country, shipping_country_base_rate)
SELECT DISTINCT
       shipping_country,
       shipping_country_base_rate
FROM public.shipping;

-- check 
-- SELECT * FROM public.shipping_country_rates LIMIT 10;

-- заполняем таблицу shipping_agreement
INSERT INTO public.shipping_agreement(agreement_id, agreement_number, agreement_number, agreement_commission)
SELECT DISTINCT
       (regexp_split_to_array(vendor_agreement_description, ':'))[1]::bigint AS agreement_id,
       (regexp_split_to_array(vendor_agreement_description, ':'))[2]::text AS agreement_number,
       (regexp_split_to_array(vendor_agreement_description, ':'))[3]::numeric AS agreement_number,
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