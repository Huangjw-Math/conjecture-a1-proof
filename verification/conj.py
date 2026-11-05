# -*- coding: utf-8 -*-
"""
Conjecture A.1 (Liu-Wu-Zhang-Zhou, CMP 375 (2020) 785-832):

  X,Y,Z in End(V), Z=[X,Y], [X,Z]=[Y,Z]=0,  X^{p+1}v = Y^{q+1}v = 0
  ==> (X+Y)^{2p+2q+1} v = 0

Universal reformulation: let A = U(h) = K<X,Y,Z> / ([X,Y]=Z, Z central)
(rank one Heisenberg algebra).  Let I = A X^{p+1} + A Y^{q+1}  (left ideal),
M_{p,q} = A / I, v = 1.  Then for every (V,v) as above there is a surjection
M_{p,q} -> A v sending 1 to v, hence

   Conjecture A.1  <=>  (X+Y)^{2p+2q+1} = 0  in  M_{p,q} .

M_{p,q} has basis { X^a Y^b Z^k : 0<=a<=p, 0<=b<=q, k>=0 } (normal ordering).
Left action on that basis:
   X . (a,b,k) = (a+1,b,k)                     if a<p, else 0
   Y . (a,b,k) = (a,b+1,k)   if b<q   [ i.e. Y^{q+1}=0 kills the term ]
               - a * (a-1,b,k+1)           if a>=1
(the second line is YX^a = X^a Y - a X^{a-1} Z)
"""
from fractions import Fraction as F
from collections import defaultdict

def mul_X(state, p):
    out = defaultdict(F)
    for (a,b,k), c in state.items():
        if a < p:
            out[(a+1,b,k)] += c
    return out

def mul_Y(state, p, q):
    out = defaultdict(F)
    for (a,b,k), c in state.items():
        if b < q:
            out[(a,b+1,k)] += c
        if a >= 1:
            out[(a-1,b,k+1)] += -a*c
    return out

def add(s1, s2):
    out = defaultdict(F, s1)
    for kk, v in s2.items():
        out[kk] += v
    return out

def apply_T(state, p, q):
    return add(mul_X(state, p), mul_Y(state, p, q))

def clean(state):
    return {k: v for k, v in state.items() if v != 0}

def T_power_on_v(p, q, n):
    """(X+Y)^n . 1  in M_{p,q}"""
    st = {(0,0,0): F(1)}
    for _ in range(n):
        st = clean(apply_T(st, p, q))
        if not st:
            return {}
    return clean(st)

def show(state):
    if not state:
        return "0"
    terms = []
    for (a,b,k) in sorted(state):
        c = state[(a,b,k)]
        terms.append("%s*X^%d Y^%d Z^%d" % (c, a, b, k))
    return " + ".join(terms)

if __name__ == "__main__":
    print("=== minimal N with (X+Y)^N = 0 in M_{p,q} (scan N=0..4p+4q+6) ===")
    for p in range(0,5):
        row = []
        for q in range(0,5):
            N = None
            for n in range(0, 4*p+4*q+7):
                if not T_power_on_v(p,q,n):
                    N = n
                    break
            row.append("p=%d,q=%d -> N=%s (pred %d)" % (p,q,N,2*p+2*q+1))
        print(" | ".join(row))

    print()
    print("=== the element (X+Y)^{2p+2q+1} for a few (p,q) ===")
    for (p,q) in [(1,1),(1,2),(2,2),(2,3)]:
        print("p,q =", p, q, ":", show(T_power_on_v(p,q,2*p+2*q+1)))
