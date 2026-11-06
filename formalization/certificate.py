"""Generate a noncommutative identity; Lean checks the resulting proof, not Python.

Run: py -3 certificate.py. Exploratory dependency: SymPy 1.14.0.
The accepted certificate is materialized in SpecialCases.lean.
"""
import itertools
import sympy as s
from pathlib import Path


def words(n):
    return [''.join(w) for w in itertools.product('xy', repeat=n)]


def product(a, b):
    return {a + w + b: c for w, c in [('xxy', 1), ('xyx', -2), ('yxx', 1)]}


def solve(n, p, q):
    basis = words(n)
    cols, labels = [], []
    for suffix in ['x' * (p+1), 'y' * (q+1)]:
        for a in words(n-len(suffix)):
            cols.append({a+suffix: 1})
            labels.append(('ann', a, suffix))
    for rel in ['X', 'Y']:
        for i in range(n-2):
            for a in words(i):
                for b in words(n-3-i):
                    d = product(a, b)
                    if rel == 'Y':
                        # y commutator: yxy - yyx - xyy + yxy
                        d = {a+'yxy'+b: 2, a+'yyx'+b: -1, a+'xyy'+b: -1}
                    cols.append(d)
                    labels.append((rel, a, b))
    m = s.Matrix([[d.get(w,0) for d in cols] for w in basis])
    sol, params = m.gauss_jordan_solve(s.ones(len(basis),1))
    sol = sol.subs({p:0 for p in params})
    assert m*sol == s.ones(len(basis),1)
    print(f'n={n}, p={p}, q={q}')
    for c,l in zip(sol,labels):
        if c: print(c, l)
    return list(zip(sol, labels))


def word(w):
    return ' * '.join(w) if w else '1'


def term(c, expression):
    if c == 1: return f'({expression})'
    return f'({c}) * ({expression})'


def generate(n, p, q, name):
    solution = solve(n,p,q)
    assert all((2*c).q == 1 for c,l in solution)
    entries = [(int(2*c),l) for c,l in solution if c]
    polynomials=[]
    for suffix in ['x'*(p+1),'y'*(q+1)]:
        poly=' +\n        '.join(term(c,word(a)) for c,(rel,a,b) in entries
                        if rel=='ann' and b==suffix)
        power = f'{suffix[0]} ^ {len(suffix)}'
        polynomials.append(f'({poly}) * ({power})')
    rhs = ' +\n      '.join(polynomials)
    extras=[]
    for c,(rel,a,b) in entries:
        if rel=='ann': continue
        r = 'x * ad x y - ad x y * x' if rel=='X' else 'y * ad x y - ad x y * y'
        factors=([word(a)] if a else [])+[f'({r})']+([word(b)] if b else [])
        extras.append(term(c,' * '.join(f'({t})' for t in factors)))
    extra = ' +\n        '.join(extras)
    return f'''/-- Finite ring certificate; the right factors are exactly the vector annihilators. -/
lemma {name} {{R : Type*}} [Ring R] (x y : R)
    (hX : Commute x (ad x y)) (hY : Commute y (ad x y)) :
    2 * (x + y) ^ {n} =
      {rhs} := by
  have hRX : x * ad x y - ad x y * x = 0 := sub_eq_zero.mpr hX.eq
  have hRY : y * ad x y - ad x y * y = 0 := sub_eq_zero.mpr hY.eq
  have cert : 2 * (x + y) ^ {n} =
      {rhs} +
        ({extra}) := by
    unfold ad
    noncomm_ring
  rw [hRX, hRY] at cert
  simpa only [mul_zero, zero_mul, add_zero] using cert
'''


if __name__ == '__main__':
    src = 'import ConjectureA1\n\nnamespace ConjectureA1\n\n'
    src += generate(5,1,1,'two_mul_add_pow_five')
    src += '\n' + generate(3,1,0,'two_mul_add_pow_three')
    src += '\nend ConjectureA1\n'
    Path(__file__).with_name('SpecialCases.lean').write_text(src, encoding='utf-8')
