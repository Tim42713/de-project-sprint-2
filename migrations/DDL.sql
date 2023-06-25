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
    PRIMARY KEY(id) 
);

-- создаем таблицу public.shipping_info
CREATE TABLE public.shipping_info(
    shipping_id bigint,
    vendor_id bigint,
    payment_amount numeric(14, 2),
    shipping_plan_datetime timestamp,
    shipping_transfer_id bigint,
    shipping_agreement_id bigint,
    shipping_country_rate_id bigint,
    PRIMARY KEY(shipping_id),
    FOREIGN KEY(shipping_transfer_id) REFERENCES shipping_transfer(id) ON UPDATE CASCADE,
    FOREIGN KEY(shipping_agreement_id) REFERENCES shipping_agreement(agreement_id) ON UPDATE CASCADE,
    FOREIGN KEY(shipping_country_rate_id) REFERENCES shipping_country_rates(id) ON UPDATE CASCADE
);

-- создаем таблицу shipping_status
CREATE TABLE public.shipping_status(
    shipping_id bigint,
    status text,
    state text,
    shipping_start_fact_datetime timestamp,
    shipping_end_fact_datetime timestamp,
    PRIMARY KEY (shipping_id)
);