/-
Elementary commutator layer and faithful statement of Conjecture A.1.

NormalOrder.lean proves arbitrary-power Taylor/normal-order formulas and the
vector right-annihilator recurrence. BoundaryCases.lean proves every p=0 or
q=0 case. VectorCases.lean retains the p,q <= 1 results.
The general positive-parameter theorem is not proved; see PROGRESS.md.
-/

import Mathlib.Algebra.Algebra.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Nat.Choose.Sum
import Mathlib.Data.Nat.Factorial.Basic
import Mathlib.Algebra.Module.LinearMap.End
import Mathlib.Tactic.NoncommRing
import Mathlib.Tactic.NormNum

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
  rw [pow_succ']
  noncomm_ring

end Derivation

section CommutatorPowers

variable {R : Type*} [Ring R]

lemma ad_swap (x y : R) : ad y x = -ad x y := by
  unfold ad
  noncomm_ring

/-- Commutator with a positive power. Only Y-Z commutation is required. -/
lemma ad_pow_of_commute (x y : R) (hy : Commute y (ad x y)) (n : ℕ) :
    ad x (y ^ (n + 1)) = (n + 1) • (y ^ n * ad x y) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [pow_succ, ad_mul, ih]
    calc
      (n + 1) • (y ^ n * ad x y) * y + y ^ (n + 1) * ad x y =
          (n + 1) • (y ^ (n + 1) * ad x y) + y ^ (n + 1) * ad x y := by
        rw [smul_mul_assoc, mul_assoc, ← hy.eq, ← mul_assoc, ← pow_succ]
      _ = (n + 1 + 1) • (y ^ (n + 1) * ad x y) := by
        simp only [add_nsmul, one_nsmul]

/-- One-X normal ordering, with the sign fixed by XY-YX=Z. -/
lemma mul_pow_normal_order (x y : R) (hy : Commute y (ad x y)) (n : ℕ) :
    x * y ^ (n + 1) = y ^ (n + 1) * x + (n + 1) • (y ^ n * ad x y) := by
  have h := ad_pow_of_commute x y hy n
  unfold ad at h
  have h' := sub_eq_iff_eq_add.mp h
  simpa only [ad, add_comm] using h'

/-- Power-commutator formula including n=0 (truncated subtraction is harmless). -/
lemma ad_pow_eq (x y : R) (hy : Commute y (ad x y)) (n : ℕ) :
    ad x (y ^ n) = n • (y ^ (n - 1) * ad x y) := by
  cases n with
  | zero => simp
  | succ n => simpa only [Nat.add_sub_cancel] using ad_pow_of_commute x y hy n

/-- Normal ordering with the power on the left. Only X-Z commutation is needed. -/
lemma pow_mul_normal_order (x y : R) (hx : Commute x (ad x y)) (n : ℕ) :
    x ^ (n + 1) * y = y * x ^ (n + 1) + (n + 1) • (x ^ n * ad x y) := by
  have hx' : Commute x (ad y x) := by rw [ad_swap]; exact hx.neg_right
  have h := mul_pow_normal_order y x hx' n
  rw [ad_swap, mul_neg, smul_neg] at h
  have h' : y * x ^ (n + 1) =
      x ^ (n + 1) * y - (n + 1) • (x ^ n * ad x y) := by
    simpa only [sub_eq_add_neg] using h
  exact (eq_sub_iff_add_eq.mp h').symm

end CommutatorPowers

/-! ## 2. Statement of the target (a `def`, hence no proof is claimed)

Legacy statement, retained under its original name for compatibility. Lean drops
the unused `Algebra ℚ R` section instance: its actual signature has only `Ring R`.
It also requires ambient centrality, stronger than commuting with X and Y.
The faithful characteristic-zero endomorphism target is `VectorConjecture` below.
-/

section Statement

variable (R V : Type*) [Ring R] [Algebra ℚ R] [AddCommGroup V] [Module R V]

/-- Legacy ring/module proposition; NOT the frozen characteristic-zero target. -/
def ConjectureA1 : Prop :=
  ∀ (x y : R) (z : R), z = ad x y → (∀ w : R, z * w = w * z) →
  ∀ (p q : ℕ) (v : V),
    (x ^ (p + 1)) • v = 0 → (y ^ (q + 1)) • v = 0 →
    ((x + y) ^ (2 * p + 2 * q + 1)) • v = 0

end Statement

section FaithfulStatement

/-- The frozen vector-level target. This declaration defines a proposition only.
No finite-dimensionality or ambient-centrality assumption is imposed. Explicit
binders retain CharZero, which an unused section instance would silently drop. -/
def VectorConjecture (K V : Type*) [Field K] [CharZero K]
    [AddCommGroup V] [Module K V] : Prop :=
  ∀ (X Y : Module.End K V),
    Commute X (ad X Y) → Commute Y (ad X Y) →
    ∀ (p q : ℕ) (v : V),
      (X ^ (p + 1)) v = 0 → (Y ^ (q + 1)) v = 0 →
      ((X + Y) ^ (2 * p + 2 * q + 1)) v = 0

end FaithfulStatement

/-! ## 3. Further layers

`NormalOrder.lean` proves the general Taylor expansion and all iterated
commutators of Y-powers under the two local commutation relations. No ambient
centrality is needed. `BoundaryCases.lean` proves all zero-parameter families.

The general line-system vanishing argument, the trinomial expansion and assembly
into a proof of `VectorConjecture` remain open. The written manuscript's
operator-nilpotence lemma is not substituted for this vector-level target.
-/

end ConjectureA1
