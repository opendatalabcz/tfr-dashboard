"""Google Trends data source collector"""

import time

import pandas as pd
from pytrends.request import TrendReq

from lib.storage import Storage, DataSource, Dataset, TimeSeries

BASE_URL = 'https://trends.google.com/trends/explore?date=all&q=%s'
UNIT = 'frekvence vyhledávání'

# Datasets to fetch along with their metadata
datasets = {
    '/m/01cnz': {
        'id': 'birth_control',
        'name': 'Antikoncepce',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s antikoncepcí'
    },
    '/m/0fw7r': {
        'id': 'ivf',
        'name': 'Umělé oplodnění',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s umělým oplodněním'
    },
    '/m/0g54wr7': {
        'id': 'abortion',
        'name': 'Potrat',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s potratem'
    },
    '/m/01t751': {
        'id': 'pregnancy_test',
        'name': 'Těhotenský test',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s těhotenskými testy'
    },
    '/m/05vqh7': {
        'id': 'pregnancy',
        'name': 'Těhotenství',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s těhotenstvím'
    },
    '/m/0lc0w': {
        'id': 'childbirth',
        'name': 'Porod',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s porodem'
    },
    '/m/0jnvp': {
        'id': 'infant',
        'name': 'Kojenec',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s kojenci'
    },
    '/m/05_5p_d': {
        'id': 'maternity_hospital',
        'name': 'Porodnice',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s porodnicí'
    },
    '/m/04fb_1': {
        'id': 'babysitting',
        'name': 'Hlídání dětí',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s hlídáním dětí',
    },
    '/m/0218w_': {
        'id': 'child_benefit',
        'name': 'Rodičovský příspěvek',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s rodičovskými příspěvky'
    },
    '/m/01ft5b': {
        'id': 'kindergarten',
        'name': 'Mateřská škola',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s mateřskou školou'
    },
    '/m/03137q': {
        'id': 'parental_leave',
        'name': 'Rodičovská dovolená',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s rodičovskou dovolenou'
    },
    '/g/12233csl': {
        'id': 'stroller',
        'name': 'Kočárek',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s tématem kočárku'
    },
    '/m/01fqc_': {
        'id': 'baby_bottle',
        'name': 'Kojenecká láhev',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s tématem kojenecké lahve'
    },
    '/m/04ztj': {
        'id': 'marriage',
        'name': 'Svatba',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících se svatbou'
    },
    '/m/0b03h': {
        'id': 'divorce',
        'name': 'Rozvod',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s rozvodem'
    },
    '/m/0dfm1w': {
        'id': 'mortgage_calculator',
        'name': 'Hypoteční kalkulačka - Téma',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s tématem hypoteční kalkulačky'
    },
    '/m/0218w7': {
        'id': 'unemployment_benefits',
        'name': 'Podpora v nezaměstnanosti - Téma',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s podporou v nezaměstnanosti'
    },
    '/m/02wcrb': {
        'id': 'termination_of_employment',
        'name': 'Výpověď ze zaměstnání - Téma',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících s výpovědí ze zaměstnání'
    },
    '/m/012lyw': {
        'id': 'stress',
        'name': 'Stres - Téma',
        'description': 'Frekvence vyhledávání klíčových slov souvisejících se stresem'
    }
}

# Regions to fetch the datasets for
# Google Trends codes along with DB codes
europe = {
    'AT': 'aut',
    'BE': 'bel',
    'BG': 'bgr',
    'HR': 'hrv',
    'CY': 'cyp',
    'CZ': 'cze',
    'DK': 'dnk',
    'EE': 'est',
    'FI': 'fin',
    'FR': 'fra',
    'DE': 'deu',
    'GR': 'grc',
    'HU': 'hun',
    'IE': 'irl',
    'IT': 'ita',
    'LV': 'lva',
    'LT': 'ltu',
    'LU': 'lux',
    'MT': 'mlt',
    'NL': 'nld',
    'PL': 'pol',
    'PT': 'prt',
    'RO': 'rou',
    'SK': 'svk',
    'SI': 'svn',
    'ES': 'esp',
    'SE': 'swe',
}

other_regions = {
    '': 'wld', # Empty region parameter means whole world
    'NO': 'nor',
    'GB': 'gbr'
}

pytrends = TrendReq(hl='en-US', tz=0)

def fetch(term, region, timeframe='all'):
    """Fetch data for a term, return yearly mean values"""

    # Fetch monthly data
    pytrends.build_payload([term], timeframe=timeframe, geo=region)
    data = pytrends.interest_over_time()

    if data.empty:
        return data

    if 'isPartial' in data.columns:
        data.drop(columns='isPartial', inplace=True)

    # Convert to yearly values as mean of months
    data.reset_index(level=0, inplace=True)
    data.date = data.date.astype('string')
    data = pd.concat([
        data.date.str[0:4],
        data[term]
        ], axis=1)
    data.rename(columns = {term: 'value'}, inplace=True)
    data.set_index('date', inplace=True)
    return data.groupby(['date'])['value'].mean()

def collect(storage: Storage):
    """Collect data from the data source"""

    data_source = DataSource(
        'google_trends',
        'Google Trends',
        'Historie vyhledávání na Google. Ukazatele ve formě témat sdružují související termíny a klíčová slova. Témata se týkají mateřství, sňatku, péče o dítě a ekonomických souvislostí s rodičovstvím.',
        'https://trends.google.com/')


    for term, props in datasets.items():
        print('  - ' + props['name'])

        dataset = Dataset(
            props['id'],
            data_source,
            props['name'],
            props['description'],
            BASE_URL % term,
            UNIT)

        # Process European Union countries
        europe_data = pd.Series(dtype='float64')
        for country, region_id in europe.items():
            data = fetch(term=term, region=country)

            if not data.empty:
                europe_data = pd.concat([europe_data, data])

                # Save data
                dataset.add_time_series(TimeSeries(
                    data_source,
                    dataset,
                    storage.regions[region_id],
                    data
                ))

            # Avoid rate limiting
            time.sleep(1)

        # Create a European mean
        europe_data = europe_data.groupby(level=0).mean()

        # Save data
        dataset.add_time_series(TimeSeries(
            data_source,
            dataset,
            storage.regions['euu'],
            data
        ))

        # Collect data for other regions
        for region, region_id in other_regions.items():
            data = fetch(term=term, region=region)

            if not data.empty:
                # Save data
                dataset.add_time_series(TimeSeries(
                    data_source,
                    dataset,
                    storage.regions[region_id],
                    data
                ))

            # Avoid rate limiting
            time.sleep(1)

        data_source.add_dataset(dataset)

    storage.add_data_source(data_source)
