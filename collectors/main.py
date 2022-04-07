import os

if not 'EXCLUDE_WORLDBANK' in os.environ:
    import src.worldbank
else:
    print('Skipping World Bank')

if not 'EXCLUDE_EUROSTAT' in os.environ:
    import src.eurostat
else:
    print('Skipping Eurostat')

if not 'EXCLUDE_DATAGOVCZ' in os.environ:
    import src.datagovcz
else:
    print('Skipping data.gov.cz')

if not 'EXCLUDE_GOOGLETRENDS' in os.environ:
    import src.googletrends
else:
    print('Skipping Google Trends')
