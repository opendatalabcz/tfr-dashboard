"""Time series forecasting module
Inserts a new data source with a TFR dataset with forecasted time series
from each region if forecasting is successful.
"""

import pandas as pd
import pmdarima as pm

from lib.storage import Storage, DataSource, Dataset, TimeSeries

forecast_years = 10

def process(storage: Storage):
    """Process time series in the storage.
    Creates new data source with a forecast of TFR values.
    """

    data_source = DataSource('forecast', 'Předpovědi', 'Předpovědi vývojů ukazatelů', '/')

    dataset = Dataset(
        'tfr_forecast',
        data_source,
        'Předpověď TFR',
        'Předpověď vývoje TFR - Počet dětí, které by žena mohla mít, '
            'kdyby po celý její život platily hodnoty plodnosti podle věku pro daný rok.',
        '/',
        'počet dětí')

    for series in storage.tfr_dataset.time_series.values():

        model_fit = pm.auto_arima(series.series, start_p=0, start_q=0, max_p=10, max_q=10,
            seasonal=False, m=1, # No seasonality
            d=None, max_d=2, test='kpss', # Differencing
            trace=False, error_action='ignore', suppress_warnings=True, # Logging
            stepwise=False)

        pred_array = model_fit.predict(forecast_years)

        last_year = int(series.series.index[-1]) + 1
        pred = pd.Series(
            pred_array,
            index=[str(i) for i in range(last_year, last_year + forecast_years)])

        dataset.add_time_series(TimeSeries(
            data_source,
            dataset,
            series.region,
            pred
        ))

    data_source.add_dataset(dataset)
    storage.add_data_source(data_source)
