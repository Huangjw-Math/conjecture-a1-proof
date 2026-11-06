# -*- coding: utf-8 -*-
"""
Exact rational consistency checks and regressions for refuted intermediate
claims. These are finite computations, NOT a proof of the conjecture.

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

def main():
    print("=== exact normal-ordering identity, 0 <= n <= 8 ===")
    for n in range(9):
        lhs = pw(add(X, Y), n)
        rhs = {}
        for k in range(n // 2 + 1):
            for a in range(n - 2 * k + 1):
                b = n - 2 * k - a
                rhs[(a, b, k)] = (F(factorial(n), factorial(a) * factorial(b) * factorial(k))
                                     * F((-1) ** k, 2 ** k))
        assert add(lhs, rhs, -1) == {}, n
    print("PASS: 9 PBW identities")

    # The historical one-sided lemma is FALSE for a left ideal. These
    # nonmembership checks prevent its accidental restoration as a premise.
    Q = Quotient(0, 1, 3)
    assert Q.reduce(Z, 2), "Z is nonzero in M_(0,1)"
    Q11 = Quotient(1, 1, 5)
    assert Q11.reduce(mul(Z, X), 3), "ZX is nonzero in M_(1,1)"
    assert Q11.reduce(mul(Z, Y), 3), "ZY is nonzero in M_(1,1)"
    assert Q11.reduce(pw(Z, 2), 4), "Z^2 is nonzero in M_(1,1)"
    B4 = {(a, 4-a, 0): F(1, factorial(a) * factorial(4-a)) for a in range(5)}
    assert Q11.reduce(B4, 4) == {}, "B4 lies in I although degree 4 < N=5"
    assert Q11.reduce(pw(add(X, Y), 4), 4), "T^4 remains nonzero"
    print("PASS: false one-sided lemma and false B_m iff threshold regressions")
    print("  p=q=1: B4=0, Z^2!=0, T^4!=0 modulo I; N=5")

    print("=== exact nilpotence indices, 0 <= p,q <= 4 ===")
    for p in range(5):
        row = []
        for q in range(5):
            N = 2 * (p + q) + 1
            Q = Quotient(p, q, N + 1)
            zmin = next((n for n in range(p + q + 2)
                         if Q.reduce(pw(Z, n), 2*n) == {}), None)
            vs = T_powers(p, q, N)
            tmin = next((n for n, value in enumerate(vs) if not value), None)
            assert zmin == p + q + 1, (p, q, zmin)
            assert tmin == N, (p, q, tmin)
            row.append("(%d,%d) Z^%s T^%s" % (p, q, zmin, tmin))
        print("   ".join(row))
    print("PASS: 25 exact index pairs; finite evidence only")


if __name__ == "__main__":
    main()
