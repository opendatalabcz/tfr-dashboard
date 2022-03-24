import os
import datetime

import pandas as pd
import numpy as np
import world_bank_data as wb

import lib.db as db

data_source = 'world_bank'

# Datasets to collect along with their metadata
datasets = {
    'SP.DYN.TFRT.IN': {
        'id': 'tfr',
        'name': 'Total fertility rate',
        'description': 'Počet dětí, které by žena mohla mít, kdyby po celý její život platily hodnoty plodnosti podle věku pro daný rok.',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=SP.DYN.TFRT.IN',
        'unit': 'počet dětí'
    }
}

# Regions to collect the datasets for
regions = [
    'WLD', # World
    'EUU', # European Union
    'AUT',
    'BEL',
    'BGR',
    'HRV',
    'CYP',
    'CZE',
    'DNK',
    'EST',
    'FIN',
    'FRA',
    'DEU',
    'GRC',
    'HUN',
    'IRL',
    'ITA',
    'LVA',
    'LTU',
    'LUX',
    'MLT',
    'NLD',
    'POL',
    'PRT',
    'ROU',
    'SVK',
    'SVN',
    'ESP',
    'SWE'
]

# Add data source record
conn = db.Connection(data_source)
conn.add_data_source(
    name='World Bank',
    description='description',
    url='TBA')

# Collect data since 1980 until now
year = datetime.date.today().strftime("%Y")
for dataset in datasets:
    print('Fetching dataset %s' % dataset)

    series = wb.get_series(dataset, date='1980:%s' % year, id_or_value='id', simplify_index=True)

    # Process dataset for each selected region
    for region in regions:
        print('- %s' % region)
        data = series[region]

        # Remove trailing years with missing values
        years = data.index
        i = len(years) - 1
        was_null = False
        while(i >= 0):
            if np.isnan(data[years[i]]):
                was_null = True
            else:
                if was_null == True:
                    break
            i = i - 1
        data = data.iloc[:(i + 1)] # Last index is exclusive

        # Compute intermediary missing values using interpolation 
        data = data.interpolate()

        # Save data
        
        # Add data set entry
        props = datasets[dataset]
        conn.add_dataset_record(
            dataset=props['id'],
            region=region.lower(),
            name=props['name'],
            description=props['description'],
            url=props['url'],
            unit=props['unit'])

        # Save time series
        rows = []
        for row in data.iteritems():
            rows.append(row)
        conn.add_dataset_data(
            dataset=props['id'],
            region=region.lower(),
            data=rows)