/-
  ConjectureA1.lean
  ============================================================================
  Lean 4 + Mathlib formalisation, **layer 1** of
  《报告_ConjectureA1的证明》 (Conjecture A.1 of Liu–Wu–Zhang–Zhou,
  Comm. Math. Phys. 375 (2020) 785–832, Appendix A).

  ⚠️  STATUS  ⚠️
  ----------------------------------------------------------------------------
  Produced in an environment with **no Lean toolchain and no network**, hence
  **NOT compiled**.  The file contains
      * no `sorry`,
      * no user-declared `axiom`,
      * no `unsafe` / `native_decide` shortcuts.
  Only declarations whose proofs are short and whose Mathlib dependencies are
  minimal are *stated and proved* here.  The mathematically substantial steps
  (Taylor expansion, the `z`-power lemma, the trinomial formula, the two-sided
  theorem, and a fortiori Conjecture A.1 itself) are recorded as **comments**
  with their exact Lean statements and proof plans — a comment is not a proof
  obligation, so nothing here is faked, and nothing is assumed.

  What *is* machine-provable in this file: `ad` is a derivation of a
  (non-commutative) ring, together with the elementary identities used later.
  ============================================================================
-/

import Mathlib.Algebra.Algebra.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Nat.Choose.Sum
import Mathlib.Data.Nat.Factorial.Basic
import Mathlib.Tactic

open Finset
open scoped BigOperators

namespace ConjectureA1

/-! ## 1. The inner derivation `ad` -/

section Derivation

variable {R : Type*} [Ring R]

/-- `ad x y = x * y - y * x`.  (Report's convention `[x,y] = x*y - y*x`.) -/
def ad (x y : R) : R := x * y - y * x

@[simp] lemma ad_def (x y : R) : ad x y = x * y - y * x := rfl

lemma ad_add (x y z : R) : ad x (y + z) = ad x y + ad x z := by
  unfold ad
  rw [mul_add, add_mul]
  abel

lemma ad_zero (x : R) : ad x 0 = 0 := by
  unfold ad
  simp

lemma ad_neg (x y : R) : ad x (-y) = -ad x y := by
  unfold ad
  noncomm_ring

lemma ad_one (x : R) : ad x (1 : R) = 0 := by
  unfold ad
  simp

/-- Leibniz rule: `ad x` is a derivation. -/
lemma ad_mul (x y z : R) : ad x (y * z) = ad x y * z + y * ad x z := by
  unfold ad
  noncomm_ring

/-- `ad x` is additive and a derivation; packaged form used by `taylor`. -/
lemma ad_pow_succ (x : R) (w : R) (r : ℕ) :
    x * (w * x ^ r) = w * x ^ (r + 1) + ad x w * x ^ r := by
  unfold ad
  rw [pow_succ]
  noncomm_ring

end Derivation

/-! ## 2. Statement of the target (a `def`, hence no proof is claimed)

We record the conjecture exactly as in the report, over a `ℚ`-algebra `R` and a
`R`-module `V`.  `ConjectureA1` is a *definition of a proposition*; asserting it
would require the proofs of §2 of `形式化说明与差异.md`.
-/

section Statement

variable (R V : Type*) [Ring R] [Algebra ℚ R] [AddCommGroup V] [Module R V]

/-- Conjecture A.1 (Liu–Wu–Zhang–Zhou), vector-level form. -/
def ConjectureA1 : Prop :=
  ∀ (x y : R) (z : R), z = ad x y → (∀ w : R, z * w = w * z) →
  ∀ (p q : ℕ) (v : V),
    (x ^ (p + 1)) • v = 0 → (y ^ (q + 1)) • v = 0 →
    ((x + y) ^ (2 * p + 2 * q + 1)) • v = 0

end Statement

/-! ## 3. NOT FORMALISED HERE — exact statements and proof plans

The following block lists, in Lean syntax, every lemma that the report proves and
that this file does **not** prove.  They are comments on purpose.  `形式化说明与差异.md`
gives, for each one, the effort estimate and the reason.

```
section Layer2

variable {R : Type*} [Ring R] [Algebra ℚ R]

/-- Report Lemma 4.1 / Appendix A.2.  Needs `Finset.sum_range_succ` bookkeeping. -/
lemma taylor (x y : R) (n : ℕ) :
    x ^ n * y
      = ∑ j in range (n + 1), ((n.choose j : ℕ) : R) * ((ad x)^[j] y) * x ^ (n - j) := by
  -- induction on n; step:
  --   x^(n+1) * y = x * (x^n * y)
  --   = ∑_j C(n,j) * x * ((ad x)^[j] y * x^(n-j))
  --   = ∑_j C(n,j) * ((ad x)^[j] y * x^(n-j+1) + ((ad x)^[j+1] y) * x^(n-j))
  --   (uses `ad_pow_succ` above)
  -- then reindex the second sum and use Pascal: C(n,j) + C(n,j-1) = C(n+1,j).
  -- Mathlib ingredients: `Finset.sum_range_succ`, `Finset.sum_range_succ'`,
  -- `Nat.choose_succ_succ`, `Function.iterate_succ_apply'`.

/-- Report Lemma 4.1, iterated form.  Hypothesis `hxy : z = ad x y`, `hz` = centrality. -/
lemma ad_iterate_y_pow (x y z : R) (hxy : z = ad x y) (hz : ∀ w : R, z * w = w * z)
    (m j : ℕ) :
    ((ad x)^[j]) (y ^ m) = ((m.descFactorial j : ℕ) : R) * (y ^ (m - j) * z ^ j) := by
  -- induction on j; step uses `ad_y_pow` and `z*w = w*z`
  -- (`Nat.descFactorial_succ`), truncated subtraction handles `j > m`
  -- because `m.descFactorial j = 0` then.

/-- Report Lemma 4.2 "key relation" (`R(A,B,K) = (X^{A-p-1} Y^B Z^K) X^{p+1} ∈ I`),
    here in the two-sided form used by Proposition 4.5 of the report. -/
lemma z_pow_mul_x_pow (x y z : R) (hxy : z = ad x y) (hz : ∀ w : R, z * w = w * z)
    (p : ℕ) (hx : x ^ (p + 1) = 0) :
    ∀ J : ℕ, 1 ≤ J → J ≤ p + 1 → z ^ J * x ^ (p + 1 - J) = 0 := by
  -- `x^(p+1) * y^J = 0`; expand by `taylor` and `ad_iterate_y_pow`;
  -- the j = 0 term vanishes (`x^(p+1) = 0`), terms j < J by induction,
  -- leaving C(p+1,J) * J! * (z^J * x^(p+1-J)) = 0;
  -- conclude since char 0 (`Nat.cast_ne_zero` of `(p+1).choose J * J.factorial`).

/-- Report Theorem 3.1 (generalised binomial theorem / trinomial formula). -/
lemma trinomial (x y z : R) (hxy : z = ad x y) (hz : ∀ w : R, z * w = w * z) (n : ℕ) :
    (x + y) ^ n
      = ∑ k in range (n / 2 + 1), (((-1 : ℚ) ^ k / (2 ^ k * k.factorial) : ℚ) : R)
          * (z ^ k * ∑ ab in Finset.antidiagonal (n - 2 * k),
              ((1 : ℚ) / ((ab.1.factorial * ab.2.factorial : ℕ) : ℚ) : ℚ) * (x ^ ab.1 * y ^ ab.2)) := by
  -- induction on n via the divided-power recursion
  --   (m+1) B_{m+1} = (x+y) B_m + z B_{m-1},  B_m = ∑_{a+b=m} x^a y^b /(a! b!)
  -- which follows from `d/dt e^{tx}e^{ty} = (x+y+t z) e^{tx}e^{ty}`.

/-- Report Proposition 4.5: the **two-sided** theorem. -/
theorem two_sided (x y z : R) (hxy : z = ad x y) (hz : ∀ w : R, z * w = w * z)
    (p q : ℕ) (hx : x ^ (p + 1) = 0) (hy : y ^ (q + 1) = 0) :
    (x + y) ^ (2 * p + 2 * q + 1) = 0 := by
  -- assemble `trinomial` with the vanishing of `z^J x^(p+1-J)` and
  -- `z^J y^(q+1-J)`; see the report, Proof of Proposition 4.5.

end Layer2
```

## 4. The missing layer (why the conjecture itself is not proved here)

Conjecture A.1 is the **one-sided** statement: the hypothesis is `x^(p+1) • v = 0`
(vector level), not `x^(p+1) = 0` (element level).  Its proof needs, beyond layer 2,

  (a) the Heisenberg algebra as a ring with a **PBW normal form and its grading**
      (`A = U(h₁)`, basis `X^a Y^b Z^k`, `I = A X^{p+1} + A Y^{q+1}`),
  (b) the **"line" linear-algebra argument** (triangular minors) and
  (c) the **fewnomial multiplicity bound for module-valued polynomials**
      (`Module.Dual` separation on a finitely spanned submodule).

None of these is formalised; `形式化说明与差异.md` §3 quantifies the gap.
-/

end ConjectureA1
