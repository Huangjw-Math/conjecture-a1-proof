# Exact finite verification

These scripts use Python 3.9+ standard-library integer/rational arithmetic. They
check explicitly bounded cases and algebraic identities; they do not prove
Conjecture A.1 or sharpness for arbitrary parameters.

From the repository root, with Python available as `python`:

```powershell
python verification/run_all.py
```

The expected final line is `PASS_FINITE_CHECKS`, with exit code 0. The runner
executes all nine scripts below and checks that its inventory covers every other
`verification/*.py` exactly once. It exits 1 if any child fails or exceeds the
default 180-second per-script timeout. Run without `-O`: assertions are part of
the checks, and the runner rejects optimized Python execution. The checked
runtime for this audit is CPython 3.10.11. No third-party dependencies are needed.

Local transcripts and the per-script exit summary are written to
`verification/results/`, which is ignored by Git. An optional `--output-dir`
selects a different local destination; `--timeout` changes the per-script limit.
No previous audit files are required. Keep raw logs local: failure tracebacks can
contain machine-specific paths.

## Mathematical setup

The convention is `XY-YX=Z`, with Z commuting with X and Y. In the PBW basis
`X^a Y^b Z^k`, degrees are `a+b+2k`. The left ideal is
`I=A X^(p+1)+A Y^(q+1)` and `M=A/I`. In each homogeneous degree d, `conj2.py`
constructs the complete spanning set of `I_d` and tests membership by exact
fraction Gaussian elimination. It never truncates X powers as if I were
two-sided. Homogeneous input with a nonzero term in the wrong degree is rejected.
Specifically,

```
I_d = A_(d-p-1) X^(p+1) + A_(d-q-1) Y^(q+1),
Y^b X^n = sum_j (-1)^j choose(b,j) choose(n,j) j! X^(n-j) Y^(b-j) Z^j.
```

The left actions are `X.(a,b,k)=(a+1,b,k)` and
`Y.(a,b,k)=(a,b+1,k) - a * (a-1,b,k+1)`, followed by homogeneous reduction.
`Quotient.reduce` returns sparse coordinates indexed by `basis_degree(d)`;
`Quotient.to_elem` converts them back to PBW monomial keys.

## Scripts and tested domains

| Script | Exact finite scope |
| --- | --- |
| `conj2.py` | All 49 pairs `0<=p,q<=6`: the first zero of `T^n.1` is `N=2p+2q+1`, where `T=X+Y`; 686 states over all `0<=n<=N`. |
| `conj.py` | Compatibility entry point using the same valid quotient backend, `0<=p,q<=4`; regression at `(0,1)`. The old independent truncation was invalid. |
| `verify.py` | PBW binomial identity `0<=n<=8`; Z index `p+q+1` and T index N for `0<=p,q<=4`; explicit counterexamples to discarded intermediate claims. |
| `verify2.py` | 36 normal-ordering identities `p,B=0..5`; 240 key relations `p=0..3`, `A=p+1..p+4`, `B=0..4`, `K=0..2`; 155 nonempty line matrices for `p,q=0..4`, all parity-compatible `delta=-N..N` (95 positive triangular, 30 negative triangular, 30 middle); 25 full-degree checks `I_N=A_N`; six explicit determinants; 54 support bounds and endpoint checks for `p=1..5,q=0..5,1<=delta<=p` of correct parity. |
| `sharpness.py` | Model `Q[x,eps]/(eps^(q+1))`, `X=d/dx,Y=eps*x,v=1`, `p=0,q=0..6`; coefficient `(2q)!/(2^q q!)`, first zero `2q+1`; all three Heisenberg relations on basis monomials `i=0..3,j=0..q,q=1..3` (108 identities). |
| `pureZ_check.py` | Eight listed `(p,q)` pairs: pure-Z coefficient of `Y^(p+1) Z^(q-1) X^(p+1)` in A equals `(-1)^(p+1)(p+1)!`. This says nothing by itself about nonmembership in I. |
| `structure.py` | Diagnostic quotient-dimension/monomial tables at `(1,1),(1,2),(2,2)`; no asserted general formula. |
| `probe2.py` | Diagnostic dimension tables for `p,q=0..4`, through degree `2(p+q)+3`; 230 `Z^k B_m` entries at `(1,1),(1,2),(2,2),(2,3)`, with `k=0..p+q+1,m=0..2(p+q)+2`; 144 entries with `2k+m>=N` assert vanishing. No reverse threshold is asserted. |
| `audit_checks.py` | Ten regression groups, detailed below; includes actual sandbox failure/timeout subprocesses and an independent symmetric-tensor model. |

The ten unittest groups cover:

- A corrupted coefficient prediction in a temporary copy of `pureZ_check.py`
  produces `AssertionError`, child exit 1 and aggregate exit 1; the other eight
  control scripts still run. A separate sleeping child times out and also
  produces aggregate exit 1. The checked sources are never modified in place.
- The runner inventory covers all nine child scripts, and `python -O` is rejected
  with a nonzero exit before any result directory is created.
- The `(p,q)=(0,1)` left-ideal regression; the B4 certificate and nonmembership
  examples below; rejection of a wrong homogeneous degree and a negative parameter.
- 128 iterative-versus-direct PBW power comparisons for `p,q=0..3,0<=n<=N`.
- 1,848 left-stability checks: multiply every listed generator of `I_d` by X
  and by Y, for `p,q=0..2,d=0..8`, then reduce in degree `d+1`.
- The independent representation below and the characteristic-zero ring example.

The independent representation is `Sym^p(W*) tensor Sym^q(W)` over Q, with
`W=Q^3`, `X=E12`, `Y=E23` and the induced dual action. The vector is
`epsilon1^p tensor e3^q`. The implementation uses six-variable homogeneous
polynomials, independently of PBW elimination. It checks `[X,Y]=Z`, `[X,Z]=0`
and `[Y,Z]=0` on all 400 basis vectors across `p,q=0..3` (1,200 identities).
For `p,q=0..6`, it checks the two
annihilation hypotheses, nonzero `T^(N-1)v` with exact coefficient
`(N-1)!/2^(p+q)`, and `T^N v=0`. It also checks
`Z^(p+q)v=(-1)^p (p+q)! epsilon3^p tensor e1^q` and `Z^(p+q+1)v=0`.
These are 49 finite examples, not a general proof.

## Refuted historical claims

Independent truncation of both X and Y powers is invalid for this left ideal:
at `(p,q)=(0,1)`, `T^2.1=Z.1!=0`, while `T^3.1=0`. The compatibility entry
point `conj.T_power_on_v` delegates to the homogeneous quotient backend.

The one-sided assertion `Z^J X^(p+1-J), Z^J Y^(q+1-J) in I` is false.
At `p=q=1`, the exact nonmembership regressions include `ZX`, `ZY` and `Z^2`.
They also check `X^2Y notin I`, despite `X^2 in I`.

At `p=q=1`, `ZX,ZY,Z^2` are nonzero in M, while

```
B4 = sum_(a+b=4) X^a Y^b/(a! b!)
   = (X^2/24+XY/6+Z/3) X^2 + (X^2/4+XY/6+Y^2/24) Y^2.
```

Thus `B4 in I` even though `4<N=5`; an unconditional iff threshold for individual
`Z^k B_m` is false. The exact certificate is checked in A independently of the
quotient reduction. `T^4.1` remains nonzero, so this does not refute Conjecture A.1.

## Field hypotheses matter

The original [Conjecture A.1](https://arxiv.org/pdf/1811.10137v2#page=42)
concerns vector spaces over characteristic-zero fields.
Characteristic zero alone does not suffice for the separate ring-level claim
that nilpotent elements satisfy the same bound. The regression constructs
`R=Z x M_2(F_2)`, `x=(0,E12)`, `y=(0,E21)`. This ring has characteristic zero,
`x^2=y^2=0`, and `z=xy-yx=(0,I_2)` is central, but
`(x+y)^5=x+y!=0`. The test checks the matrix products and centrality against all
16 matrices over F2. This refutes the unrestricted ring extension, not the
field/vector-space conjecture. In a characteristic-zero field, the nonzero
integer coefficients used in the written proof are invertible scalars.
