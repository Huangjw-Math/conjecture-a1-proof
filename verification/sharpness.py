# -*- coding: utf-8 -*-
"""
Verify the p=0 polynomial sharpness model (exact rationals).

Model:  V = Q[x,eps]/(eps^{q+1}),  X = d/dx,  Y = eps*x,  Z = eps,  v = 1.
States: dict (i,j) -> coeff  meaning  coeff * x^i eps^j ,  0 <= j <= q.
"""
from fractions import Fraction as F
from math import factorial

def clean(d):
    return {k: v for k, v in d.items() if v != 0}

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
for q in range(0, 7):
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
    first_zero = next((n for n, value in enumerate(hist) if not value), None)
    # predicted zero: 2q+1 ; predicted nonzero: 2q
    ok = (hist[2 * q] != {}) and all(not hist[n] for n in range(2 * q + 1, len(hist)))
    # check the eps^q coefficient of T^{2q}(1)
    coef = hist[2 * q].get((0, q), F(0)) if hist[2 * q] else F(0)
    pred = F(factorial(2*q), 2**q * factorial(q))
    assert Xv == {} and Ypow == {}, q
    assert first_zero == 2 * q + 1 and ok and coef == pred, q
    print("  q=%d: Xv=0:%s  Y^(q+1)v=0:%s | T^(2q)v != 0:%s  T^(2q+1..)=0:%s  eps^q coeff=%s (pred %s) match=%s"
          % (q, Xv == {}, Ypow == {}, hist[2*q] != {}, all(not hist[n] for n in range(2*q+1, len(hist))),
             coef, pred, coef == pred))

print()
print("=== check [X,Y] = Z, [X,Z] = [Y,Z] = 0 on sampled basis monomials ===")
relation_count = 0
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
            relation_count += 1
            for op in [dX, Ymult]:
                OZ = op_apply(op, op_apply(Zmult, {m: F(1)}, q), q)
                ZO = op_apply(Zmult, op_apply(op, {m: F(1)}, q), q)
                if OZ != ZO:
                    ok = False
                relation_count += 1
    assert ok, q
    print("  q=%d : all three Heisenberg relations ? %s" % (q, ok))

print("PASS: p=0, q=0..6 sharpness model; %d relations on i=0..3, j=0..q, q=1..3"
      % relation_count)
