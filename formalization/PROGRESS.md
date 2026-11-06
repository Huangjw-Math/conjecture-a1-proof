# Complete proof of Conjecture A.1 — 2026-11-06

Import `General` and use the actual root proof:

```lean
import General

example (K V : Type*) [Field K] [CharZero K]
    [AddCommGroup V] [Module K V] : ConjectureA1.VectorConjecture K V :=
  ConjectureA1.vector_conjecture K V
```

`ConjectureA1.vector_general` is the expanded interface. For every characteristic-zero
field K, every K-vector space V, X,Y in End_K(V), and Z=XY−YX, it proves

```text
XZ=ZX → YZ=ZY → ∀ p q v,
  X^(p+1)v=0 → Y^(q+1)v=0 → (X+Y)^(2p+2q+1)v=0.
```

Both carrier universes are arbitrary and independent. Parameters p,q are all natural
numbers, including zero. No finite-dimensionality, nonzero-vector, ambient-centrality
or operator-nilpotence hypothesis is present. The former `VectorConjecture` definition
is retained unchanged and now has an actual theorem proving it.

## Reproduce the complete check

Pins: Lean **4.31.0**, compiler commit `68218e876d2a38b1985b8590fff244a83c321783`;
Mathlib **fabf563a7c95a166b8d7b6efca11c8b4dc9d911f**; all eight transitive packages
are pinned in `lake-manifest.json`.

### Existing compiled cache

Set `LEAN_BIN` to the pinned Lean/Lake bin directory and `MATHLIB_CACHE` to the
matching Mathlib checkout, whose dependencies are siblings or in `.lake/packages`.
From the repository root:

```powershell
python formalization/validate.py --lean-bin $env:LEAN_BIN --mathlib-cache $env:MATHLIB_CACHE
```

The wrapper requires Python 3 and native PowerShell. It verifies the compiler,
all nine checkout HEADs and tracked-clean states, and Mathlib's toolchain.
It then runs `lake -f lakefile.offline.lean build`, freshly compiling all twelve
material modules in dependency order. The fresh project output comes first in
`LEAN_PATH`; imported dependency artifacts are trusted read-only cache inputs.

Validation reads this invocation's compiler output, not an old log. Every proved
declaration has an actual `#print axioms` probe. All root-level Lean files are
scanned after masking nested comments, strings, raw strings and quoted identifiers.
Local transcripts and the JSON report stay in ignored `evidence/`.

### Dependency-managed environment

With elan and the pinned Lean version available:

```text
cd formalization
lake exe cache get
python validate.py
```

Unset `MATHLIB_CACHE` for this route. The wrapper runs the ordinary Lake build and
a fresh proof/axiom pass through `lake env`. This online acquisition route and a
from-source Mathlib rebuild were not run in the current check.

The optional `setup.ps1` is a source/archive downloader, not a substitute for all
transitive dependencies and compiled caches.

## Proof chain

1. **Normal ordering:** `NormalOrder.lean` proves Taylor and arbitrary commutator
   powers using only the two local commuting relations.
2. **Sparse uniqueness:** `Fewnomial.lean` proves `SparseRootProperty K`. The Euler
   operator `X*f' - e*f` removes a support index, while `(X-1)^m` divisibility drops
   by at most one order. Induction gives sparse-root uniqueness at 1, including m=0.
3. **Finite line kernel:** `LineSystem.lean` forms the exponential generating
   polynomial U and H=(1-X)^(p+1)U. The actual recurrence kills its middle
   coefficients. Its support lies in `[lo,b0)` and `(M,D+p+1]`; the bound
   `(b0-lo)+(D+p+1-M)≤p+1` gives H=0. Full dual separation lifts the result to any
   vector space without assuming finite dimension.
4. **Operator bridge:** `MonomialActions.lean` obtains the recurrence by a genuine
   left multiple of the right-annihilator identity. Range changes use zero
   coefficients, not false individual-monomial vanishing assertions.
5. **Indices:** `WeightedLines.lean` encodes positive and negative line differences
   with natural lower endpoints and proves every cutoff monomial vanishes.
   Odd cutoff weight excludes zero line difference.
6. **Assembly:** `General.lean` supplies the proved sparse property and line kernel,
   discharging the auxiliary interfaces. A three-term left-action rule gives
   weighted induction and the full original conclusion.

The formal route uses one sparse-support kernel for all line regions. It does
not need a PBW algebra, matrix determinant construction or explicit trinomial sum.
`SparseRootProperty` and `LineVanishing` are definitions used for modular interfaces;
neither remains an assumption of `vector_general` or `vector_conjecture`.

## Complete inventory: 62 proved declarations

All mathematical names have prefix `ConjectureA1.`; definitions are not counted.
`AxiomAudit.lean` contains probes and signature checks, not new mathematical theorems.

| Module | Proved declarations | Main contents |
|---|---:|---|
| `ConjectureA1` | 12 | Elementary commutators and one-generator power identities |
| `SpecialCases` | 2 | Integral degree-three and degree-five certificates |
| `VectorCases` | 6 | Original p,q≤1 interfaces, retained for existing callers |
| `BoundaryCases` | 8 | Arbitrary p=0/q=0 families and weighted boundary vanishing |
| `NormalOrder` | 9 | Taylor, iterated commutators, normal ordering, right line relation |
| `LineRecurrence` | 0 | Shared scalar coefficient and proposition definitions |
| `Fewnomial` | 4 | Euler coefficients/support and sparse-root uniqueness |
| `LineSystem` | 7 | Generating coefficients, support bounds, scalar/vector uniqueness |
| `MonomialActions` | 8 | Ordered-monomial actions and legal left-anchor relation |
| `WeightedLines` | 3 | Power-zero propagation, weighted iteration and line-index assembly |
| `General` | 3 | Cutoff monomials, expanded general theorem and faithful root proof |

`vector_monomial_cutoff` proves vanishing at weight `2p+2q+1`; `vector_general`
then proves the original sum-power statement. Earlier specialized interfaces are
unchanged. Optional SymPy certificate discovery is not a trusted proof dependency
and was not rerun for this continuation.

## Actual machine evidence and semantic review

The current complete build checked all twelve material modules and all **62/62**
transitive axiom sets, with compiler/build exit 0 and `passed=true`.
No unfinished terms, user axioms, `unsafe` or `native_decide` occur in material code.
The complete root has exactly the standard foundations:

```text
propext, Classical.choice, Quot.sound
```

The full source/type readback and separate contract comparison are recorded under
`docs/full-formalization-2026-11-06/`; they are independent of the authors' checks.
The original duplicated namespace produces one preserved compatibility linter warning.
No alternative kernel implementation or full dependency source rebuild was run.

## Scope beyond the root

The all-parameter tensor sharpness construction is a separately audited written
result, not a Lean theorem in this project. The explicit trinomial formula and
all higher-weight universal-algebra statements are not separately formalized;
they are not missing dependencies of the complete original root proof.

The legacy `ConjectureA1.ConjectureA1 R V` remains a different, unproved proposition:
its unused rational-algebra binder is absent from its actual type, and it requires
ambient centrality. The new full root does not use that proposition.

## Dated continuation record

2026-11-05: snapshot edd9dd0 contained 37 checked declarations, including boundary
families and arbitrary-power identities; the general theorem was not yet proved.
The attempted draft PR was denied by the GitHub integration with HTTP 403.

2026-11-06: the user made complete original formalization a gate before PR creation.
Added the six modules from `LineRecurrence` through `General`, 25 new proved
declarations. Independent leaf authors supplied sparse uniqueness, the line kernel
and the operator bridge; the coordinator proved the natural index/weighted assembly.
The first full audit failed on an extra nonexistent probe extracted from a comment;
removing that probe, without removing any declaration check, gave the successful
12-module/62-probe run. Original proof hypotheses and the frozen target are unchanged.
