# -*- coding: utf-8 -*-
"""Compatibility entry point for the exact homogeneous quotient calculation.

The historical implementation truncated both X and Y powers as if the left
ideal were two-sided. That is invalid: p=0,q=1 gave index 2 instead of 3.
All public power computations now use conj2's homogeneous left-ideal backend.
"""
from conj2 import T_powers
from verify import shows as show


def T_power_on_v(p, q, n):
    """Return the exact class of (X+Y)^n in A/(AX^(p+1)+AY^(q+1))."""
    return T_powers(p, q, n)[n]


if __name__ == "__main__":
    assert T_power_on_v(0, 1, 2), "regression: T^2 must be nonzero"
    assert not T_power_on_v(0, 1, 3)
    for p in range(5):
        row = []
        for q in range(5):
            expected = 2 * (p + q) + 1
            values = T_powers(p, q, expected)
            actual = next((n for n, value in enumerate(values) if not value), None)
            assert actual == expected, (p, q, actual, expected)
            row.append("(%d,%d)->%d" % (p, q, actual))
        print("  ".join(row))
    print("PASS: compatibility entry point; 25 finite exact cases, p,q in 0..4")
