# -*- coding: utf-8 -*-
"""Finite dimension/membership tables, with asserted high-degree vanishing."""
from fractions import Fraction as F
from math import comb, factorial
from conj2 import Quotient, basis_degree

print("=== dim M_d (Hilbert series), p,q in 0..4 ===")
for p in range(0, 5):
    for q in range(0, 5):
        maxdeg = 2 * (p + q) + 3
        Q = Quotient(p, q, maxdeg)
        dims = [len(basis_degree(d)) - len(Q.reduced[d]) for d in range(maxdeg + 1)]
        print("  p=%d q=%d  total=%2d   %s" % (p, q, sum(dims), dims))

print()
print("=== which Z^k * B_m lie in I ?  (B_m = sum_{a+b=m} X^aY^b/(a!b!)) ===")
def B(m):
    out = {}
    for a in range(0, m + 1):
        b = m - a
        out[(a, b, 0)] = out.get((a, b, 0), F(0)) + F(1, factorial(a) * factorial(b))
    return out

def Zmul(e, k):
    return {(a, b, kk + k): v for (a, b, kk), v in e.items()}

membership_count = 0
vanishing_count = 0
for (p, q) in [(1, 1), (1, 2), (2, 2), (2, 3)]:
    print(" p=%d q=%d :  table of (k,m) with Z^k B_m = 0 mod I ; N0 = %d" % (p, q, 2 * p + 2 * q + 1))
    print("        m:  " + "  ".join("%2d" % m for m in range(0, 2 * (p + q) + 3)))
    for k in range(0, p + q + 2):
        row = []
        for m in range(0, 2 * (p + q) + 3):
            d = 2 * k + m
            Q = Quotient(p, q, d)
            e = Zmul(B(m), k)
            remainder = Q.reduce(e, d)
            membership_count += 1
            if d >= 2 * (p + q) + 1:
                assert not remainder, (p, q, k, m, remainder)
                vanishing_count += 1
            row.append(" 0" if not remainder else " .")
        print("      k=%d:  " % k + "  ".join(row))
    print()

print("PASS: %d finite Z^k B_m membership entries; %d high-degree vanishings asserted"
      % (membership_count, vanishing_count))
