"""Database communication module
Provides Storage persistence.
"""

import os
import sys
import psycopg2

from lib.storage import Storage, Region, DataSource, Dataset, TimeSeries

class Connection:
    """PostgreSQL connection wrapper for Storage saving
    """

    def __init__(self):
        """Establish a connection to the database
        data_source: data source database id
        """

        try:
            self.conn = psycopg2.connect(
                host=os.environ['POSTGRES_HOST'],
                database=os.environ['POSTGRES_DB'],
                user=os.environ['POSTGRES_USER'],
                password=os.environ['POSTGRES_PASSWORD'])
            self.cur = self.conn.cursor()
        except (ConnectionAbortedError, ConnectionError,
            ConnectionRefusedError, ConnectionResetError):
            print('Failed to connect to the database')
            sys.exit(1)

    def __del__(self):
        if self.cur:
            self.cur.close()
        if self.conn:
            self.conn.close()

    def save_storage(self, storage: Storage):
        """Save the provided storage instance contents to the database"""

        for region in storage.regions.values():
            self._save_region(region)

        for data_source in storage.data_sources.values():
            self._save_data_source(data_source)

    def _save_region(self, region: Region):
        """Create a region entry or update it; the id must not change"""

        if not self._record_id_exists('region', region.region_id):
            self.cur.execute(f"""INSERT INTO region (id, name)
                VALUES ('{region.region_id}', '{region.name}')""")
        else:
            self.cur.execute(f"""UPDATE region
                SET name = '{region.name}'
                WHERE id = '{region.region_id}'""")

        self.conn.commit()

    def _save_data_source(self, data_source: DataSource):
        """Create a data source entry or update it, including its child values"""

        if not self._record_id_exists('data_source', data_source.data_source_id):
            self.cur.execute(f"""INSERT INTO data_source (id, name, description, url)
                VALUES ('{data_source.data_source_id}', '{data_source.name}',
                '{data_source.description}', '{data_source.url}')""")
        else:
            self.cur.execute(f"""UPDATE data_source
                SET name = '{data_source.name}', description = '{data_source.description}', url = '{data_source.url}'
                WHERE id = '{data_source.data_source_id}'""")

        self.conn.commit()

        for dataset in data_source.datasets.values():
            self._save_dataset(dataset)

    def _save_dataset(self, dataset: Dataset):
        """Create a dataset record or update it
        The dataset_id and data_source.data_source_id must not change between updates.
        The data source this dataset belongs to must already exist in the database.
        """

        if not self._record_id_exists('dataset', dataset.dataset_id):
            if dataset.p_values_per_year is not None:
                self.cur.execute(f"""INSERT INTO dataset (id, data_source, name, description, url, unit,
                    p_values_per_year, r_values_per_year, correlation_values_per_year)
                    VALUES ('{dataset.dataset_id}', '{dataset.data_source.data_source_id}', '{dataset.name}',
                    '{dataset.description}', '{dataset.url}', '{dataset.unit}',
                    '{dataset.p_values_per_year.to_json()}', '{dataset.r_values_per_year.to_json()}',
                    '{dataset.correlation_values_per_year.to_json()}')""")
            else:
                self.cur.execute(f"""INSERT INTO dataset (id, data_source, name, description, url, unit)
                    VALUES ('{dataset.dataset_id}', '{dataset.data_source.data_source_id}', '{dataset.name}',
                    '{dataset.description}', '{dataset.url}', '{dataset.unit}')""")
        else:
            if dataset.p_values_per_year is not None:
                self.cur.execute(f"""UPDATE dataset
                    SET name = '{dataset.name}', description = '{dataset.description}', url = '{dataset.url}',
                    unit = '{dataset.unit}', p_values_per_year = '{dataset.p_values_per_year.to_json()}',
                    r_values_per_year = '{dataset.r_values_per_year.to_json()}',
                    correlation_values_per_year = '{dataset.correlation_values_per_year.to_json()}'
                    WHERE id = '{dataset.dataset_id}'""")
            else:
                self.cur.execute(f"""UPDATE dataset
                    SET name = '{dataset.name}', description = '{dataset.description}', url = '{dataset.url}',
                    unit = '{dataset.unit}'
                    WHERE id = '{dataset.dataset_id}'""")

        self.conn.commit()

        for time_series in dataset.time_series.values():
            self._save_time_series(time_series)

    def _save_time_series(self, time_series: TimeSeries):
        """Create a time series record or update it
        The dataset.dataset_id and region.region_id must not change between updates.
        The dataset this time series belongs to must already exist in the database.
        """

        if not self._time_series_exists(time_series):
            if time_series.lag is not None:
                self.cur.execute(f"""INSERT INTO time_series (dataset, region, series, processed_series,
                    lag, slope, intercept, r_value, p_value, std_err, correlation)
                    VALUES ('{time_series.dataset.dataset_id}', '{time_series.region.region_id}', '{time_series.series.to_json()}',
                    '{time_series.differenced.to_json()}', '{time_series.lag}', '{time_series.slope}', '{time_series.intercept}',
                    '{time_series.r_value}', '{time_series.p_value}',
                    '{time_series.std_err}', '{time_series.correlation}')""")
            else:
                self.cur.execute(f"""INSERT INTO time_series (dataset, region, series)
                    VALUES ('{time_series.dataset.dataset_id}', '{time_series.region.region_id}',
                    '{time_series.series.to_json()}')""")
        else:
            if time_series.lag is not None:
                self.cur.execute(f"""UPDATE time_series
                    SET series = '{time_series.series.to_json()}', processed_series = '{time_series.differenced.to_json()}',
                    lag = '{time_series.lag}', slope = '{time_series.slope}',
                    intercept = '{time_series.intercept}', r_value = '{time_series.r_value}',
                    p_value = '{time_series.p_value}', std_err = '{time_series.std_err}'
                    WHERE dataset = '{time_series.dataset.dataset_id}'
                    AND region = '{time_series.region.region_id}'""")
            else:
                self.cur.execute(f"""UPDATE time_series
                    SET series = '{time_series.series.to_json()}'
                    WHERE dataset = '{time_series.dataset.dataset_id}'
                    AND region = '{time_series.region.region_id}'""")

        self.conn.commit()

    def _record_id_exists(self, table: str, record_id: str):
        """Try to find a record by id, return True on success"""

        self.cur.execute(f"SELECT 1 FROM {table} WHERE id = '{record_id}'")
        records = self.cur.fetchall()
        return len(records) > 0

    def _time_series_exists(self, time_series: TimeSeries):
        """Try to find a time series by key, return True on success"""

        self.cur.execute(f"""SELECT 1 FROM time_series
            WHERE dataset = '{time_series.dataset.dataset_id}'
            AND region = '{time_series.region.region_id}'""")
        records = self.cur.fetchall()
        return len(records) > 0
