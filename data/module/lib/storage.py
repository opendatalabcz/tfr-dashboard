"""Data storage container and related data classes"""

import pandas as pd
import numpy as np

from lib.correlation import is_correlation

class Region:
    """Geographical region"""

    def __init__(self, region_id: str, name: str):
        self.region_id = region_id
        self.name = name

class TimeSeries:
    """Time series with a pandas Series object
    This is a "realization of a dataset for a given region"
    The Series should have a name equal to data_source and index named Year
    """

    def __init__(self, data_source, dataset, region: Region, series: pd.Series):
        self.data_source = data_source
        self.dataset = dataset
        self.region = region
        self.series = series

        self.differenced: pd.Series = None
        self.normalized: pd.Series = None

        self.lag: int = None
        self.slope: float = None
        self.intercept: float = None
        self.r_value: float = None
        self.p_value: float = None
        self.std_err: float = None
        self.correlation: bool = None

    def set_correlation_regression(self, props: tuple):
        """Set the correlation and regression results
        Expects a tuple with the used lag as the first value,
        followed by the results of scipy.stats.linregress
        """

        self.lag = props[0]
        self.slope = props[1]
        self.intercept = props[2]
        self.r_value = props[3]
        self.p_value = props[4]
        self.std_err = props[5]
        self.correlation = is_correlation(self.p_value, self.r_value)

class Dataset:
    """Dataset with its metadata and time series"""

    def __init__(self, dataset_id: str, data_source, name: str, description: str, url: str, unit: str):
        self.dataset_id = dataset_id
        self.data_source = data_source
        self.name = name
        self.description = description
        self.url = url
        self.unit = unit

        self.time_series: dict[Region, TimeSeries] = {}
        """Time series from this dataset per region"""

        self.values_per_year: dict[str, pd.Series] = {}
        """Values from all time series per year with corresponding TFR values"""

        self.p_values_per_year: pd.Series = None
        """p-values for inter-region correlation per year"""

        self.r_values_per_year: pd.Series = None
        """r-values for inter-region correlation per year"""

        self.correlation_values_per_year: pd.Series = None
        """Truth values for inter-region correlation per year"""

    def add_time_series(self, time_series: TimeSeries):
        """Add time series to the dataset"""

        self.time_series[time_series.region] = time_series

    def all_series(self, regions: list[Region]) -> pd.DataFrame:
        """Construct a dataframe containing all time series of this dataset"""

        # Create a list of series ordered by regions
        all_series_list = []
        for region in regions.values():
            if region in self.time_series.keys():
                all_series_list.append(self.time_series[region].series)
            else:
                all_series_list.append(pd.Series(dtype=np.float64)) # Will produce NaNs for this region in the dataframe below

        all_series = pd.DataFrame(all_series_list)
        all_series.reset_index(inplace=True)
        all_series.drop(columns=['index'], inplace=True)

        return all_series

    def recompute_values_per_year(self, all_tfr: pd.DataFrame, regions: list[Region], min_values: int):
        """Refresh values_per_year
        min_values: minimum number of values from time series available
        to include a year in values_per_year
        """

        all_series = self.all_series(regions)
        for year in all_series.columns:
            if year in all_tfr.columns:
                # Add explanatory values for each region
                series = pd.Series(all_series[year])
                # Set index to the corresponding TFR values
                series.index = all_tfr[year]
                # Remove countries for which the value is missing
                series.dropna(inplace=True)
                if series.size >= min_values:
                    self.values_per_year[year] = series

    def set_inter_region_correlation_p_values(self, p_values: dict[str, float]):
        """Set the series of inter-region correlation p-values"""

        self.p_values_per_year = pd.Series(data=p_values.values(), index=p_values.keys())

    def set_inter_region_correlation_r_values(self, r_values: dict[str, float]):
        """Set the series of inter-region correlation r-values"""

        self.r_values_per_year = pd.Series(data=r_values.values(), index=r_values.keys())

    def set_inter_region_correlations(self, correlations: dict[str, bool]):
        """Set the series of inter-region correlation truth values"""

        self.correlation_values_per_year = pd.Series(data=correlations.values(),
            index=correlations.keys())

class DataSource:
    """Data source with its metadata and datasets"""

    def __init__(self, data_source_id: str, name: str, description: str, url: str):
        self.data_source_id = data_source_id
        self.name = name
        self.description = description
        self.url = url

        self.datasets: dict[str, Dataset] = {}

    def add_dataset(self, dataset: Dataset):
        """Add dataset to the data source"""

        self.datasets[dataset.dataset_id] = dataset

class Storage:
    """Manages gathered data, provides it to statistics engine and handles persistence"""

    def __init__(self):
        self.regions: dict[str, Region] = {}
        self.data_sources: dict[str, DataSource] = {}
        self.tfr_dataset: Dataset = None

    def add_data_source(self, data_source: DataSource):
        """Add a data source"""

        self.data_sources[data_source.data_source_id] = data_source

    def add_region(self, region: Region):
        """Add a region"""

        self.regions[region.region_id] = region

    def add_regions(self, regions: list[Region]):
        """Add multiple regions"""

        for region in regions:
            self.add_region(region)
