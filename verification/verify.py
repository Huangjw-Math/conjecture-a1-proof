# -*- coding: utf-8 -*-
"""
Independent exact checks (char 0, rational arithmetic) of every intermediate
statement used in the proof.  These are consistency checks, NOT proofs.

A = U(h_1) = K<X,Y,Z>/([X,Y]=Z, Z central), PBW basis X^a Y^b Z^k.
Normal-ordering rule used:  Y^b X^n = sum_j (-1)^j C(b,j) C(n,j) j! X^{n-j} Y^{b-j} Z^j.
"""
from fractions import Fraction as F
from math import comb, factorial
from conj2 import Quotient, basis_degree, I_basis, T_powers

def mul_mono(m1, m2):
    """product of two PBW monomials (a,b,k)*(a2,b2,k2), returned as dict"""
    a, b, k = m1
    a2, b2, k2 = m2
    out = {}
    for j in range(0, min(b, a2) + 1):
        coef = F((-1) ** j * comb(b, j) * comb(a2, j) * factorial(j))
        key = (a + a2 - j, b - j + b2, k + k2 + j)
        out[key] = out.get(key, F(0)) + coef
    return {kk: v for kk, v in out.items() if v != 0}

def mul(e1, e2):
    out = {}
    for m1, c1 in e1.items():
        for m2, c2 in e2.items():
            for m, c in mul_mono(m1, m2).items():
                out[m] = out.get(m, F(0)) + c1 * c2 * c
    return {kk: v for kk, v in out.items() if v != 0}

def add(e1, e2, s=1):
    out = dict(e1)
    for m, c in e2.items():
        out[m] = out.get(m, F(0)) + s * c
    return {kk: v for kk, v in out.items() if v != 0}

X = {(1, 0, 0): F(1)}
Y = {(0, 1, 0): F(1)}
Z = {(0, 0, 1): F(1)}
one = {(0, 0, 0): F(1)}

def pw(e, n):
    r = one
    for _ in range(n):
        r = mul(r, e)
    return r

def shows(e):
    if not e:
        return "0"
    return " + ".join("%s*X^%dY^%dZ^%d" % (c, m[0], m[1], m[2]) for m, c in sorted(e.items()))

# ---------- 1. the trinomial / generalized binomial formula ----------
print("=== CHECK 1: (X+Y)^n = sum_{a+b+2k=n} n!/(a!b!k!) (-1/2)^k X^a Y^b Z^k ===")
XdY = add(X, Y)
ok = True
for n in range(0, 9):
    lhs = pw(XdY, n)
    rhs = {}
    for k in range(0, n // 2 + 1):
        for a in range(0, n - 2 * k + 1):
            b = n - 2 * k - a
            c = F(factorial(n), factorial(a) * factorial(b) * factorial(k)) * F((-1) ** k, 2 ** k)
            rhs[(a, b, k)] = rhs.get((a, b, k), F(0)) + c
    rhs = {kk: v for kk, v in rhs.items() if v != 0}
    same = add(lhs, rhs, -1) == {}
    ok = ok and same
    print("  n=%d : identity holds = %s" % (n, same))
print("  ALL:", ok)

# ---------- 2. key lemma: Z^J X^{p+1-J} in I and Z^J Y^{q+1-J} in I ----------
print()
print("=== CHECK 2: Z^J X^{p+1-J} = 0 mod I and Z^J Y^{q+1-J} = 0 mod I ===")
for p in range(0, 5):
    for q in range(0, 5):
        maxdeg = 2 * (p + q) + 6
        Q = Quotient(p, q, maxdeg)
        bad = []
        for J in range(1, p + 2):
            e = mul(pw(Z, J), pw(X, p + 1 - J))
            d = 2 * J + (p + 1 - J)
            if Q.reduce(e, d):
                bad.append(("X", J))
        for J in range(1, q + 2):
            e = mul(pw(Z, J), pw(Y, q + 1 - J))
            d = 2 * J + (q + 1 - J)
            if Q.reduce(e, d):
                bad.append(("Y", J))
        if bad:
            print("  p=%d q=%d  FAILED: %s" % (p, q, bad))
print("  (no output above means: all these elements reduce to 0 in M_{p,q}, p,q<=4)")

# ---------- 3. nilpotency index of Z and of X+Y ----------
print()
print("=== CHECK 3: minimal n with Z^n = 0, and minimal n with (X+Y)^n = 0, in M_{p,q} ===")
for p in range(0, 5):
    row = []
    for q in range(0, 5):
        maxdeg = 4 * (p + q) + 10
        Q = Quotient(p, q, maxdeg)
        zmin = None
        for n in range(0, maxdeg // 2 + 1):
            e = pw(Z, n)
            d = 2 * n
            if Q.reduce(e, d) == {}:
                zmin = n
                break
        vs = T_powers(p, q, maxdeg)
        tmin = None
        for n in range(0, maxdeg + 1):
            if not vs[n]:
                tmin = n
                break
        row.append("(%d,%d) Z^%s (X+Y)^%s" % (p, q, zmin, tmin))
    print("   ".join(row))
