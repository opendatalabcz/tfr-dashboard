"""Eurostat data source collector"""

import pandas as pd
import numpy as np

from lib import utils
from lib.storage import Storage, DataSource, Dataset, TimeSeries

# Human-usable URL to put into eurostat_id metadata
LINK = 'https://ec.europa.eu/eurostat/databrowser/view/%s/default/table'

# API to fetch the datasets from
API = 'https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/%s?format=TSV'

# Regions to collect the datasets for
# Eurostat country codes along with DB codes
regions = {
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
    'EL': 'grc',
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
    'NO': 'nor',
    'UK': 'gbr'
}

# Datasets to collect along with their metadata
datasets = {
    'DEMO_NSINAGEC': [
        {
            'id': 'first_marriages_women',
            'name': 'První sňatky žen',
            'description': 'Počet poprvé se vdávajících žen',
            'unit': 'počet sňatků',
            'filter': {
                'sex': 'F',
                'age': 'TOTAL'
            },
        },
        {
            'id': 'first_marriages_men',
            'name': 'První sňatky mužů',
            'description': 'Počet poprvé se ženících mužů',
            'unit': 'počet sňatků',
            'filter': {
                'sex': 'M',
                'age': 'TOTAL'
            },
        },
    ],
    'EDUC_UOE_PERD03': [
        {
            'id': 'teachers_women_ed1',
            'name': 'Podíl žen mezi vyučujícími prvního stupně',
            'description': 'Procento zastoupení žen mezi vyučujícími prvního stupně',
            'unit': '%',
            'filter': {
                'isced11': 'ED1'
            }
        },
        {
            'id': 'teachers_women_ed3',
            'name': 'Podíl žen mezi vyučujícími středního vzdělání',
            'description': 'Procento zastoupení žen mezi vyučujícími středního vzdělání',
            'unit': '%',
            'filter': {
                'isced11': 'ED3'
            }
        }
    ],
    'EDUC_UOE_FINE06': [
        {
            'id': 'education_expenditure',
            'name': 'Státní výdaje na vzdělávání',
            'description': 'Výdaje na vzdelávání od předškolní do vysokoškolské úrovně',
            'unit': '% HDP',
            'filter': {
                'isced11': 'ED02-8'
            }
        }
    ],
    'TPS00106': [
        {
            'id': 'social_benefits_health',
            'name': 'Výdaje na zdravotní péči',
            'description': 'Podíl státních výdajů na zdravotní péči v porovnání se všemi sociálními výdaji',
            'unit': '%',
            'filter': {
                'spdeps': 'SICK'
            }
        },
        {
            'id': 'social_benefits_old_age',
            'name': 'Výdaje na starobní důchody',
            'description': 'Podíl státních výdajů na starobní důchody v porovnání se všemi sociálními výdaji',
            'unit': '%',
            'filter': {
                'spdeps': 'OLD'
            }
        },
        {
            'id': 'social_benefits_family',
            'name': 'Výdaje na podporu rodin',
            'description': 'Podíl státních výdajů na podporu rodin v porovnání se všemi sociálními výdaji',
            'unit': '%',
            'filter': {
                'spdeps': 'FAM'
            }
        },
        {
            'id': 'social_benefits_unemployment',
            'name': 'Výdaje na podporu v nezaměstnanosti',
            'description': 'Podíl státních výdajů na podporu v nezaměstnanosti v porovnání se všemi sociálními výdaji',
            'unit': '%',
            'filter': {
                'spdeps': 'UNEMPLOY'
            }
        }
    ],
    'YTH_DEMO_030': [
        {
            'id': 'age_when_leaving_parents_men',
            'name': 'Průměrný věk osamostatnění potomků - mužů',
            'description': 'Odhadovaný průměrný věk, kdy mladí dospělí opouštějí rodičovskou domácnost',
            'unit': 'věk',
            'filter': {
                'sex': 'M',
            }
        },
        {
            'id': 'age_when_leaving_parents_women',
            'name': 'Průměrný věk osamostatnění potomků - žen',
            'description': 'Odhadovaný průměrný věk, kdy mladí dospělí opouštějí rodičovskou domácnost',
            'unit': 'věk',
            'filter': {
                'sex': 'F',
            }
        }
    ],
    'CRIM_PRIS_AGE': [
        {
            'id': 'prisoners',
            'name': 'Počet vězňů',
            'description': 'Počet vězňů na 100 000 obyvatel',
            'unit': 'počet vězňů',
            'filter': {
                'age': 'TOTAL',
                'sex': 'T',
                'unit': 'P_HTHAB'
            }
        }
    ]
}

def collect(storage: Storage):
    """Collect data from the data source"""

    data_source = DataSource(
        'eurostat',
        'Eurostat',
        'Statistický úřad Evropské unie',
        'https://ec.europa.eu/eurostat')

    for dataset_id, subsets in datasets.items():
        data = pd.read_csv(API % dataset_id, sep='\t')

        # Prepare data for filtering

        # Split leading column into separate columns
        leading_col = data.columns[0]
        leading_cols = data.columns[0].split(sep='\\')[0].split(sep=',')
        data[leading_cols] = pd.DataFrame(data[leading_col].apply(lambda x: x.split(sep=',')).to_list(), index=data.index)
        data.drop(leading_col, axis=1, inplace=True)

        # Replace ':' followed by optional flags with NaN
        data.replace(regex=':.*', value=np.NaN, inplace=True)

        # Strip trailing whitespace from column names
        data.rename(mapper=lambda x: x.strip(), axis=1, inplace=True)

        # Filter out datasets
        for props in subsets:
            print('  - ' + props['name'])

            filtered_data = pd.DataFrame(data)
            for filter_by in props['filter']:
                filtered_data = filtered_data[data[filter_by] == props['filter'][filter_by]]

            # Extract per-country data
            for region, region_id in regions.items():
                region_data = filtered_data[data['geo'] == region]

                if region_data.size == 0:
                    continue

                # Create Series without the values used for filtering
                region_data = region_data.transpose()
                region_data.drop(index=leading_cols, inplace=True)
                region_data = region_data[region_data.columns[0]].squeeze()

                # Strip flags and trailing spaces from the values
                region_data = region_data.apply(lambda x: str(x).split(' ', maxsplit=1)[0]).astype(np.float64)

                # Strip leading and trailing NaNs and interpolate intermediary missing values
                region_data = utils.strip_nans(region_data)
                region_data = region_data.interpolate()

                # Save data
                dataset = Dataset(
                    props['id'],
                    data_source,
                    props['name'],
                    props['description'],
                    LINK % dataset_id,
                    props['unit'])

                dataset.add_time_series(TimeSeries(
                    data_source,
                    props,
                    storage.regions[region_id],
                    region_data))

                data_source.add_dataset(dataset)

    storage.add_data_source(data_source)
