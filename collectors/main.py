import os

if not 'EXCLUDE_WORLDBANK' in os.environ:
    import src.worldbank
else:
    print('Skipping World Bank')

if not 'EXCLUDE_DATAGOVCZ' in os.environ:
    import src.datagovcz
else:
    print('Skipping data.gov.cz')
