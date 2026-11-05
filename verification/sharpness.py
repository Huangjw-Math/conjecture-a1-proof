# -*- coding: utf-8 -*-
"""
Verify the sharpness counterexample of 指数sharp性分析.md §2 (exact rationals).

Model:  V = Q[x,eps]/(eps^{q+1}),  X = d/dx,  Y = eps*x,  Z = eps,  v = 1.
States: dict (i,j) -> coeff  meaning  coeff * x^i eps^j ,  0 <= j <= q.
"""
from fractions import Fraction as F
from math import factorial

def clean(d):
    return {k: v for k, v in d.items() if v != 0}

def _unused_mul_op(A, B, q):
    """composition A∘B  (A applied after B)"""
    out = {}
    for m, c in B.items():
        for m2, c2 in A.items():
            i, j = m
            i2, j2 = m2
            i3, j3 = i + i2, j + j2
            if j3 <= q:
                out[(i3, j3)] = out.get((i3, j3), F(0)) + c * c2
    return clean(out)

def apply(A, v):
    out = {}
    for m, c in v.items():
        if m in A:
            out[m] = out.get(m, F(0)) + c * A[m]
        elif (m[0], m[1]) in A:
            pass
    # general matrix-vector: A is a sparse operator on basis elements
    return clean(out)

# represent operators as functions on sparse vectors instead
def op_apply(op, vec, q):
    out = {}
    for m, c in vec.items():
        for m2, c2 in op(m, q).items():
            out[m2] = out.get(m2, F(0)) + c * c2
    return clean(out)

def dX(m, q):            # d/dx
    i, j = m
    return {(i - 1, j): F(i)} if i >= 1 else {}

def Ymult(m, q):         # eps * x
    i, j = m
    return {(i + 1, j + 1): F(1)} if j + 1 <= q else {}

def Zmult(m, q):         # eps
    i, j = m
    return {(i, j + 1): F(1)} if j + 1 <= q else {}

def addv(u, v):
    out = dict(u)
    for k, c in v.items():
        out[k] = out.get(k, F(0)) + c
    return clean(out)

print("=== sharpness model: V=Q[x,eps]/(eps^{q+1}), X=d/dx, Y=eps*x, Z=eps, v=1 ===")
for q in range(1, 7):
    v = {(0, 0): F(1)}
    # X v = 0 ?
    Xv = op_apply(dX, v, q)
    # Y^{q+1} v ?
    w = v
    for _ in range(q + 1):
        w = op_apply(Ymult, w, q)
    Ypow = w
    # T = X + Y ; compute T^n v
    def T(vec):
        return addv(op_apply(dX, vec, q), op_apply(Ymult, vec, q))
    cur = v
    hist = [cur]
    for n in range(1, 2 * q + 4):
        cur = T(cur)
        hist.append(cur)
    nz = [n for n in range(len(hist)) if hist[n]]
    first_zero = next((n for n in nz if all(not hist[m] for m in range(n, len(hist)))), None)
    # predicted zero: 2q+1 ; predicted nonzero: 2q
    ok = (hist[2 * q] != {}) and all(not hist[n] for n in range(2 * q + 1, len(hist)))
    # check the eps^q coefficient of T^{2q}(1)
    coef = hist[2 * q].get((0, q), F(0)) if hist[2 * q] else F(0)
    pred = F(factorial(2*q), 2**q * factorial(q))
    print("  q=%d: Xv=0:%s  Y^(q+1)v=0:%s | T^(2q)v != 0:%s  T^(2q+1..)=0:%s  eps^q coeff=%s (pred %s) match=%s"
          % (q, Xv == {}, Ypow == {}, hist[2*q] != {}, all(not hist[n] for n in range(2*q+1, len(hist))),
             coef, pred, coef == pred))

print()
print("=== check [X,Y] = Z as operators (on basis monomials) ===")
for q in range(1, 4):
    ok = True
    for i in range(0, 4):
        for j in range(0, q + 1):
            m = (i, j)
            XY = op_apply(dX, op_apply(Ymult, {m: F(1)}, q), q)  # X∘Y
            YX = op_apply(Ymult, op_apply(dX, {m: F(1)}, q), q)  # Y∘X
            comm = addv(XY, {k: -c for k, c in YX.items()})
            if comm != op_apply(Zmult, {m: F(1)}, q):
                ok = False
    print("  q=%d : [X,Y]==Z ? %s" % (q, ok))

print()
print()
print('（注：本文件只核验 sharpness 反例模型；关于纯 Z 项的产生，见 pureZ_check.py，那里在 Heisenberg 代数 A 的 PBW 基上做精确核验。）')
