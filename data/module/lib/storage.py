"""Data storage container and related data classes"""

from typing import List
import pandas as pd

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

class Dataset:
    """Dataset with its metadata and time series"""

    def __init__(self, dataset_id: str, data_source, name: str, description: str, url: str, unit: str):
        self.dataset_id = dataset_id
        self.data_source = data_source
        self.name = name
        self.description = description
        self.url = url
        self.unit = unit

        self.time_series = {}

    def add_time_series(self, time_series: TimeSeries):
        """Add time series to the dataset"""

        self.time_series[time_series.region] = time_series

class DataSource:
    """Data source with its metadata and datasets"""

    def __init__(self, data_source_id: str, name: str, description: str, url: str):
        self.data_source_id = data_source_id
        self.name = name
        self.description = description
        self.url = url

        self.datasets = {}

    def add_dataset(self, dataset: Dataset):
        """Add dataset to the data source"""

        self.datasets[dataset.dataset_id] = dataset

class Storage:
    """Manages gathered data, provides it to statistics engine and handles persistence"""

    regions = {}
    data_sources = {}
    datasets = {}
    time_series = {}

    def add_data_source(self, data_source: DataSource):
        """Add a data source"""

        self.data_sources[data_source.data_source_id] = data_source

    def add_region(self, region: Region):
        """Add a region"""

        self.regions[region.region_id] = region

    def add_regions(self, regions: List[Region]):
        """Add multiple regions"""

        for region in regions:
            self.add_region(region)
