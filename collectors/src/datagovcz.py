import pandas as pd

import lib.db as db

print('Data.gov.cz')

conn = db.Connection('datagovcz')
conn.add_data_source(
    name='Národní katalog otevřených dat ČR',
    description='Otevřená data zveřejňovaná institucemi českého státu',
    url='https://data.gov.cz/')

# Pensions
print('- Pensions')
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

# Save data
rows = []
for row in data.itertuples():
    rows.append((row.year, row.value))

conn.add_dataset(
    dataset='pensions_count',
    region='cze',
    name='Počet důchodů',
    description='Počet všech typů důchodů vyplacených za rok',
    url='https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00006963%2F4ca9223c497b1ee13011611498c3155f',
    unit='počet důchodů',
    data=rows)

# Schools
print('- Schools')
data = pd.read_csv('https://www.czso.cz/documents/62353418/143522558/230057-21data102921.csv')

# Extract data
data = data[(data['vuzemi_cis'] == 97) & ((data['ds_kod'] == 10) | (data['ds_kod'] == 20)) & (data['stapro_kod'] == 6053)]

data = data[['rok', 'ds_kod', 'hodnota']]

data = data.groupby(['rok'])['hodnota'].sum()

# Save data
rows = []
for row in data.iteritems():
    rows.append(row)

conn.add_dataset(
    dataset='classrooms_count',
    region='cze',
    name='Počet tříd',
    description='Počet tříd mateřských a základních škol',
    url='https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2F4b1efc67d6113e657b5332ede85d32fc',
    unit='počet tříd',
    data=rows)

# Apartments
print('- Apartments')
data = pd.read_csv('https://www.czso.cz/documents/62353418/143522520/200068-21data060821.zip', compression='zip')

# Extract data
data = data.groupby(['rok'])['hodnota'].sum()

# Save data
rows = []
for row in data.iteritems():
    rows.append(row)

conn.add_dataset(
    dataset='apartments',
    region='cze',
    name='Dokončené byty',
    description='Počet dokončených bytů včetně bytů v rodinných domcích a bytových domech',
    url='https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2F5aecb836332131bd6ce0a75fbbf23fb5',
    unit='počet bytů',
    data=rows)

# Unemployment by sex
data = pd.read_csv('https://www.czso.cz/documents/62353418/143520414/250180-21data123021.csv')

# Extract data
data_men = data[(data['stapro_txt'] == 'Obecná míra nezaměstnanosti') & (data['pohlavi_kod'] == 1) & (data['uzemi_cis'] == 97)][['rok', 'hodnota']].groupby('rok')['hodnota'].mean()

data_women = data[(data['stapro_txt'] == 'Obecná míra nezaměstnanosti') & (data['pohlavi_kod'] == 2) & (data['uzemi_cis'] == 97)][['rok', 'hodnota']].groupby('rok')['hodnota'].mean()

# Save data
print('- Unemployed men')
rows = []
for row in data_men.iteritems():
    rows.append(row)

conn.add_dataset(
    dataset='unemployment_men',
    region='cze',
    name='Míra nezaměstnanosti mužů',
    description='Nezaměstnaní podle výsledků výběrového šetření pracovních sil',
    url='https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2Ff35dda6e266c29b4572b295306d93991',
    unit='podíl nezaměstnaných',
    data=rows)

print('- Unemployed women')
rows = []
for row in data_women.iteritems():
    rows.append(row)

conn.add_dataset(
    dataset='unemployment_women',
    region='cze',
    name='Míra nezaměstnanosti žen',
    description='Nezaměstnaní podle výsledků výběrového šetření pracovních sil',
    url='https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2Ff35dda6e266c29b4572b295306d93991',
    unit='podíl nezaměstnaných',
    data=rows)

# Wages
data = pd.read_csv('https://www.czso.cz/documents/62353418/143522174/110080-21data052421.csv')

# Extract data
data_men = data[(data['POHLAVI_kod'] == 1) & (data['uzemi_cis'] == 97) & (data['SPKVANTIL_cis'] == 7636)][['rok', 'hodnota']].set_index(['rok']).sort_index()

data_women = data[(data['POHLAVI_kod'] == 2) & (data['uzemi_cis'] == 97) & (data['SPKVANTIL_cis'] == 7636)][['rok', 'hodnota']].set_index(['rok']).sort_index()

# Save data
print('- Wages men')
rows = []
for row in data_men.iteritems():
    rows.append(row)

conn.add_dataset(
    dataset='wages_men',
    region='cze',
    name='Medián mezd mužů',
    description='Medián měsíčních mezd mužů',
    url='https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2F6be519cff8c390ae9003292b6c56c9ca',
    unit='Kč',
    data=rows)

print('- Wages women')
rows = []
for row in data_men.iteritems():
    rows.append(row)

conn.add_dataset(
    dataset='wages_women',
    region='cze',
    name='Medián mezd žen',
    description='Medián měsíčních mezd žen',
    url='https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2F6be519cff8c390ae9003292b6c56c9ca',
    unit='Kč',
    data=rows)