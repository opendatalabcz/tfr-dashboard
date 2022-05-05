#!/bin/bash

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d "$POSTGRES_DB"  <<-EOSQL
--    
-- PostgREST authentication part 1
--

CREATE ROLE $POSTGREST_USER WITH
LOGIN
NOSUPERUSER
NOINHERIT
NOCREATEDB
NOCREATEROLE
NOREPLICATION
PASSWORD '$POSTGREST_PASSWORD';

CREATE ROLE $POSTGREST_ANON_ROLE WITH
NOLOGIN
NOSUPERUSER
INHERIT
NOCREATEDB
NOCREATEROLE
NOREPLICATION;

--    
-- PostgREST authentication part 1 complete, continues right before end of file
--


--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2 (Debian 14.2-1.pgdg110+1)
-- Dumped by pg_dump version 14.2 (Debian 14.2-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: data_source; Type: TABLE; Schema: public; Owner: $POSTGRES_USER
--

CREATE TABLE public.data_source (
    id character varying(128) NOT NULL,
    name text NOT NULL,
    description text,
    url text
);


ALTER TABLE public.data_source OWNER TO $POSTGRES_USER;

--
-- Name: COLUMN data_source.name; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.data_source.name IS 'Data source display name';


--
-- Name: COLUMN data_source.description; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.data_source.description IS 'Data source single-paragraph description';


--
-- Name: COLUMN data_source.url; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.data_source.url IS 'The original URL of the data source';


--
-- Name: dataset; Type: TABLE; Schema: public; Owner: $POSTGRES_USER
--

CREATE TABLE public.dataset (
    id character varying(128) NOT NULL,
    data_source character varying(128) NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    url text NOT NULL,
    unit text NOT NULL,
    p_values_per_year json,
    r_values_per_year json,
    correlation_values_per_year json
);


ALTER TABLE public.dataset OWNER TO $POSTGRES_USER;

--
-- Name: COLUMN dataset.data_source; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.dataset.data_source IS 'Parent data source';


--
-- Name: COLUMN dataset.description; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.dataset.description IS 'Up to one paragraph about the data set';


--
-- Name: COLUMN dataset.url; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.dataset.url IS 'The original URL of the data source';


--
-- Name: COLUMN dataset.unit; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.dataset.unit IS 'Unit of measurement of the data points';


--
-- Name: COLUMN dataset.p_values_per_year; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.dataset.p_values_per_year IS 'p-values for inter-region correlations per year';


--
-- Name: COLUMN dataset.r_values_per_year; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.dataset.r_values_per_year IS 'r-values for inter-region correlations per year';


--
-- Name: COLUMN dataset.correlation_values_per_year; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.dataset.correlation_values_per_year IS 'Truth values for inter-region correlations per year';


--
-- Name: time_series; Type: TABLE; Schema: public; Owner: $POSTGRES_USER
--

CREATE TABLE public.time_series (
    dataset character varying(128) NOT NULL,
    region character varying(128) NOT NULL,
    series json NOT NULL,
    processed_series json,
    lag real,
    slope real,
    intercept real,
    r_value real,
    p_value real,
    std_err real,
    correlation boolean
);


ALTER TABLE public.time_series OWNER TO $POSTGRES_USER;

--
-- Name: COLUMN time_series.series; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.time_series.series IS 'Values of the dataset in a given region per year';


--
-- Name: COLUMN time_series.processed_series; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.time_series.processed_series IS 'Differenced values of the dataset in a given region per year';


--
-- Name: COLUMN time_series.correlation; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON COLUMN public.time_series.correlation IS 'Whether this time series has a non-zero slope of linear regression with the TFR dataset';


--
-- Name: low_p_value_time_series_by_dataset; Type: VIEW; Schema: public; Owner: $POSTGRES_USER
--

CREATE VIEW public.low_p_value_time_series_by_dataset AS
 SELECT time_series.dataset,
    avg(time_series.p_value) AS p_avg,
    max(time_series.r_value) AS r_max,
    min(time_series.r_value) AS r_min,
    sum(time_series.r_value) AS r_sum,
    sum(
        CASE
            WHEN (time_series.r_value > (0)::double precision) THEN 1
            ELSE 0
        END) AS n_positive,
    sum(1) AS n_series
   FROM public.time_series
  WHERE (((time_series.dataset)::text <> 'tfr'::text) AND (abs(time_series.p_value) < (0.05)::double precision))
  GROUP BY time_series.dataset
  ORDER BY (sum(1)) DESC;


ALTER TABLE public.low_p_value_time_series_by_dataset OWNER TO $POSTGRES_USER;

--
-- Name: VIEW low_p_value_time_series_by_dataset; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON VIEW public.low_p_value_time_series_by_dataset IS 'Number of time series with p-value < 0.05 by dataset';


--
-- Name: region; Type: TABLE; Schema: public; Owner: $POSTGRES_USER
--

CREATE TABLE public.region (
    id character varying(128) NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.region OWNER TO $POSTGRES_USER;

--
-- Name: TABLE region; Type: COMMENT; Schema: public; Owner: $POSTGRES_USER
--

COMMENT ON TABLE public.region IS 'Geographical region';


--
-- Data for Name: data_source; Type: TABLE DATA; Schema: public; Owner: $POSTGRES_USER
--

COPY public.data_source (id, name, description, url) FROM stdin;
\.


--
-- Data for Name: dataset; Type: TABLE DATA; Schema: public; Owner: $POSTGRES_USER
--

COPY public.dataset (id, data_source, name, description, url, unit, p_values_per_year, r_values_per_year, correlation_values_per_year) FROM stdin;
\.


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: $POSTGRES_USER
--

COPY public.region (id, name) FROM stdin;
\.


--
-- Data for Name: time_series; Type: TABLE DATA; Schema: public; Owner: $POSTGRES_USER
--

COPY public.time_series (dataset, region, series, processed_series, lag, slope, intercept, r_value, p_value, std_err, correlation) FROM stdin;
\.


--
-- Name: data_source data_source_pkey; Type: CONSTRAINT; Schema: public; Owner: $POSTGRES_USER
--

ALTER TABLE ONLY public.data_source
    ADD CONSTRAINT data_source_pkey PRIMARY KEY (id);


--
-- Name: dataset dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: $POSTGRES_USER
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: $POSTGRES_USER
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: time_series time_series_pkey; Type: CONSTRAINT; Schema: public; Owner: $POSTGRES_USER
--

ALTER TABLE ONLY public.time_series
    ADD CONSTRAINT time_series_pkey PRIMARY KEY (dataset, region);


--
-- Name: fki_data_source_fkey; Type: INDEX; Schema: public; Owner: $POSTGRES_USER
--

CREATE INDEX fki_data_source_fkey ON public.dataset USING btree (data_source);


--
-- Name: fki_dataset_fkey; Type: INDEX; Schema: public; Owner: $POSTGRES_USER
--

CREATE INDEX fki_dataset_fkey ON public.time_series USING btree (dataset);


--
-- Name: fki_region_fkey; Type: INDEX; Schema: public; Owner: $POSTGRES_USER
--

CREATE INDEX fki_region_fkey ON public.time_series USING btree (region);


--
-- Name: dataset data_source_fkey; Type: FK CONSTRAINT; Schema: public; Owner: $POSTGRES_USER
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT data_source_fkey FOREIGN KEY (data_source) REFERENCES public.data_source(id) NOT VALID;


--
-- Name: time_series dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: $POSTGRES_USER
--

ALTER TABLE ONLY public.time_series
    ADD CONSTRAINT dataset_fkey FOREIGN KEY (dataset) REFERENCES public.dataset(id) NOT VALID;


--
-- Name: time_series region_fkey; Type: FK CONSTRAINT; Schema: public; Owner: $POSTGRES_USER
--

ALTER TABLE ONLY public.time_series
    ADD CONSTRAINT region_fkey FOREIGN KEY (region) REFERENCES public.region(id) NOT VALID;


--
-- PostgreSQL database dump complete
--


--
-- PostgREST authentication part 2
--

GRANT $POSTGREST_ANON_ROLE TO $POSTGREST_USER;
GRANT USAGE ON SCHEMA public TO $POSTGREST_ANON_ROLE;

GRANT SELECT ON TABLE public.data_source TO $POSTGREST_ANON_ROLE;
GRANT SELECT ON TABLE public.dataset TO $POSTGREST_ANON_ROLE;
GRANT SELECT ON TABLE public.region TO $POSTGREST_ANON_ROLE;
GRANT SELECT ON TABLE public.time_series TO $POSTGREST_ANON_ROLE;

--
-- PostgREST authentication part 2 complete
--
EOSQL