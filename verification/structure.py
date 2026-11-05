# -*- coding: utf-8 -*-
"""Which PBW monomials X^a Y^b Z^k vanish in M_{p,q} = A/(A X^{p+1}+A Y^{q+1}) ?"""
from conj2 import Quotient, basis_degree
from fractions import Fraction as F

for (p, q) in [(1, 1), (1, 2), (2, 2)]:
    print("=" * 70)
    print("p = %d, q = %d :  M = A/(A X^%d + A Y^%d)" % (p, q, p + 1, q + 1))
    maxdeg = 2 * (p + q) + 4
    Q = Quotient(p, q, maxdeg)
    dims = []
    for d in range(0, maxdeg + 1):
        dims.append(len(basis_degree(d)) - len(Q.reduced[d]))
    print("  dim M_d for d=0..%d : %s   (total %d)" % (maxdeg, dims, sum(dims)))
    print("  vanishing of X^a Y^b Z^k  ('.' = nonzero, '0' = zero), rows = k, cols = (a,b)")
    for k in range(0, (p + q) + 3):
        row = []
        for a in range(0, p + 2):
            for b in range(0, q + 2):
                d = a + b + 2 * k
                if d > maxdeg:
                    row.append(" ")
                    continue
                vec = Q.reduce({(a, b, k): F(1)}, d)
                row.append("." if vec else "0")
        print("   k=%d : %s" % (k, " ".join(row)))
    print("   (a,b) order:", [(a, b) for a in range(0, p + 2) for b in range(0, q + 2)])
