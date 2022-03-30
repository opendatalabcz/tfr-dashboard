import datetime

import numpy as np
import world_bank_data as wb

import lib.db as db

print('Collecting World Bank')

data_source = 'world_bank'

# Datasets to collect along with their metadata
datasets = {
    'SP.DYN.TFRT.IN': {
        'id': 'tfr',
        'name': 'Total fertility rate',
        'description': 'Počet dětí, které by žena mohla mít, kdyby po celý její život platily hodnoty plodnosti podle věku pro daný rok.',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=SP.DYN.TFRT.IN',
        'unit': 'počet dětí'
    },
    'EN.ATM.CO2E.KT': {
        'id': 'co2_emissions',
        'name': 'Emise CO2',
        'description': 'Emise CO2 vzniklé spalování fosilních paliv a výrobou cementu.',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=EN.ATM.CO2E.KT',
        'unit': 'kt'
    },
    'FR.INR.DPST': {
        'id': 'deposit_interest_rate',
        'name': 'Úrok z vkladu',
        'description': 'Úrok z vkladu komerčních bank podle MMF.',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=FR.INR.DPST',
        'unit': '%'
    },
    'NY.GDP.PCAP.PP.CD': {
        'id': 'gdp',
        'name': 'HDP per capita',
        'description': 'HDP per capita v mezinárodních dolarech podle parity kupní síly',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=NY.GDP.PCAP.PP.CD',
        'unit': 'mezinárodní dolary'
    },
    'FP.CPI.TOTL.ZG': {
        'id': 'inflation',
        'name': 'Inflace',
        'description': 'Inflace podle indexu spotřebitelských cen',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=FP.CPI.TOTL.ZG',
        'unit': '%'
    },
    'SL.TLF.ACTI.1524.FE.ZS': {
        'id': 'lfp_young_female',
        'name': 'Participace žen 15-24 let v pracovním procesu',
        'description': 'Podíl ekonomicky aktivních žen ve věku 15-24 (odhad ILOSTAT)',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=SL.TLF.ACTI.1524.FE.ZS',
        'unit': '%'
    },
    'SL.TLF.ACTI.1524.MA.ZS': {
        'id': 'lfp_young_male',
        'name': 'Participace mužů 15-24 let v pracovním procesu',
        'description': 'Podíl ekonomicky aktivních mužů ve věku 15-24 (odhad ILOSTAT)',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=SL.TLF.ACTI.1524.MA.ZS',
        'unit': '%'
    },
    'SL.TLF.ACTI.1524.ZS': {
        'id': 'lfp_young',
        'name': 'Participace osob 15-24 let v pracovním procesu',
        'description': 'Podíl ekonomicky aktivních osob ve věku 15-24 (odhad ILOSTAT)',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=SL.TLF.ACTI.1524.ZS',
        'unit': '%'
    },
    'SL.TLF.CACT.FE.ZS': {
        'id': 'lfp_female',
        'name': 'Participace žen 15+ v pracovním procesu',
        'description': 'Podíl ekonomicky aktivních žen ve věku 15 a více let (odhad ILOSTAT)',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=SL.TLF.CACT.FE.ZS',
        'unit': '%'
    },
    'SL.TLF.CACT.MA.ZS': {
        'id': 'lfp_male',
        'name': 'Participace mužů 15+ v pracovním procesu',
        'description': 'Podíl ekonomicky aktivních mužů ve věku 15 a více let (odhad ILOSTAT)',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=SL.TLF.CACT.MA.ZS',
        'unit': '%'
    },
    'SL.TLF.CACT.ZS': {
        'id': 'lfp',
        'name': 'Participace osob 15+ v pracovním procesu',
        'description': 'Podíl ekonomicky aktivních osob ve věku 15 a více let (odhad ILOSTAT)',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=SL.TLF.CACT.ZS',
        'unit': '%'
    },
    'SG.GEN.PARL.ZS': {
        'id': 'women_in_parliament',
        'name': 'Podíl žen v parlamentu',
        'description': 'Procento žen v parlamentu (v dolní komoře, pokud je dvoukomorový) (IPU)',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=SG.GEN.PARL.ZS',
        'unit': '%'
    },
    'SL.TLF.CACT.FM.ZS': {
        'id': 'lfp_female_to_male',
        'name': 'Poměr participace žen vůči mužům v pracovním procesu',
        'description': 'Podíl partiticipace žen a mužů vyjádřený v procentech (odhad ILOSTAT)',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=SL.TLF.CACT.FM.ZS',
        'unit': '%'
    },
    'SH.STA.SUIC.P5': {
        'id': 'suicide_mortality_rate',
        'name': 'Sebevražednost',
        'description': 'Hrubý počet sebevražd na 100000 obyvatel (WHO)',
        'url': 'https://databank.worldbank.org/reports.aspx?source=2&series=SH.STA.SUIC.P5',
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
    'SWE'
]

# Add data source record
conn = db.Connection(data_source)
conn.add_data_source(
    name='World Bank',
    description='Otevřená data World Bank',
    url='https://data.worldbank.org/')

# Collect data since 1980 until now
year = datetime.date.today().strftime("%Y")
for dataset in datasets:
    print('Fetching dataset %s' % dataset)

    series = wb.get_series(dataset, date='1980:%s' % year, id_or_value='id', simplify_index=True)

    # Process dataset for each selected region
    for region in regions:
        print('- %s' % region)
        data = series[region]

        # Remove leading and trailing years with missing values
        years = data.index

        start = 0
        while start <= len(years) - 1:
            if not np.isnan(data[years[start]]):
                break
            start = start + 1

        end = len(years) - 1
        while end >= 0:
            if not np.isnan(data[years[end]]):
                break
            end = end - 1
        data = data.iloc[start:(end + 1)] # Last index is exclusive

        # Compute intermediary missing values using interpolation
        data = data.interpolate()

        # Save data
        props = datasets[dataset]

        rows = []
        for row in data.iteritems():
            rows.append(row)

        if len(rows) != 0:
            conn.add_dataset(
                dataset=props['id'],
                region=region.lower(),
                name=props['name'],
                description=props['description'],
                url=props['url'],
                unit=props['unit'],
                data=rows)
        else:
            print('  No data')
