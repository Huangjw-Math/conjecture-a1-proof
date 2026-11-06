FINITE_COMPUTATIONAL_RESULT

# Exact-verifier review — 2026-11-05

**Verdict: PASS for the finite verification and runner scope.** All nine child
scripts ran with exit 0; `verification/run_all.py` returned 0 and printed
`PASS_FINITE_CHECKS`. The ten unittest regression groups passed.

## Inputs and reproduction

Inputs: `verification/*.py` and `verification/README.md`. The target was compared
with `report/src/report.tex` and
[Conjecture A.1, Appendix A, PDF page 42](https://arxiv.org/pdf/1811.10137v2#page=42):
arbitrary vector spaces over characteristic-zero fields, generator/commutator
commutation, and annihilation of the distinguished vector, rather than operator
nilpotence. The computational coefficient field is Q.

Checked runtime: **CPython 3.10.11**, standard library only. From the repository
root:

```text
python verification/run_all.py
git diff --check -- verification
```

Both commands returned 0. Python must run without `-O`. The default per-child
timeout is 180 seconds. Local transcripts and the exit summary are regenerated
under ignored `verification/results/`; no previous audit JSON or machine log is
needed to reproduce these checks.

## Model fidelity

The backend computes the left quotient
`M=A/(A X^(p+1)+A Y^(q+1))`, with `XY-YX=Z` and central Z. For weighted degree d,
it lists every PBW left multiple in
`I_d=A_(d-p-1) X^(p+1)+A_(d-q-1) Y^(q+1)` and uses exact Fraction Gaussian
elimination. The signs in right normal ordering and left multiplication agree.
There is no independent X/Y double truncation. Wrong-degree nonzero terms are
rejected instead of discarded.

The `(p,q)=(0,1)` regression gives `T^2.1=Z.1!=0`, `T^3.1=0`.
At `(1,1)`, `ZX,ZY,Z^2,X^2Y` are nonzero, whereas B4 has an explicitly checked
left-ideal membership certificate. These distinguish the left ideal from the
incorrect two-sided model and refute the unconditional reverse threshold for
individual `Z^k B_m` terms.

## Exact coverage and observed outcomes

Here `T=X+Y` and `N=2p+2q+1`; overlapping checks are not additional distinct
parameter cases.

| Input | Exact finite coverage | Outcome |
| --- | --- | --- |
| `verification/conj2.py` | 49 pairs `p,q=0..6`; 686 states `0<=n<=N`; first zero exactly N | PASS |
| `verification/conj.py` | 25 pairs `p,q=0..4`, plus `(0,1)` regression; same quotient backend | PASS |
| `verification/verify.py` | 9 PBW binomial identities `n=0..8`; 25 exact T/Z index pairs `p,q=0..4`; discarded-claim regressions | PASS |
| `verification/verify2.py` | 36 normal-ordering identities; 240 key relations; 155 nonempty line matrices (95 positive triangular, 30 negative triangular, 30 middle), `p,q=0..4`; 25 full-degree quotient checks `I_N=A_N`; 6 explicit determinants; 54 support/endpoint checks | PASS |
| `verification/sharpness.py` | `p=0,q=0..6` polynomial model, exact terminal coefficient and first zero; 108 Heisenberg identities on the stated basis samples | PASS |
| `verification/pureZ_check.py` | 8 listed pure-Z coefficient identities in A | PASS |
| `verification/structure.py` | Dimension and monomial tables at `(1,1),(1,2),(2,2)` | Completed, diagnostic only |
| `verification/probe2.py` | Dimension tables for `p,q=0..4`; 230 `Z^k B_m` entries at four listed pairs, including 144 asserted high-degree vanishings | PASS; dimensions diagnostic only |
| `verification/audit_checks.py` | 10 unittest groups; 128 direct/iterative PBW comparisons; 1,848 left-stability checks; 1,200 relation identities across 400 symmetric-tensor basis vectors (`p,q=0..3`); 49 independent tensor examples (`p,q=0..6`) checking vector annihilators and exact terminal T/Z coefficients | PASS |

All loop endpoints and the six determinant examples are specified in
`verification/README.md` and the executable sources.

## Failure paths actually exercised

The portable regressions launch real subprocesses in temporary sandboxes:

- Adding 1 to the predicted coefficient in a copied `pureZ_check.py` causes
  `AssertionError`, child exit 1, aggregate exit 1 and status `FAIL`. All eight
  control children still execute successfully.
- A sleeping child exceeds a one-second timeout, records `exit_code=null` and a
  timeout transcript, and causes aggregate exit 1 and status `FAIL`; the other
  eight controls finish.
- `python -O` is rejected with a nonzero exit before writing results.

The actual checked sources are not mutated by these tests. The runner also
checks that all other `verification/*.py` files occur in its inventory exactly
once.

## Ring boundary and limits

A separate regression verifies the counterexample
`R=Z x M_2(F_2)`, `x=(0,E12)`, `y=(0,E21)`, `z=(0,I_2)`:
`x^2=y^2=0` and z is central, but `(x+y)^5=x+y!=0`. Characteristic zero follows
from projection to Z; centrality's matrix component is checked against all 16
binary matrices. Thus a general characteristic-zero **ring** extension is false.
This does not refute the original characteristic-zero **field/vector-space**
target. The paper's scalar-cancellation argument needs invertible nonzero
integer scalars, as supplied by its field hypothesis.

These finite exact computations do not establish the universal conjecture,
arbitrary-parameter sharpness, novelty, or completeness of Lean formalization.
The independent written-proof and Lean reviews remain separate acceptance
inputs. No verification-scope failure remains open.
