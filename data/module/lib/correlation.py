"""Correlation decision module"""

def is_correlation(p_value: float) -> bool:
    """Determine whether there is a strong enough statement about the time series
    based on constant threshold.
    The threshold is defined for the p-value of a test with the null hypothesis
    that the slope of linear regression line is zero."""

    if p_value is None:
        return None

    return p_value <= 0.05
