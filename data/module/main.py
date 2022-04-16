"""TFR Dashboard data collection and processing module"""

import os

from lib.db import Connection
from lib.storage import Storage, Region
from collectors import worldbank, eurostat, datagovcz, googletrends
from processors import intercorr, paircorr

if __name__ == '__main__':
    storage = Storage()

    storage.add_regions([
        Region('wld', 'Celý svět'),
        Region('euu', 'Evropská unie'),
        Region('aut', 'Rakousko'),
        Region('bel', 'Belgie'),
        Region('bgr', 'Bulharsko'),
        Region('hrv', 'Chorvatsko'),
        Region('cyp', 'Kypr'),
        Region('cze', 'Česká republika'),
        Region('dnk', 'Dánsko'),
        Region('est', 'Estonsko'),
        Region('fin', 'Finsko'),
        Region('fra', 'Francie'),
        Region('deu', 'Německo'),
        Region('grc', 'Řecko'),
        Region('hun', 'Maďarsko'),
        Region('irl', 'Irsko'),
        Region('ita', 'Itálie'),
        Region('lva', 'Lotyšsko'),
        Region('ltu', 'Litva'),
        Region('lux', 'Lucembursko'),
        Region('mlt', 'Malta'),
        Region('nld', 'Nizozemsko'),
        Region('pol', 'Polsko'),
        Region('prt', 'Portugalsko'),
        Region('rou', 'Rumunsko'),
        Region('svk', 'Slovensko'),
        Region('svn', 'Slovinsko'),
        Region('esp', 'Španělsko'),
        Region('swe', 'Švédsko'),
        Region('nor', 'Norsko'),
        Region('gbr', 'Velká Británie'),
    ])

    # Collect data
    print('Collecting data')

    data_sources = {
        'WORLDBANK': worldbank.collect,
        'EUROSTAT': eurostat.collect,
        'DATAGOVCZ': datagovcz.collect,
        'GOOGLETRENDS': googletrends.collect,
    }

    for data_source_name, data_source_collector in data_sources.items():
        if not f'EXCLUDE_{data_source_name}' in os.environ:
            print('- ' + data_source_name)
            data_source_collector(storage)
        else:
            print('- Skipping ' + data_source_name)

    # Process data
    print('Processing data')

    print('- Pair correlation')
    paircorr.process(storage)
    print('- Inter-region correlation')
    intercorr.process(storage)
    print('- Forecasting')
    # TODO: Implement.

    # Save data
    print('Saving data')
    connection = Connection()
    connection.save_storage(storage)
