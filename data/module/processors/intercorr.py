"""Inter-region correlation processing module"""

from scipy.stats import linregress

from lib.storage import Storage
from lib.correlation import is_correlation

def process(storage: Storage):
    """Process time series in the storage"""

    all_tfr = storage.tfr_dataset.all_series(storage.regions)
    min_values_per_year = 5
    min_years = 5

    for data_source in storage.data_sources.values():
        for dataset in data_source.datasets.values():
            dataset.recompute_values_per_year(all_tfr, storage.regions, min_values_per_year)
            if len(dataset.values_per_year) >= min_years:
                p_values: dict[str, float] = {} # p_values per year
                r_values: dict[str, float] = {} # r_values per year
                correlations: dict[str, bool] = {} # correlations per year
                for year, series in dataset.values_per_year.items():
                    results = linregress(series.index, series.values)
                    p_values[year] = results[3]
                    r_values[year] = results[2]
                    correlations[year] = is_correlation(results[3])
                dataset.set_inter_region_correlation_p_values(p_values)
                dataset.set_inter_region_correlation_r_values(r_values)
                dataset.set_inter_region_correlations(correlations)
