# Checked partial formalization — 2026-11-05

`BoundaryCases.lean` proves Conjecture A.1 for **every natural parameter pair with
p=0 or q=0**. `VectorCases.lean` also proves p=q=1. These results hold over every
characteristic-zero field and every vector space, with only the two prescribed
commutation relations and vector-level annihilation hypotheses.

`NormalOrder.lean` now proves arbitrary-power Taylor and normal-order formulas,
and the general vector right-annihilator recurrence.

**The arbitrary positive-parameter theorem is not proved in Lean.**
`VectorConjecture` defines the full target; it does not assert it.

## Reproduce the checks

The project pins Lean **4.31.0** and Mathlib commit
`fabf563a7c95a166b8d7b6efca11c8b4dc9d911f`. `lake-manifest.json` also pins
Mathlib's eight transitive packages.

### Existing compiled dependency cache

Set `LEAN_BIN` to an existing pinned Lean/Lake bin directory and `MATHLIB_CACHE`
to a Mathlib checkout with compiled imports. Its pinned transitive checkouts may
be siblings or under its `.lake/packages` directory. From the repository root:

```powershell
python formalization/validate.py
```

Or supply both paths explicitly:

```powershell
python formalization/validate.py --lean-bin $env:LEAN_BIN --mathlib-cache $env:MATHLIB_CACHE
```

Python 3 and PowerShell 5.1+ or PowerShell 7 are required by this wrapper.
It launches `build.ps1`, verifies the actual Lean version, all nine checkout HEADs,
their tracked-clean state and the Mathlib toolchain, then runs the offline Lake
proof target. The compiler freshly checks, in order:

```text
ConjectureA1, SpecialCases, VectorCases, BoundaryCases, NormalOrder, AxiomAudit
```

The target always invokes Lean for every module, writes proof artifacts into
`.lake/build/lib/lean`, and places that fresh output first in `LEAN_PATH`.
External compiled caches are trusted, read-only inputs; they are not rebuilt.
A locked Lake-only dependency need not have a compiled library when none of these
modules imports it. Required missing artifacts fail in the compiler.

The diagnostic scanner covers every root-level `*.lean` file (the six material
modules and both Lake configurations), masking nested comments, ordinary/raw
strings and Lean quoted identifiers. Its five regression tests run with:

```text
python -m unittest discover -s formalization -p test_validate.py
```

Validation checks **this invocation's actual compiler
output** for every declaration's transitive axioms and every material module's
successful compilation. It never accepts a historical build log. Local output is
written to ignored `evidence/validation-build.log` and
`evidence/validation-report.json`; no machine logs are part of the public artifact.

For a build without the Python report, the existing entry point remains:

```powershell
.\formalization\build.ps1 -LeanBin $env:LEAN_BIN -MathlibCache $env:MATHLIB_CACHE
```

### Ordinary dependency-managed environment

With elan/Lean 4.31.0 and Git available, the standard route is:

```text
cd formalization
lake exe cache get
python validate.py
```

Unset `MATHLIB_CACHE` for this route. `validate.py` then invokes the normal Lake
build and a fresh proof/axiom pass using `lake env`. This download/dependency-managed
route was not run in the current audit; the existing-cache route above was run.

`setup.ps1` remains an optional, source-only archive downloader. It accepts an
existing Node executable through `-NodePath`; it does not install the transitive
Mathlib dependencies or compiled caches. Prefer the ordinary Lake route for a new
environment.

## Target fidelity

`ConjectureA1.VectorConjecture K V` explicitly binds `[Field K] [CharZero K]`,
`[AddCommGroup V] [Module K V]`. For `X,Y : Module.End K V`, put `Z=XY-YX`.
Its assumptions are exactly `Commute X Z` and `Commute Y Z`; for natural `p,q`
and `v : V`, its conclusion is:

```text
X^(p+1) v = 0 → Y^(q+1) v = 0 → (X+Y)^(2p+2q+1) v = 0.
```

The elaborated definition is printed by `AxiomAudit.lean`. The file also has typed
signature checks for the definition and the two new infinite boundary families.
No result assumes ambient centrality, finite dimension, a nonzero vector, or
operator annihilation `X^(p+1)=0`.

The old `ConjectureA1.ConjectureA1 R V` name and meaning are retained for legacy
callers. Its elaborated signature requires only a ring and module (the original
unused rational-algebra section instance is dropped), and assumes ambient
centrality. It is a different, unproved proposition and is not used by the new
vector theorems.

## Complete inventory: 37 proved lemmas/theorems

All names below have namespace prefix `ConjectureA1.`. Natural coefficients are
additive multiples. In ring statements let `z=xy-yx`.

### Elementary ring layer — 12 declarations

`ad_def`, `ad_add`, `ad_zero`, `ad_neg`, `ad_one`, `ad_mul`, `ad_pow_succ` and
`ad_swap` express the commutator convention, additive/Leibniz rules, and sign.
They hold in every ring.

`ad_pow_of_commute`, `ad_pow_eq`, `mul_pow_normal_order` and
`pow_mul_normal_order` prove the one-generator power rules, with only the
specified generator commuting with `z`. In particular:

```text
[x,y^n] = n • (y^(n-1) z),
x y^(n+1) = y^(n+1) x + (n+1) • (y^n z).
```

### Integral certificates and small vector cases — 8 declarations

`two_mul_add_pow_five` and `two_mul_add_pow_three` are explicit ring identities
with right factors `x²,y²` and `x²,y`, respectively. Lean checks the identities
modulo the two commutation relations with `noncomm_ring`.

`vector_two_cancel`, `vector_p_one_q_one`, `vector_p_one_q_zero`,
`vector_p_zero_q_one`, `vector_p_zero_q_zero` and `vector_parameters_le_one`
prove and assemble the p,q≤1 vector cases. The zero-zero theorem needs neither
CharZero nor commutator assumptions.

`certificate.py` can rediscover the two explicit identities using optional
SymPy 1.14.0. Python/SymPy is not a trusted proof or build dependency.

### Arbitrary boundary parameters — 8 new declarations

- `vector_nat_cancel`: a positive natural coefficient cancels in a
  characteristic-zero vector space.
- `boundary_x_action`: if `Xv=0`, then
  `X (Z^a Y^(b+1) v) = (b+1) • (Z^(a+1) Y^b v)`.
  This action rule itself does not require CharZero.
- `boundary_monomial_vanish`: if `Xv=0` and `Y^(q+1)v=0`, then
  `Z^a Y^b v=0` whenever `a+b>q`.
- `boundary_add_action`: on the same X-killed vector, left multiplication by
  `X+Y` sends `Z^aY^b v` to
  `Z^aY^(b+1)v + b • (Z^(a+1)Y^(b-1)v)`.
  This rule does not require CharZero; b=0 is included.
- `boundary_weighted_vanish`: under the two boundary vector hypotheses,
  `(X+Y)^n Z^a Y^b v=0` whenever `n+2a+b>2q`.
- `vector_p_zero`: `Xv=0`, `Y^(q+1)v=0` imply `(X+Y)^(2q+1)v=0`, all natural q.
- `vector_q_zero`: the symmetric result for all natural p, with exponent `2p+1`.
- `vector_boundary_or_le_one`: exactly the frozen exponent `2p+2q+1` when
  `p=0 ∨ q=0 ∨ (p≤1 ∧ q≤1)`.

The boundary argument first inducts on `a`: applying X to a vanished monomial
with Y-exponent b+1 yields a nonzero coefficient b+1 times the next monomial.
A second induction on n uses the action rule, which raises weight `2a+b` by one.
This proves an infinite family directly on vectors, without constructing PBW.

### Arbitrary-power normal ordering — 9 new declarations

`innerEnd_apply`, `mulLeft_pow_apply`, `mulRight_pow_apply` and
`innerEnd_commute_right` package the additive endomorphism
`innerEnd x = (left multiplication by x) - (right multiplication by x)`.

`taylor` proves, in every ring and with no commutation assumptions:

```text
x^n w = ∑ j=0..n, choose(n,j) • ((ad x)^[j](w) x^(n-j)).
```

`ad_nsmul` expresses additivity on natural multiples.
`ad_iterate_pow` proves, under just xz=zx and yz=zy:

```text
(ad x)^[j](y^b) = b.descFactorial(j) • (y^(b-j) z^j).
```

`normal_order` combines them, for all natural a,b including zero:

```text
x^a y^b = ∑ j=0..a,
  (choose(a,j) * b.descFactorial(j)) • (y^(b-j) z^j x^(a-j)).
```

`vector_right_line_relation` swaps X,Y and evaluates the normal-order identity
on a vector killed by `X^(p+1)`. For every natural p,B:

```text
(∑ j=0..B, (B.descFactorial(j) * choose(p+1,j)) •
  (X^(p+1-j) (-Z)^j Y^(B-j))) v = 0.
```

Terms past either relevant endpoint have coefficient zero; the power `(-Z)^j`
retains the sign explicitly. This is a vector right-annihilator relation, not
a two-sided-ideal assertion. It does not require CharZero.

The Taylor proof applies the ordinary binomial theorem to commuting additive
endomorphisms `innerEnd x` and right multiplication by x. No custom binomial
axiom, PBW theorem or operator nilpotence is introduced.

## Current machine evidence and trust boundary

The current existing-cache run freshly compiled all six material modules and
checked all 37 declaration axiom sets. Source diagnostics found no unfinished
proof terms, user axioms, unsafe declarations or `native_decide` calls.

Allowed transitive axioms are subsets of:

```text
propext, Classical.choice, Quot.sound
```

The two new boundary root theorems use those three standard foundations;
the normal-order/Taylor root declarations also use those three. Exact per-declaration
sets are printed by `AxiomAudit.lean` and retained in the generated validation
report. No independent alternative kernel implementation was run.

The checked compiler was Lean 4.31.0, commit
`68218e876d2a38b1985b8590fff244a83c321783`. All nine dependency checkout HEADs
matched the lockfile, all had no tracked changes, and Mathlib's `lean-toolchain`
matched. Imported `.olean` files remain trusted prebuilt inputs of those
checkouts; this is not a from-source rebuild of all Mathlib.

The preserved legacy duplicated namespace produces one linter warning.
Independent type readback and a separate contract comparison accepted this
precisely partial scope. A separately authored typed Guard also compiled. See
[the independent review](../docs/audit-2026-11-05/lean-review.md).

## Exact remaining obligations for arbitrary positive p,q

1. Instantiate the general right-annihilator identity on each finite
   weighted-degree line `u_b = X^(b+δ)Y^bZ^(m-b)v`, using valid natural index
   ranges and explicit zero endpoints. The arbitrary-power algebraic identity
   and its right-annihilator evaluation are now proved, but this indexed
   line-family packaging is not.
2. Prove the triangular elimination arguments for the outer δ ranges.
3. Prove the scalar fewnomial multiplicity bound and its vector-valued
   consequence for the interior line systems, including any required
   vector/separating-functional argument.
4. Show `(X+Y)^(2p+2q+1)v` is a linear combination of the vanished monomials
   and assemble a theorem of type `VectorConjecture K V`.

A full explicit trinomial expansion is still absent, but a direct induction on
the weighted monomial span could replace that formula for the final assembly.
No PBW linear-independence construction is required by this direct vector route.
The boundary vanishing lemma is deliberately not generalized to arbitrary p:
its proof uses `Xv=0`, and that hypothesis cannot be replaced by `X^(p+1)v=0`
in the differentiating step.

## Dated work record

2026-11-05: independently recompiled the inherited 20 declarations, verified the
pinned environment, and continued the general formalization without editing the
paper or verification scripts. Added the two arbitrary zero-parameter families,
weighted boundary vanishing, the all-power Taylor/normal-order layer and the
general right-annihilator recurrence (17 new declarations).

Removed obsolete unproved Lean-code comment blocks and machine/session-specific
material from the public progress report. The build verifies all locked source
checkouts and puts fresh local modules first. Validation now runs a fresh build
instead of consuming an earlier log. Fixed the inherited quoted-identifier
mask delimiters using ASCII Unicode escapes and added five scanner regression
tests. The optional downloader accepts a generic
Node executable path; private evidence is ignored. No old branch files were
removed, and no commit or publication was performed by this formalization owner.
