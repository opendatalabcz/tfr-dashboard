"""Correlation decision module"""

def is_correlation(p_value: float, r_value: float):
    """Determine whether there is a correlation based on constant thresholds.
    The thresholds are defined for the p-value of a test with the null hypothesis
    that the slope of linear regression line is zero and for the r-value of
    Pearson's correlation coefficient."""

    if p_value is None or r_value is None:
        return None

    return p_value <= 0.05 and abs(r_value) >= 0.4
