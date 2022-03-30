import os

if not 'EXCLUDE_WORLDBANK' in os.environ:
    import src.worldbank
else:
    print('Skipping World Bank')
