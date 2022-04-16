"""Time series pairwise correlation processing module"""

import pandas as pd
from scipy.stats import linregress

from lib.storage import Storage

def lag_interval(lagging: tuple[int, int], static: tuple[int, int], lag: int) \
        -> tuple[tuple[int, int], tuple[int, int], int]:
    """Compute bounds when given intervals are lagged

    Parameters:
    - lagging: interval to be lagged
    - static: interval to relate the lag to
    - lag: relative lag, positive value points to the past

    Returns:
    - new_lagging: new bounds of the lagged interval or None if invalid
    - new_static: new bounds of the lagged interval or None if invalid
    - length: length of the both intervals of None if interval(s) invalid
    """

    # Compute start points
    lagging_start = lagging[0]
    static_start = lagging_start + lag

    if static_start < static[0]:
        lagging_start += static[0] - static_start
        static_start = static[0]

    # Compute end points
    static_end = static[1]
    lagging_end = static_end - lag

    if lagging_end > lagging[1]:
        static_end -= lagging_end - lagging[1]
        lagging_end = lagging[1]

    # Validate results
    if static_start > static_end or lagging_start > lagging_end:
        return None, None, None

    new_lagging = (lagging_start, lagging_end)
    new_static = (static_start, static_end)
    length = lagging_end - lagging_start + 1

    return new_lagging, new_static, length

def best_lag(tfr: pd.Series, other: pd.Series, maxlags: int = 5) -> tuple:
    """Find the best correlation and regression of tfr and other time series
    between -maxlags and maxlags. The correlation with the biggest absolute r-value is
    considered the best.

    Returns:
    - lag of the best correlation
    - slope of the linear regression line
    - intercept of the linear regression line
    - r_value (correlation coefficient of the series)
    - p_value of a test with the null hypothesis that the slope is 0
    - std_err of the slope
    - intercept_std_err
    """

    min_data_lenght = 5 # Minimal number of data points to compute the correlation

    tfr_interval = (int(tfr.index[0]), int(tfr.index[-1]))
    tfr_length = tfr_interval[1] - tfr_interval[0]

    other_interval = (int(other.index[0]), int(other.index[-1]))
    other_length = other_interval[1] - other_interval[0]

    min_length = int(max(min_data_lenght, min(tfr_length, other_length) / 2))

    relations: dict[int, tuple] = {}

    for lag in range(-maxlags, maxlags):
        tfr_lagged, other_lagged, length = lag_interval(tfr_interval, other_interval, lag)

        if length is not None and length >= min_length:
            primary = tfr.copy()
            secondary = other.copy()

            primary.index = primary.index.astype(int)
            secondary.index = secondary.index.astype(int)
            primary = primary.loc[(primary.index >= tfr_lagged[0])
                & (primary.index <= tfr_lagged[1])]
            secondary = secondary.loc[(secondary.index >= other_lagged[0])
                & (secondary.index <= other_lagged[1])]

            relations[lag] = linregress(primary, secondary)
        else:
            pass
    
    if len(relations) == 0:
        return (None, None, None, None, None, None)

    max_r_value = 0
    max_r_value_lag = None
    for lag, props in relations.items():
        cur_r_value = abs(props[2])
        if cur_r_value > max_r_value:
            max_r_value = cur_r_value
            max_r_value_lag = lag
    
    return (max_r_value_lag, ) + relations[max_r_value_lag]

def process(storage: Storage):
    """Process time series in the storage"""

    for data_source in storage.data_sources.values():
        for dataset in data_source.datasets.values():
            for time_series in dataset.time_series.values():
                # First difference
                time_series.differenced = time_series.series.diff().iloc[1:]

                # Differencing may have deleted the only value we had.
                if time_series.differenced.size == 0:
                    continue

                # Normalization
                time_series.normalized = (time_series.differenced - time_series.differenced.mean()) \
                    / (time_series.differenced.max() - time_series.differenced.min())

                # Correlation and regression
                results = best_lag(storage.tfr_dataset.time_series[time_series.region].normalized, time_series.normalized)

                time_series.set_correlation_regression(results)
