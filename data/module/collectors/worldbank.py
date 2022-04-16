"""World Bank data source collector"""

import datetime

import pandas as pd
import world_bank_data as wb

from lib import utils
from lib.storage import Storage, DataSource, Dataset, TimeSeries

LINK = 'https://databank.worldbank.org/reports.aspx?source=2&series=%s'

# Datasets to collect along with their metadata
datasets = {
    'SP.DYN.TFRT.IN': {
        'id': 'tfr',
        'name': 'Total fertility rate',
        'description': 'Počet dětí, které by žena mohla mít, kdyby po celý její život platily hodnoty plodnosti podle věku pro daný rok.',
        'unit': 'počet dětí'
    },
    'EN.ATM.CO2E.KT': {
        'id': 'co2_emissions',
        'name': 'Emise CO2',
        'description': 'Emise CO2 vzniklé spalování fosilních paliv a výrobou cementu.',
        'unit': 'kt'
    },
    'FR.INR.DPST': {
        'id': 'deposit_interest_rate',
        'name': 'Úrok z vkladu',
        'description': 'Úrok z vkladu komerčních bank podle MMF.',
        'unit': '%'
    },
    'NY.GDP.PCAP.PP.CD': {
        'id': 'gdp',
        'name': 'HDP per capita',
        'description': 'HDP per capita v mezinárodních dolarech podle parity kupní síly',
        'unit': 'mezinárodní dolary'
    },
    'FP.CPI.TOTL.ZG': {
        'id': 'inflation',
        'name': 'Inflace',
        'description': 'Inflace podle indexu spotřebitelských cen',
        'unit': '%'
    },
    'SL.TLF.ACTI.1524.FE.ZS': {
        'id': 'lfp_young_female',
        'name': 'Participace žen 15-24 let v pracovním procesu',
        'description': 'Podíl ekonomicky aktivních žen ve věku 15-24 (odhad ILOSTAT)',
        'unit': '%'
    },
    'SL.TLF.ACTI.1524.MA.ZS': {
        'id': 'lfp_young_male',
        'name': 'Participace mužů 15-24 let v pracovním procesu',
        'description': 'Podíl ekonomicky aktivních mužů ve věku 15-24 (odhad ILOSTAT)',
        'unit': '%'
    },
    'SL.TLF.ACTI.1524.ZS': {
        'id': 'lfp_young',
        'name': 'Participace osob 15-24 let v pracovním procesu',
        'description': 'Podíl ekonomicky aktivních osob ve věku 15-24 (odhad ILOSTAT)',
        'unit': '%'
    },
    'SL.TLF.CACT.FE.ZS': {
        'id': 'lfp_female',
        'name': 'Participace žen 15+ v pracovním procesu',
        'description': 'Podíl ekonomicky aktivních žen ve věku 15 a více let (odhad ILOSTAT)',
        'unit': '%'
    },
    'SL.TLF.CACT.MA.ZS': {
        'id': 'lfp_male',
        'name': 'Participace mužů 15+ v pracovním procesu',
        'description': 'Podíl ekonomicky aktivních mužů ve věku 15 a více let (odhad ILOSTAT)',
        'unit': '%'
    },
    'SL.TLF.CACT.ZS': {
        'id': 'lfp',
        'name': 'Participace osob 15+ v pracovním procesu',
        'description': 'Podíl ekonomicky aktivních osob ve věku 15 a více let (odhad ILOSTAT)',
        'unit': '%'
    },
    'SG.GEN.PARL.ZS': {
        'id': 'women_in_parliament',
        'name': 'Podíl žen v parlamentu',
        'description': 'Procento žen v parlamentu (v dolní komoře, pokud je dvoukomorový) (IPU)',
        'unit': '%'
    },
    'SL.TLF.CACT.FM.ZS': {
        'id': 'lfp_female_to_male',
        'name': 'Poměr participace žen vůči mužům v pracovním procesu',
        'description': 'Podíl partiticipace žen a mužů vyjádřený v procentech (odhad ILOSTAT)',
        'unit': '%'
    },
    'SH.STA.SUIC.P5': {
        'id': 'suicide_mortality_rate',
        'name': 'Sebevražednost',
        'description': 'Hrubý počet sebevražd na 100 000 obyvatel (WHO)',
        'unit': 'počet sebevražd'
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
    'SWE',
    'NOR', # Others
    'GBR'
]

def collect(storage: Storage):
    """Collect data from the data source"""

    data_source = DataSource(
        'world_bank',
        'World Bank',
        'Otevřená data World Bank',
        'https://data.worldbank.org/')

    # Collect data since 1980 until now
    year = datetime.date.today().strftime("%Y")
    for dataset_id, props in datasets.items():
        print('  - ' + dataset_id)

        dataset = Dataset(
            props['id'],
            data_source,
            props['name'],
            props['description'],
            LINK % dataset_id,
            props['unit'])

        series = wb.get_series(
            dataset_id,
            date=f'1980:{year}',
            id_or_value='id',
            simplify_index=True)

        # Process dataset_id for each selected region
        for region in regions:
            data = series[region]

            data = utils.strip_nans(data)

            # Compute intermediary missing values using interpolation
            data = data.interpolate()

            # Save data
            if data.size != 0:
                time_series = TimeSeries(
                    data_source,
                    dataset,
                    storage.regions[region.lower()],
                    # pd.Series(data=data.values.copy(), index=data.index.copy(), name=str(dataset_id)))
                    data)
                dataset.add_time_series(time_series)

        data_source.add_dataset(dataset)

    storage.add_data_source(data_source)
    storage.tfr_dataset = data_source.datasets['tfr']
