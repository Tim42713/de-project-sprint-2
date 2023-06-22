DROP TABLE IF EXISTS public.shipping_country_rates;
DROP TABLE IF EXISTS public.shipping_agreement;
DROP TABLE IF EXISTS public.shipping_transfer;
DROP TABLE IF EXISTS public.shipping_info;
DROP TABLE IF EXISTS public.shipping_status;

-- создаем таблицу public.shipping_country_rates
CREATE TABLE public.shipping_country_rates(
    id serial NOT NULL,
    shipping_country text,
    shipping_country_base_rate NUMERIC(14, 3),
    PRIMARY KEY(id)
);

-- создаем таблицу public.shipping_agreement
CREATE TABLE public.shipping_agreement(
    agreement_id bigint NOT NULL,
    agreement_number text,
    agreement_rate numeric(14, 3),
    agreement_commission numeric(14, 3),
    PRIMARY KEY(agreement_id)
);

-- создаем таблицу public.shipping_transfer
CREATE TABLE public.shipping_transfer(
    id serial NOT NULL,
    transfer_type text,
    transfer_model text,
    shipping_transfer_rate numeric(14, 3),
    PRIMARY KEY(transfer_type_id) 
);