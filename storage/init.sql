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
-- Name: data_source; Type: TABLE; Schema: public; Owner: tfr
--

CREATE TABLE public.data_source (
    id character varying(128) NOT NULL,
    name text NOT NULL,
    description text,
    url text
);


ALTER TABLE public.data_source OWNER TO tfr;

--
-- Name: COLUMN data_source.name; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.data_source.name IS 'Data source display name';


--
-- Name: COLUMN data_source.description; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.data_source.description IS 'Data source single-paragraph description';


--
-- Name: COLUMN data_source.url; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.data_source.url IS 'The original URL of the data source';


--
-- Name: dataset; Type: TABLE; Schema: public; Owner: tfr
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


ALTER TABLE public.dataset OWNER TO tfr;

--
-- Name: COLUMN dataset.data_source; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.dataset.data_source IS 'Parent data source';


--
-- Name: COLUMN dataset.description; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.dataset.description IS 'Up to one paragraph about the data set';


--
-- Name: COLUMN dataset.url; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.dataset.url IS 'The original URL of the data source';


--
-- Name: COLUMN dataset.unit; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.dataset.unit IS 'Unit of measurement of the data points';


--
-- Name: COLUMN dataset.p_values_per_year; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.dataset.p_values_per_year IS 'p-values for inter-region correlations per year';


--
-- Name: COLUMN dataset.r_values_per_year; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.dataset.r_values_per_year IS 'r-values for inter-region correlations per year';


--
-- Name: COLUMN dataset.correlation_values_per_year; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.dataset.correlation_values_per_year IS 'Truth values for inter-region correlations per year';


--
-- Name: region; Type: TABLE; Schema: public; Owner: tfr
--

CREATE TABLE public.region (
    id character varying(128) NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.region OWNER TO tfr;

--
-- Name: TABLE region; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON TABLE public.region IS 'Geographical region';


--
-- Name: time_series; Type: TABLE; Schema: public; Owner: tfr
--

CREATE TABLE public.time_series (
    dataset character varying(128) NOT NULL,
    region character varying(128) NOT NULL,
    series json NOT NULL,
    lag real,
    slope real,
    intercept real,
    r_value real,
    p_value real,
    std_err real,
    correlation boolean
);


ALTER TABLE public.time_series OWNER TO tfr;

--
-- Name: COLUMN time_series.series; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.time_series.series IS 'Values of the dataset in a given region per year';


--
-- Data for Name: data_source; Type: TABLE DATA; Schema: public; Owner: tfr
--

COPY public.data_source (id, name, description, url) FROM stdin;
\.


--
-- Data for Name: dataset; Type: TABLE DATA; Schema: public; Owner: tfr
--

COPY public.dataset (id, data_source, name, description, url, unit, p_values_per_year, r_values_per_year, correlation_values_per_year) FROM stdin;
\.


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: tfr
--

COPY public.region (id, name) FROM stdin;
\.


--
-- Data for Name: time_series; Type: TABLE DATA; Schema: public; Owner: tfr
--

COPY public.time_series (dataset, region, series, lag, slope, intercept, r_value, p_value, std_err) FROM stdin;
\.


--
-- Name: data_source data_source_pkey; Type: CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.data_source
    ADD CONSTRAINT data_source_pkey PRIMARY KEY (id);


--
-- Name: dataset dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: time_series time_series_pkey; Type: CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.time_series
    ADD CONSTRAINT time_series_pkey PRIMARY KEY (dataset, region);


--
-- Name: fki_data_source_fkey; Type: INDEX; Schema: public; Owner: tfr
--

CREATE INDEX fki_data_source_fkey ON public.dataset USING btree (data_source);


--
-- Name: fki_dataset_fkey; Type: INDEX; Schema: public; Owner: tfr
--

CREATE INDEX fki_dataset_fkey ON public.time_series USING btree (dataset);


--
-- Name: fki_region_fkey; Type: INDEX; Schema: public; Owner: tfr
--

CREATE INDEX fki_region_fkey ON public.time_series USING btree (region);


--
-- Name: dataset data_source_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT data_source_fkey FOREIGN KEY (data_source) REFERENCES public.data_source(id) NOT VALID;


--
-- Name: time_series dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.time_series
    ADD CONSTRAINT dataset_fkey FOREIGN KEY (dataset) REFERENCES public.dataset(id) NOT VALID;


--
-- Name: time_series region_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.time_series
    ADD CONSTRAINT region_fkey FOREIGN KEY (region) REFERENCES public.region(id) NOT VALID;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: tfr
--

GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

