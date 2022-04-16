"""Data.gov.cz data source collector"""

import pandas as pd

from lib.storage import Storage, DataSource, Dataset, TimeSeries

def collect(storage: Storage):
    """Collect data from the data source"""

    data_source = DataSource(
        'datagovcz',
        'Národní katalog otevřených dat ČR',
        'Otevřená data zveřejňovaná institucemi českého státu',
        'https://data.gov.cz/')
    region = storage.regions['cze']

    # Pensions
    print('  - Pensions')
    data = pd.read_csv('https://data.cssz.cz/dump/duchody-dle-veku.csv')

    # Extract data
    data = data[(data['pohlavi_kod'] == 'T') & (data['vek_kod'] == '0+')]
    data = data[['referencni_obdobi', 'pocet_duchodu']]

    data = pd.concat([
        data.referencni_obdobi.str[0:4],
        data['pocet_duchodu']
    ], axis=1)

    data = data.groupby(['referencni_obdobi'])['pocet_duchodu'].sum().reset_index()

    data.rename(columns = {
        'referencni_obdobi': 'year',
        'pocet_duchodu': 'value'
        }, inplace = True)

    index = data['year']
    series = pd.Series(data=data['value'], name='pensions_count')
    series.index = index # Assign index afterwards to avoid having NaN values???

    # Save data
    dataset = Dataset(
        'pensions_count',
        data_source,
        'Počet důchodů',
        'Počet všech typů důchodů vyplacených za rok',
        'https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00006963%2F4ca9223c497b1ee13011611498c3155f',
        'počet důchodů',
        )
    dataset.add_time_series(TimeSeries(data_source, dataset, region, series))
    data_source.add_dataset(dataset)

    # Schools
    print('  - Schools')
    data = pd.read_csv('https://www.czso.cz/documents/62353418/143522558/230057-21data102921.csv')

    # Extract data
    data = data[(data['vuzemi_cis'] == 97)
        & ((data['ds_kod'] == 10) | (data['ds_kod'] == 20))
        & (data['stapro_kod'] == 6053)]

    data = data[['rok', 'ds_kod', 'hodnota']]

    data = data.groupby(['rok'])['hodnota'].sum()

    data.name = 'classrooms_count'

    # Save data
    dataset = Dataset(
        'classrooms_count',
        data_source,
        'Počet tříd',
        'Počet tříd mateřských a základních škol',
        'https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2F4b1efc67d6113e657b5332ede85d32fc',
        'počet tříd')
    dataset.add_time_series(TimeSeries(data_source, dataset, region, data))
    data_source.add_dataset(dataset)

    # Apartments
    print('  - Apartments')
    data = pd.read_csv('https://www.czso.cz/documents/62353418/143522520/200068-21data060821.zip', compression='zip')

    # Extract data
    data = data.groupby(['rok'])['hodnota'].sum()

    data.name = 'apartments'

    # Save data
    dataset = Dataset(
        'apartments',
        data_source,
        'Dokončené byty',
        'Počet dokončených bytů včetně bytů v rodinných domcích a bytových domech',
        'https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2F5aecb836332131bd6ce0a75fbbf23fb5',
        'počet bytů')
    dataset.add_time_series(TimeSeries(data_source, dataset, region, data))
    data_source.add_dataset(dataset)

    # Unemployment by sex
    data = pd.read_csv('https://www.czso.cz/documents/62353418/143520414/250180-21data123021.csv')

    # Extract data
    data_men = data[(data['stapro_txt'] == 'Obecná míra nezaměstnanosti')
        & (data['pohlavi_kod'] == 1)
        & (data['uzemi_cis'] == 97)][['rok', 'hodnota']].groupby('rok')['hodnota'].mean()

    data_men.name = 'unemployment_men'

    data_women = data[(data['stapro_txt'] == 'Obecná míra nezaměstnanosti')
        & (data['pohlavi_kod'] == 2)
        & (data['uzemi_cis'] == 97)][['rok', 'hodnota']].groupby('rok')['hodnota'].mean()

    data_women.name = 'unemployment_women'

    # Save data
    print('  - Unemployed men')
    dataset = Dataset(
        'unemployment_men',
        data_source,
        'Míra nezaměstnanosti mužů',
        'Nezaměstnaní podle výsledků výběrového šetření pracovních sil',
        'https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2Ff35dda6e266c29b4572b295306d93991',
        'podíl nezaměstnaných')
    dataset.add_time_series(TimeSeries(data_source, dataset, region, data_men))
    data_source.add_dataset(dataset)

    print('  - Unemployed women')
    dataset = Dataset(
        'unemployment_women',
        data_source,
        'Míra nezaměstnanosti žen',
        'Nezaměstnaní podle výsledků výběrového šetření pracovních sil',
        'https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2Ff35dda6e266c29b4572b295306d93991',
        'podíl nezaměstnaných')
    dataset.add_time_series(TimeSeries(data_source, dataset, region, data_women))
    data_source.add_dataset(dataset)

    # Wages
    data = pd.read_csv('https://www.czso.cz/documents/62353418/143522174/110080-21data052421.csv')

    # Extract data
    data_men = data[(data['POHLAVI_kod'] == 1)
        & (data['uzemi_cis'] == 97)
        & (data['SPKVANTIL_cis'] == 7636)][['rok', 'hodnota']].set_index(['rok']).sort_index()

    index = data_men.index
    data_men = pd.Series(data=data_men['hodnota'], name='wages_men')
    data_men.index = data_men.index  # Assign index afterwards to avoid having NaN values???

    data_women = data[(data['POHLAVI_kod'] == 2)
        & (data['uzemi_cis'] == 97)
        & (data['SPKVANTIL_cis'] == 7636)][['rok', 'hodnota']].set_index(['rok']).sort_index()

    index = data_women.index
    data_women = pd.Series(data=data_women['hodnota'], name='wages_women')
    data_women.index = data_women.index  # Assign index afterwards to avoid having NaN values???

    # Save data
    print('  - Wages men')
    dataset = Dataset(
        'wages_men',
        data_source,
        'Medián mezd mužů',
        'Medián měsíčních mezd mužů',
        'https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2F6be519cff8c390ae9003292b6c56c9ca',
        'Kč')
    dataset.add_time_series(TimeSeries(data_source, dataset, region, data_men))
    data_source.add_dataset(dataset)

    print('  - Wages women')
    dataset = Dataset(
        'wages_women',
        data_source,
        'Medián mezd žen',
        'Medián měsíčních mezd žen',
        'https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2F6be519cff8c390ae9003292b6c56c9ca',
        'Kč')
    dataset.add_time_series(TimeSeries(data_source, dataset, region, data_women))
    data_source.add_dataset(dataset)

    storage.add_data_source(data_source)
