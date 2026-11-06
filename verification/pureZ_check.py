# -*- coding: utf-8 -*-
"""A-level check (PBW basis of the Heisenberg algebra A, exact rationals):
a * X^(p+1) can have a nonzero pure-Z component Z^(p+q),
with a = Y^(p+1) Z^(q-1).   Self-contained (no imports from other scripts)."""
from fractions import Fraction as F
from math import comb, factorial

def mul_mono(m1, m2):
    a, b, k = m1; a2, b2, k2 = m2
    out = {}
    for j in range(0, min(b, a2) + 1):
        c = F((-1) ** j * comb(b, j) * comb(a2, j) * factorial(j))
        out[(a + a2 - j, b - j + b2, k + k2 + j)] = out.get((a + a2 - j, b - j + b2, k + k2 + j), F(0)) + c
    return {kk: v for kk, v in out.items() if v != 0}

def mul(e1, e2):
    out = {}
    for m1, c1 in e1.items():
        for m2, c2 in e2.items():
            for m, c in mul_mono(m1, m2).items():
                out[m] = out.get(m, F(0)) + c1 * c2 * c
    return {k: v for k, v in out.items() if v != 0}

one = {(0, 0, 0): F(1)}
def pw(e, n):
    r = one
    for _ in range(n): r = mul(r, e)
    return r

X = {(1, 0, 0): F(1)}; Y = {(0, 1, 0): F(1)}; Z = {(0, 0, 1): F(1)}

print("=== a * X^(p+1) with a = Y^(p+1) Z^(q-1) : pure-Z component ===")
for (p, q) in [(1,1),(2,1),(2,2),(3,2),(3,3),(4,3),(4,4),(5,4)]:
    if q < 1: continue
    a = mul(pw(Y, p + 1), pw(Z, q - 1))
    elem = mul(a, pw(X, p + 1))
    c = elem.get((0, 0, p + q), F(0))
    pred = F((-1) ** (p + 1) * factorial(p + 1))
    assert c == pred, (p, q, c, pred)
    print("  p=%d q=%d : coeff of Z^(p+q) = %s   predicted (-1)^(p+1)(p+1)! = %s   match=%s"
          % (p, q, c, pred, c == pred))

print("PASS: 8 pure-Z coefficient identities in A, not quotient nonmembership")
