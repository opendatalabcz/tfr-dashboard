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
-- Name: correlation; Type: TABLE; Schema: public; Owner: tfr
--

CREATE TABLE public.correlation (
    first_dataset_id character varying(128) NOT NULL,
    second_dataset_id character varying(128) NOT NULL
);


ALTER TABLE public.correlation OWNER TO tfr;

--
-- Name: dataset; Type: TABLE; Schema: public; Owner: tfr
--

CREATE TABLE public.dataset (
    id character varying(128) NOT NULL,
    datasource character varying(128) NOT NULL,
    region character varying(128) NOT NULL,
    name text NOT NULL,
    description text,
    url text,
    unit text NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.dataset OWNER TO tfr;

--
-- Name: COLUMN dataset.datasource; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.dataset.datasource IS 'Parent data source';


--
-- Name: COLUMN dataset.region; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.dataset.region IS 'Geographical region of this dataset';


--
-- Name: COLUMN dataset.type; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.dataset.description IS 'Up to one paragraph about the data set';


--
-- Name: COLUMN dataset.unit; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.dataset.unit IS 'Unit of measurement of the data points';


--
-- Name: datasource; Type: TABLE; Schema: public; Owner: tfr
--

CREATE TABLE public.datasource (
    id character varying(128) NOT NULL,
    name text NOT NULL,
    description text,
    url text
);


ALTER TABLE public.datasource OWNER TO tfr;

--
-- Name: COLUMN datasource.name; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.datasource.name IS 'Data source display name';


--
-- Name: COLUMN datasource.description; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.datasource.description IS 'Data source single-paragraph description';


--
-- Name: COLUMN datasource.url; Type: COMMENT; Schema: public; Owner: tfr
--

COMMENT ON COLUMN public.datasource.url IS 'The original URL of the data source';


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
-- Data for Name: correlation; Type: TABLE DATA; Schema: public; Owner: tfr
--

COPY public.correlation (first_dataset_id, second_dataset_id) FROM stdin;
\.


--
-- Data for Name: dataset; Type: TABLE DATA; Schema: public; Owner: tfr
--

COPY public.dataset (datasource, region, id, name, description, url, unit, last_updated) FROM stdin;
\.


--
-- Data for Name: datasource; Type: TABLE DATA; Schema: public; Owner: tfr
--

COPY public.datasource (id, name, description, url) FROM stdin;
\.


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: tfr
--

COPY public.region (id, name) FROM stdin;
\.


--
-- Name: dataset dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (id);


--
-- Name: datasource datasource_pkey; Type: CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.datasource
    ADD CONSTRAINT datasource_pkey PRIMARY KEY (id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: fki_datasource_fkey; Type: INDEX; Schema: public; Owner: tfr
--

CREATE INDEX fki_datasource_fkey ON public.dataset USING btree (datasource);


--
-- Name: fki_first_dataset_fkey; Type: INDEX; Schema: public; Owner: tfr
--

CREATE INDEX fki_first_dataset_fkey ON public.correlation USING btree (first_dataset_id);


--
-- Name: fki_region_fkey; Type: INDEX; Schema: public; Owner: tfr
--

CREATE INDEX fki_region_fkey ON public.dataset USING btree (region);


--
-- Name: fki_second_dataset_fkey; Type: INDEX; Schema: public; Owner: tfr
--

CREATE INDEX fki_second_dataset_fkey ON public.correlation USING btree (second_dataset_id);


--
-- Name: dataset datasource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT datasource_fkey FOREIGN KEY (datasource) REFERENCES public.datasource(id) NOT VALID;


--
-- Name: correlation first_dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.correlation
    ADD CONSTRAINT first_dataset_fkey FOREIGN KEY (first_dataset_id) REFERENCES public.dataset(id) NOT VALID;


--
-- Name: dataset region_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT region_fkey FOREIGN KEY (region) REFERENCES public.region(id) NOT VALID;


--
-- Name: correlation second_dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tfr
--

ALTER TABLE ONLY public.correlation
    ADD CONSTRAINT second_dataset_fkey FOREIGN KEY (second_dataset_id) REFERENCES public.dataset(id) NOT VALID;


--
-- PostgreSQL database dump complete
--

