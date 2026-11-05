# -*- coding: utf-8 -*-
"""
Verification of the three ingredients of the proof of Conjecture A.1.

Setup.  A = U(h_1) = K<X,Y,Z>/([X,Y]=Z, Z central), I = A X^{p+1} + A Y^{q+1}.
Fix N and delta = a-b (a = X-power, b = Y-power).  The monomials
      P_b = X^{b+delta} Y^b Z^{M-b},     M = (N-delta)/2,
form the "line" delta of degree N.  We write u_b for the class of P_b in M=A/I.

(KEY RELATION)  For every A >= p+1, B, K >= 0
   (X^{A-p-1} Y^B Z^K) X^{p+1}  =  sum_{j=0}^{min(B,p+1)} (-1)^j c_{B,j} X^{A-j} Y^{B-j} Z^{K+j}
   with c_{B,j} = B!/(B-j)! * C(p+1,j),
so on the line delta, with A = b+delta, B = b, K = M-b:
   sum_j (-1)^j c_{b,j} u_{b-j} = 0            (b = "anchor", b >= p+1-delta).
(TRIVIAL VANISHING)  u_b = 0 whenever b >= q+1.

Claims to check:
 1. the relation coefficients c_{B,j} : Y^B X^{p+1} = sum_j (-1)^j c_{B,j} X^{p+1-j} Y^{B-j} Z^j  (and the key relation itself);
 2. the equation matrix  W_{b,c} = (-1)^{b-c} c_{b, b-c}  has, after restricting to the
    unknown columns, a nonsingular triangular submatrix in the cases  delta >= p+1  and  delta <= -1;
 3. in the case 1 <= delta <= p, the "support" count  k = (# free coefficients of h)
    satisfies  k <= p+1  (this is the hypothesis of the fewnomial lemma).
"""
from fractions import Fraction as F
from math import comb, factorial
from conj2 import Quotient
from verify import mul, mul_mono, pw, X, Y, Z, one, add, shows

def c(B, j, p):
    return F(factorial(B), factorial(B - j)) * comb(p + 1, j)

# ---------- 1. the normal-ordering relation Y^B X^{p+1} ----------
print("=== 1. Y^B X^{p+1} = sum_j (-1)^j c_{B,j} X^{p+1-j} Y^{B-j} Z^j ? ===")
ok = True
for p in range(0, 6):
    for B in range(0, 6):
        lhs = mul(pw(Y, B), pw(X, p + 1))
        rhs = {}
        for j in range(0, min(B, p + 1) + 1):
            term = {(p + 1 - j, B - j, j): (-1) ** j * c(B, j, p)}
            rhs = add(rhs, term)
        if add(lhs, rhs, -1) != {}:
            ok = False
            print("   FAIL p=%d B=%d" % (p, B))
print("   all (p,B) with p,B<=5 :", ok)

# the full "key relation" inside A, including the left factor X^{A-p-1} Z^K
print("   checking the key relation (X^{A-p-1}Y^B Z^K)X^{p+1} in A ...")
ok = True
for p in range(0, 4):
    for A in range(p + 1, p + 5):
        for B in range(0, 5):
            for K in range(0, 3):
                f = mul(mul(pw(X, A - p - 1), pw(Y, B)), pw(Z, K))
                lhs = mul(f, pw(X, p + 1))
                rhs = {}
                for j in range(0, min(B, p + 1) + 1):
                    rhs = add(rhs, {(A - j, B - j, K + j): (-1) ** j * c(B, j, p)})
                if add(lhs, rhs, -1) != {}:
                    ok = False
                    print("   FAIL", p, A, B, K)
print("   key relation holds :", ok)

# ---------- 2. triangular / rank checks ----------
def det(mat):
    """exact determinant by fraction Gaussian elimination"""
    n = len(mat)
    m = [row[:] for row in mat]
    d = F(1)
    for i in range(n):
        piv = None
        for r in range(i, n):
            if m[r][i] != 0:
                piv = r
                break
        if piv is None:
            return F(0)
        if piv != i:
            m[i], m[piv] = m[piv], m[i]
            d = -d
        d *= m[i][i]
        inv = F(1) / m[i][i]
        for r in range(i + 1, n):
            if m[r][i] != 0:
                f = m[r][i] * inv
                for cc in range(i, n):
                    m[r][cc] -= f * m[i][cc]
    return d

print()
print("=== 2. the triangular submatrices  (N = 2p+2q+1) ===")
allok = True
for p in range(0, 5):
    for q in range(0, 5):
        N = 2 * p + 2 * q + 1
        for delta in range(-N, N + 1):
            if (N - delta) % 2 != 0:
                continue
            M = (N - delta) // 2
            bmin = max(0, -delta)
            b0 = max(p + 1 - delta, 0)
            if M < bmin:
                continue
            cols = list(range(bmin, min(M, q) + 1))     # unknowns
            rows = list(range(b0, M + 1))               # equations
            if not cols:
                continue
            # full column rank ?  build the matrix and compute rank
            A_ = [[(-1) ** (b - cc) * c(b, b - cc, p) if 0 <= b - cc <= p + 1 else F(0)
                   for cc in cols] for b in rows]
            # rank by row reduction
            mat = [row[:] for row in A_]
            nrow, ncol = len(mat), len(cols)
            rank = 0
            for col in range(ncol):
                piv = None
                for r in range(rank, nrow):
                    if mat[r][col] != 0:
                        piv = r
                        break
                if piv is None:
                    continue
                mat[rank], mat[piv] = mat[piv], mat[rank]
                inv = F(1) / mat[rank][col]
                mat[rank] = [v * inv for v in mat[rank]]
                for r in range(nrow):
                    if r != rank and mat[r][col] != 0:
                        f = mat[r][col]
                        mat[r] = [a - f * b for a, b in zip(mat[r], mat[rank])]
                rank += 1
            if rank != ncol:
                allok = False
                print("   RANK DEFICIENT: p=%d q=%d delta=%d  rank=%d < %d" % (p, q, delta, rank, ncol))
print("   full column rank for all p,q<=4 and all delta :", allok)

# explicit triangular determinants in the two triangular cases
print()
print("   explicit triangular submatrices:")
for (p, q, delta) in [(1, 1, 3), (2, 2, 3), (2, 3, 4), (3, 3, 4), (2, 2, -1), (2, 3, -1), (3, 3, -3), (2, 3, -3)]:
    N = 2 * p + 2 * q + 1
    if (N - delta) % 2 != 0:
        print("   (skip parity) p=%d q=%d delta=%d" % (p, q, delta)); continue
    M = (N - delta) // 2
    bmin = max(0, -delta); b0 = max(p + 1 - delta, 0)
    cols = list(range(bmin, min(M, q) + 1))
    if not cols:
        continue
    if delta >= p + 1:
        # rows = columns (both indexed 0..K)
        K = min(M, q)
        sub = [[(-1) ** (b - cc) * c(b, b - cc, p) if 0 <= b - cc <= p + 1 else F(0)
                for cc in range(0, K + 1)] for b in range(0, K + 1)]
        print("   delta=%d>=p+1 : lower-triangular K=%d, det=%s, diag=1" % (delta, K, det(sub)))
    elif delta <= -1:
        K = q - bmin
        sub = [[(-1) ** (b - cc) * c(b, b - cc, p) if 0 <= b - cc <= p + 1 else F(0)
                for cc in range(bmin, bmin + K + 1)] for b in range(b0, b0 + K + 1)]
        print("   delta=%d<=-1 : upper-triangular size %d, det=%s" % (delta, K + 1, det(sub)))

# ---------- 3. the support count in the case 1 <= delta <= p ----------
print()
print("=== 3. support count  k <= p+1  for  1 <= delta <= p  (N = 2p+2q+1) ===")
for p in range(1, 6):
    for q in range(0, 6):
        N = 2 * p + 2 * q + 1
        for delta in range(1, p + 1):
            if (N - delta) % 2 != 0:
                continue
            M = (N - delta) // 2
            b0 = max(p + 1 - delta, 0)
            degU = min(q, M)
            k = b0 + max(0, degU + p + 1 - M)
            if k > p + 1:
                print("   BOUND TOO WEAK p=%d q=%d delta=%d : k=%d > p+1=%d" % (p, q, delta, k, p + 1))
print("   (no output = the count k <= p+1 always holds)")
