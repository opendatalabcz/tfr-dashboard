import os
import psycopg2

class Connection:
    """PostgreSQL connection wrapper providing utility methods for data collectors
    
    Use a separate instance for each data source
    """

    conn = None
    cur = None

    def __init__(self, data_source):
        """Establish a connection to the database
        data_source: data source database id
        """
        self.data_source = data_source
        
        try:
            self.conn = psycopg2.connect(
                host=os.environ['POSTGRES_HOST'],
                database=os.environ['POSTGRES_DB'],
                user=os.environ['POSTGRES_USER'],
                password=os.environ['POSTGRES_PASSWORD'])
            self.cur = self.conn.cursor()
            print('Connected to the database')
        except:
            print('Failed to connect to the database')
            exit(1)
        
        self._init_db()

    def __del__(self):
        if self.cur:
            self.cur.close()
        if self.conn:
            self.conn.close()

    def add_data_source(self, name, description, url):
        """Create data source entry or update it"""

        if not self._record_id_exists('datasource', self.data_source):
            # Insert
            self.cur.execute('INSERT INTO datasource (id, name, description, url) VALUES (\'%s\', \'%s\', \'%s\', \'%s\')'
                % (self.data_source, name, description, url))
        else:
            # Update
            self.cur.execute('UPDATE datasource SET name = \'%s\', description = \'%s\', url = \'%s\' WHERE id = \'%s\''
                % (name, description, url, self.data_source))
        
        self.conn.commit()
        print('Data source record saved')

    def add_dataset_record(self, dataset, region, name, description, url, unit):
        """Create dataset record or update it; the dataset, datasource and region must not change
        Used to save metadata about a dataset to the 'dataset' table
        """

        id = self._create_dataset_id(region, dataset)
        if not self._record_id_exists('dataset', id):
            # Insert
            self.cur.execute('''INSERT INTO dataset (id, datasource, region, name, description, url, unit)
                VALUES (\'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\')'''
                % (id, self.data_source, region, name, description, url, unit))
        else:
            # Update
            self.cur.execute('''UPDATE dataset SET name = \'%s\', description = \'%s\', url = \'%s\', unit = \'%s\'
                WHERE id = \'%s\'''' % (name, description, url, unit, id))
        
        self.conn.commit()
        print('  Dataset record saved')

    def add_dataset_data(self, dataset, region, data):
        """Add dataset time-series to its own table"""

        id = self._create_dataset_id(region, dataset)
        # Create the data table
        self.cur.execute('''DROP TABLE IF EXISTS public.dataset_%s;
        
            CREATE TABLE IF NOT EXISTS public.dataset_%s
            (
                year character varying(4) COLLATE pg_catalog."default" NOT NULL,
                value double precision NOT NULL,
                CONSTRAINT dataset_%s_pkey PRIMARY KEY (year)
            )

            TABLESPACE pg_default;

            ALTER TABLE IF EXISTS public.dataset_%s
                OWNER to %s;'''
            % (id, id, id, id, os.environ['POSTGRES_USER']))

        # Insert data 
        self.cur.executemany('INSERT INTO dataset_%s ' % id + '(year, value) VALUES(%s, %s)', data) # List of tuples

        self.conn.commit()

        print('  Dataset data saved')

        # Mark dataset as updated
        self.update_dataset(id)

    def add_dataset(self, dataset, region, name, description, url, unit, data):
        """Shorthand for calling add_dataset_record and add_dataset_data at once"""

        self.add_dataset_record(dataset, region, name, description, url, unit)
        self.add_dataset_data(dataset, region, data)

    def update_dataset(self, id):
        """Mark dataset as updated by setting the last_updated column to now"""

        self.cur.execute('UPDATE dataset SET last_updated = NOW() WHERE id = \'%s\'' % id)
        self.conn.commit()
        print('  Dataset record updated')

    def _init_db(self):
        """Initialize DB records"""

        # Add region records
        for region_id in regions:
            self._add_region(region_id, regions[region_id])

    def _add_region(self, id, name):
        """Create region entry or update it; the id must not change"""

        if not self._record_id_exists('region', id):
            # Insert
            self.cur.execute('INSERT INTO region (id, name) VALUES (\'%s\', \'%s\')'
                % (id, name))
        else:
            # Update
            self.cur.execute('UPDATE region SET name = \'%s\' WHERE id = \'%s\''
                % (name, id))
        
        self.conn.commit()

    def _record_id_exists(self, table, id):
        """Try to find a record by id, return True on success"""

        self.cur.execute('SELECT id FROM %s WHERE id = \'%s\'' % (table, id))
        records = self.cur.fetchall()
        return len(records) > 0

    def _create_dataset_id(self, region, dataset):
        """Construct a dataset id from given parameters"""
        return '%s_%s_%s' % (self.data_source, region, dataset)

# Region ids and names
regions = {
    'wld': 'Celý svět',
    'euu': 'Evropská unie',
    'aut': 'Rakousko',
    'bel': 'Belgie',
    'bgr': 'Bulharsko',
    'hrv': 'Chorvatsko',
    'cyp': 'Kypr',
    'cze': 'Česká republika',
    'dnk': 'Dánsko',
    'est': 'Estonsko',
    'fin': 'Finsko',
    'fra': 'Francie',
    'deu': 'Německo',
    'grc': 'Řecko',
    'hun': 'Maďarsko',
    'irl': 'Irsko',
    'ita': 'Itálie',
    'lva': 'Lotyšsko',
    'ltu': 'Litva',
    'lux': 'Lucembursko',
    'mlt': 'Malta',
    'nld': 'Nizozemsko',
    'pol': 'Polsko',
    'prt': 'Portugalsko',
    'rou': 'Rumunsko',
    'svk': 'Slovensko',
    'svn': 'Slovinsko',
    'esp': 'Španělsko',
    'swe': 'Švédsko'
}
