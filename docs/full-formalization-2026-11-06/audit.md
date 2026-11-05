# Full original-root contract audit

**Verdict: PASS — the Lean root proves the complete original Conjecture A.1.**

Date: 2026-11-06. This reviewer did not author the candidate proof or the separate
blind readback. The verdict combines direct source comparison, the retained fresh
build evidence, and a newly authored and compiled exact-type guard. Project status
labels were not used as proof evidence.

## 1. The original statement and the checked target agree

The primary source is Liu–Wu–Zhang–Zhou,
[arXiv:1811.10137v2, Appendix A, printed page 42](https://arxiv.org/pdf/1811.10137v2#page=42).
Its Conjecture A.1 concerns an arbitrary vector space over a characteristic-zero
field, three endomorphisms satisfying
\(Z=XY-YX\) and \([X,Z]=[Y,Z]=0\), and a vector killed by
\(X^{p+1}\) and \(Y^{q+1}\). The conclusion is
\((X+Y)^{2p+2q+1}v=0\). The same page explicitly treats zero parameters;
the conjecture itself does not restrict the parameters to the special cases
proved there. This matches `docs/audit-2026-11-05/problem_contract.md`.

Using the original commutator rather than the project's abbreviation, the complete
expanded Lean target is:

```lean
universe u v

∀ {K : Type u} {V : Type v} [Field K] [CharZero K]
  [AddCommGroup V] [Module K V] (X Y : Module.End K V),
  Commute X (X * Y - Y * X) →
  Commute Y (X * Y - Y * X) →
  ∀ (p q : ℕ) (w : V),
    (X ^ (p + 1)) w = 0 →
    (Y ^ (q + 1)) w = 0 →
    ((X + Y) ^ (2 * p + 2 * q + 1)) w = 0
```

The independently compiled `Guard.lean` checks:

1. `definition_matches_raw`: `VectorConjecture K V` is **definitionally equal**
   to this raw-commutator proposition (`rfl`).
2. `general_has_exact_type`: `@vector_general.{u, v}` directly inhabits the full
   displayed type, without an intervening lemma that changes its assumptions.
3. `conjecture_has_full_polymorphic_type`: the actual `vector_conjecture` inhabits
   `∀ (K : Type u) (V : Type v) [Field K] [CharZero K] [AddCommGroup V]
   [Module K V], VectorConjecture K V`.
4. `conjecture_has_raw_type`: the same root also directly inhabits the expanded
   raw-commutator type.
5. `cutoff_has_raw_type`: the cutoff theorem has the original hypotheses and
   concludes \((XY-YX)^kX^aY^bw=0\) when
   \(a+b+2k=2p+2q+1\).
6. `original_three_operator_form`: the original presentation with a separately
   quantified `Z`, its defining equality, and the two commutators equal to zero
   follows by substituting that equality and using `sub_eq_zero`.

The universe parameters `u` and `v` in these checks are independent. The last
check confirms that eliminating the originally named `Z` loses no generality.

## 2. The hypotheses retain their original meaning

Direct inspection of the owning Mathlib definitions confirms that `Module.End K V`
is `V →ₗ[K] V`, `(F * G) w = F (G w)`, the multiplicative unit is the identity,
and `Commute F G` means `F * G = G * F`. Thus the powers are composition powers,
not pointwise products, and `ad X Y` has the required sign `X*Y - Y*X`.

- `Field K` and `CharZero K` are actual retained root parameters. The result is
  not restricted to rational, real, complex, ordered, or algebraically closed fields.
- `AddCommGroup V` with `Module K V` expresses an arbitrary algebraic vector
  space. There is no finite-dimensionality, finite basis, topology, or
  nontriviality assumption on `V`.
- The two commuting relations are operator identities on all of `V`, but require
  commutation only with `X` and `Y`. No ambient-center hypothesis is introduced.
- Both annihilation hypotheses and the conclusion apply to the same given vector.
  They are not replaced by `X^(p+1) = 0` or `Y^(q+1) = 0` as operator identities.
- `p` and `q` range independently over all naturals, with no positivity, ordering,
  or size restriction. Zero parameters, the zero vector, and the zero vector
  space are included. At `p=q=0`, the stated exponent is exactly one.

The separate `readback.md` reconstructs the same mathematical statement from the
formal packet without the informal target. Its reconstructed quantifiers,
definitions, and vector/operator distinction agree with this source comparison.

## 3. The auxiliary interfaces are proved, not left as root assumptions

The root's mathematical import closure consists of the eight reviewed source
modules `ConjectureA1`, `LineRecurrence`, `Fewnomial`, `LineSystem`, `NormalOrder`,
`MonomialActions`, `WeightedLines`, and `General`. Direct text comparison found
these frozen review sources identical to the corresponding current project files.

The proof dependencies close as follows:

- **Sparse uniqueness.** `sparseRootProperty` in `Fewnomial.lean` proves
  `SparseRootProperty K` from `Field K` and `CharZero K`. For a polynomial with
  at most `m` support indices divisible by `(X-1)^m`, Euler elimination
  `X*f' - e*f` removes a support index and lowers the required vanishing order.
  Characteristic zero makes distinct natural exponents distinct scalars. The
  remaining single monomial vanishes at one, so it is zero. The `m=0` case is
  handled directly by empty support.
- **Finite-line kernel.** `scalar_line_vanish` forms
  \(U(t)=\sum_{b=0}^D u(b)t^b/b!\) and
  \(H(t)=(1-t)^{p+1}U(t)\). The actual recurrence kills the middle
  coefficients. The support lies in the two disjoint boundary intervals
  \([\ell,b_0)\) and \((M,D+p+1]\), whose total size is bounded by `p+1`.
  Sparse uniqueness gives `H=0`, then `U=0` and `u=0`.
- **Arbitrary vector spaces.** `line_vanish` applies the scalar result to every
  algebraic linear functional and uses dual separation. The library separation
  theorem requests a projective module; every vector space over the given field
  supplies this through `Module.Free.of_divisionRing` and `Projective.of_free`.
  These are proved library instances, not an extra root assumption or a
  finite-dimensional restriction.
- **Genuine vector relation.** `vector_right_line_relation` comes from normal
  ordering `Y^B * X^(p+1)` and applying it to the vector. Then
  `mono_left_line_relation` applies a genuine left multiplier to that zero
  vector. No right-ideal closure, two-sided ideal, or individual monomial
  vanishing is silently substituted.
- **Discharge at the root.** In `vector_monomial_cutoff`, the local `hkernel`
  is constructed explicitly by `line_vanish (sparseRootProperty K)`. The required
  operator line relation is supplied by `mono_left_line_relation ... hx`.
  `weighted_monomial_vanish_of_line` therefore receives proofs of both of its
  conditional interfaces.
- **Final assembly.** The actual three-term action of `X+Y` on ordered monomials
  feeds `weighted_iterate_vanish`. Taking the iteration count equal to
  `2*p+2*q+1` and the starting indices all zero yields the original vector
  conclusion. `vector_conjecture` then returns this proof under the unchanged
  `VectorConjecture` definition.

The actual names above have namespace prefix `ConjectureA1`; module names identify
their source files. There is no PBW premise, finite computation premise, or
unproved sparse/line hypothesis in the root's type or proof closure.

## 4. Boundary and truncation checks

The natural-number subtraction in the formal proof is truncated subtraction.
Its boundary terms are explicitly controlled:

- In the recurrence, `j>b` implies `b.descFactorial j=0`; such terms cannot
  produce a spurious contribution at `u 0`.
- Extending or shortening the normal-order sum uses the zero binomial coefficient
  for `j>p+1` and the zero falling factorial for `j>B`.
- The left-anchor relation requires `A≥p+1`, while the remaining summation range
  has `j≤p+1`; hence its `A-j` exponents are genuine nonnegative differences.
- Factorial division is used only with a proved nonzero factorial in the
  characteristic-zero field.
- At the odd cutoff weight, `A=B` is impossible. The `B≤A` branch uses the
  nonnegative difference `d=A-B`; the `A<B` branch uses lower endpoint `r=B-A`.
  Each branch proves its support bounds, nonempty anchor interval, recurrence,
  and exact support-count inequality before invoking the kernel.
- In weighted iteration, the `a=0` branch separately kills the last term by
  its zero scalar coefficient. It does not apply a false weight identity to
  the truncated index `a-1`.

## 5. Machine execution and transitive axioms

### Retained fresh project run

I inspected `formalization/evidence/validation-report.json`, the actual output
in `validation-build.log`, `build-context.log`, and the build/validation code.
The offline target directly invokes Lean for every material module in dependency
order, prepending its fresh project output directory to `LEAN_PATH`; it does not
accept an old project artifact merely because Lake has a cached success flag.

The retained output contains 12 distinct `CHECKED` module lines, including
`General` and `AxiomAudit`, followed by successful completion and `EXIT=0`.
It contains 62 distinct declaration axiom outputs, agreeing with the report's
62 declarations and 62 recorded axiom sets. The report has no forbidden code
tokens, missing probes, unreported declarations, unchecked material modules,
or disallowed axioms. Its build return code is zero. This is the existing fresh
12-module run, not a second full build performed by this reviewer.

### Newly executed independent guard

The final `Guard.lean` compiled successfully with **exit code 0**. No error or
warning was emitted. Its compiler output is retained as `guard.log` with the
local review evidence.

The actual invocation was direct Lean on `Guard.lean`, with the project's freshly
compiled library first in `LEAN_PATH` and the dependency path from the recorded
build context after it. The invocation is reproduced portably below; the local
executable, guard-file location, and dependency directories are parameters:

```powershell
$env:LEAN_PATH = "$env:A1_PROJECT_BUILD;$env:A1_DEPENDENCY_LEAN_PATH"
& $env:A1_LEAN_EXE $env:A1_GUARD
# Observed final exit code: 0
```

`A1_PROJECT_BUILD` is the project's `formalization/.lake/build/lib/lean`;
`A1_DEPENDENCY_LEAN_PATH` is the dependency-only `LEAN_PATH` recorded by the fresh
build; `A1_GUARD` names this audit's `Guard.lean`. The compiler actually reported
Lean **4.31.0**, commit `68218e876d2a38b1985b8590fff244a83c321783`.
The reused environment pins Mathlib to
`fabf563a7c95a166b8d7b6efca11c8b4dc9d911f`, with its eight transitive package
versions recorded in `formalization/lake-manifest.json` and the build context.

The guard freshly prints the transitive axioms of both full roots, the cutoff,
sparse uniqueness, scalar/vector line kernels, the left-anchor relation, both
weighted-assembly lemmas, and the independently stated three-operator form.
Every one has exactly:

```text
propext, Classical.choice, Quot.sound
```

There is no `sorryAx`, custom axiom, or unproved auxiliary assertion in
these transitive axiom outputs. Cached Mathlib artifacts and Lean's own kernel
remain the machine-checking trust boundary; this review did not rebuild Mathlib
or run an alternative kernel implementation.

## 6. Legacy proposition and completion scope

`ConjectureA1.ConjectureA1 R V` remains a different, unproved ring/module
proposition. Its unused rational-algebra section binder is absent from its
actual type, and it requires ambient centrality. It is neither the root returned
here nor a lemma or premise used in the reviewed root dependency chain. The
raw-type guards prevent confusing that proposition with `VectorConjecture`.

**No main-theorem proof obligation remains for the original Conjecture A.1 in
this candidate.** General sharpness is a separate assertion and is not proved by
these Lean roots. Its lack of general Lean formalization does not make the
original conjecture proof partial: sharpness is not an assumption, conclusion,
or dependency of that conjecture.

The written sharpness argument, explicit trinomial formulas, universal-algebra
extensions beyond the cutoff, PDF layout, and publication permissions are outside
this root-contract verdict. None is needed to close the checked root. This audit
made no project-source, dependency-cache, Git, or remote changes; its deliverables
are this report, `Guard.lean`, and the corresponding successful compiler output.
