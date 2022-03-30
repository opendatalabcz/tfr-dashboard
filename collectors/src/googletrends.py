import time

import pandas as pd
from pytrends.request import TrendReq

import lib.db as db

print('Collecting Google Trends')

data_source = 'google_trends'
base_url = 'https://trends.google.com/trends/explore?date=all&geo=%s&q=%s'

# Datasets to collect along with their metadata
datasets = { 
    # '/m/01cnz': {
    #     'id': 'birth_control',
    #     'name': 'Antikoncepce - Téma',
    #     'description': 'Birth control - Topic'
    # },
    # '/m/0fw7r': {
    #     'id': 'ivf',
    #     'name': 'Umělé oplodnění - Téma',
    #     'description': 'IVF - Topic'
    # },
    # '/m/0g54wr7': {
    #     'id': 'abortion',
    #     'name': 'Potrat - Téma',
    #     'description': 'Abortion - Topic'
    # },
    # '/m/01t751': {
    #     'id': 'pregnancy_test',
    #     'name': 'Těhotenský test - Téma',
    #     'description': 'Pregnancy test - Topic'
    # },
    # '/m/05vqh7': {
    #     'id': 'pregnancy',
    #     'name': 'Těhotenství - Téma',
    #     'description': 'Pregnancy - Topic'
    # },
    # '/m/0lc0w': {
    #     'id': 'childbirth',
    #     'name': 'Porod - Téma',
    #     'description': 'Childbirth - Topic'
    # },
    # '/m/0jnvp': {
    #     'id': 'infant',
    #     'name': 'Kojenec - Téma',
    #     'description': 'Infant - Topic'
    # },
    # '/m/05_5p_d': {
    #     'id': 'maternity_hospital',
    #     'name': 'Porodnice - Téma',
    #     'description': 'Maternity hospital - Topic'
    # },
    # '/m/04fb_1': {
    #     'id': 'babysitting',
    #     'name': 'Hlídání dětí - Téma',
    #     'description': 'Babysitting - Topic',
    # },
    '/m/0218w_': {
        'id': 'child_benefit',
        'name': 'Rodičovský příspěvek - Téma',
        'description': 'Child benefit - Topic'
    },
    '/m/01ft5b': {
        'id': 'kindergarten',
        'name': 'Mateřská škola - Téma',
        'description': 'Kindergarten - Topic'
    },
    '/m/03137q': {
        'id': 'parental_leave',
        'name': 'Rodičovská dovolená - Téma',
        'description': 'Parental leave - Topic'
    },
    '/m/04ztj': {
        'id': 'marriage',
        'name': 'Svatba - Téma',
        'description': 'Marriage - Topic'
    },
    '/m/0b03h': {
        'id': 'divorce',
        'name': 'Rozvod - Téma',
        'description': 'Divorce - Topic'
    },
    '/m/0dfm1w': {
        'id': 'mortgage_calculator',
        'name': 'Hypoteční kalkulačka - Téma',
        'description': 'Mortgage calculator - Topic'
    },
    '/m/0218w7': {
        'id': 'unemployment_benefits',
        'name': 'Podpora v nezaměstnanosti - Téma',
        'description': 'Unemployment benefits - Topic'
    },
    '/m/02wcrb': {
        'id': 'termination_of_employment',
        'name': 'Výpověď ze zaměstnání - Téma',
        'description': 'Termination of employment - Topic'
    },
    '/m/012lyw': {
        'id': 'stress',
        'name': 'Stres - Téma',
        'description': 'Stress - Topic'
    }
}
dataset_unit = 'frekvence vyhledávání'

# Regions to collect the datasets for
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

# Add data source record
conn = db.Connection(data_source)
conn.add_data_source(
    name='Google Trends',
    description='Historie vyhledávání na Google',
    url='https://trends.google.com/')

def collect(term, region, timeframe='all'):
    """Fetch data for a term, return yearly mean values"""

    # Fetch monthly data
    pytrends.build_payload([term], timeframe=timeframe, geo=region)
    df = pytrends.interest_over_time().drop(columns="isPartial")
    
    # Convert to yearly values as mean of months
    df.reset_index(level=0, inplace=True)
    df.date = df.date.astype('string')
    df = pd.concat([
        df.date.str[0:4],
        df[term]
        ], axis=1)
    df.rename(columns = {term: 'value'}, inplace=True)
    df.set_index('date', inplace=True)
    return df.groupby(['date'])['value'].mean()

def data_to_tuples(data):
    """Convert data from Series to a list of tuples (year, value)"""

    rows = []
    for row in data.iteritems():
        rows.append(row)
    return rows

pytrends = TrendReq(hl='en-US', tz=0)

# Process European Union countries

for term in datasets:
    print('Fetching dataset %s' % datasets[term]['name'])
    europe_data = pd.Series(dtype='float64')
  
    for country in europe:
        print('- %s' % country)
        data = collect(term=term, region=country)
        europe_data = pd.concat([europe_data, data])

        # Save data
        props = datasets[term]

        rows = data_to_tuples(data)

        conn.add_dataset(
            dataset=props['id'],
            region=europe[country],
            name=props['name'],
            description=props['description'],
            url=base_url % (country, term),
            unit=dataset_unit,
            data=rows)
        
        # Avoid rate limiting
        time.sleep(1)

    # Create a European mean
    print('- EUU')
    europe_data = europe_data.groupby(level=0).mean()

    # Save data
    props = datasets[term]

    rows = data_to_tuples(data)

    conn.add_dataset(
        dataset=props['id'],
        region='euu',
        name=props['name'],
        description=props['description'],
        url=base_url % ('', term),
        unit=dataset_unit,
        data=rows)
    
    # Collect worldwide data
    print('- WLD')
    data = collect(term=term, region='')

    # Save data
    props = datasets[term]

    rows = data_to_tuples(data)

    conn.add_dataset(
        dataset=props['id'],
        region='wld',
        name=props['name'],
        description=props['description'],
        url=base_url % ('', term),
        unit=dataset_unit,
        data=rows)

    # Avoid rate limiting
    print('Sleeping for 15 seconds', flush=True)
    time.sleep(15)
