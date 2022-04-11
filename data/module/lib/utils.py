"""Utility functions module"""

import pandas as pd

def strip_nans(data):
    """Remove leading and trailing rows with missing values"""

    index = data.index

    start = 0
    while start <= len(index) - 1:
        if not pd.isnull(data[index[start]]):
            break
        start = start + 1

    end = len(index) - 1
    while end >= 0:
        if not pd.isnull(data[index[end]]):
            break
        end = end - 1

    return data.iloc[start:(end + 1)] # Last index is exclusive
