import NormalOrder
import LineRecurrence
import Lean.Elab.Tactic.Omega

open Finset
open scoped BigOperators

namespace ConjectureA1

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]

/-- Ordered monomials, with the central commutator power on the left. -/
def mono (X Y : Module.End K V) (a b k : ℕ) (v : V) : V :=
  ((ad X Y) ^ k) ((X ^ a) ((Y ^ b) v))

lemma neg_pow_apply (T : Module.End K V) (j : ℕ) (w : V) :
    ((-T) ^ j) w = (-1 : K) ^ j • (T ^ j) w := by
  induction j with
  | zero => simp
  | succ j ih =>
    rw [pow_succ', Module.End.mul_apply, ih, map_smul]
    simp [pow_succ', Module.End.mul_apply]

lemma x_apply_mono (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (a b k : ℕ) (v : V) :
    X (mono X Y a b k v) = mono X Y (a + 1) b k v := by
  unfold mono
  have hc := congrArg (fun T : Module.End K V => T ((X ^ a) ((Y ^ b) v)))
    (hX.pow_right k).eq
  simp only [Module.End.mul_apply] at hc
  rw [hc, pow_succ', Module.End.mul_apply]

lemma y_mul_x_pow (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (a : ℕ) :
    Y * X ^ a = X ^ a * Y - a • (X ^ (a - 1) * ad X Y) := by
  have hX' : Commute X (ad Y X) := by rw [ad_swap]; exact hX.neg_right
  have h := ad_pow_eq Y X hX' a
  rw [ad_swap X Y, mul_neg, smul_neg] at h
  change Y * X ^ a - X ^ a * Y = _ at h
  exact (sub_eq_iff_eq_add.mp h).trans (by abel)

lemma y_apply_mono (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (a b k : ℕ) (v : V) :
    Y (mono X Y a b k v) = mono X Y a (b + 1) k v -
        (a : K) • mono X Y (a - 1) b (k + 1) v := by
  unfold mono
  have hc := congrArg (fun T : Module.End K V => T ((X ^ a) ((Y ^ b) v)))
    (hY.pow_right k).eq
  simp only [Module.End.mul_apply] at hc
  rw [hc]
  have he := congrArg (fun T : Module.End K V => T ((Y ^ b) v)) (y_mul_x_pow X Y hX a)
  simp only [Module.End.mul_apply, LinearMap.sub_apply, LinearMap.smul_apply] at he
  rw [he, map_sub, map_nsmul]
  have hz := congrArg (fun T : Module.End K V => T ((Y ^ b) v))
    ((hX.pow_left (a - 1)).eq)
  simp only [Module.End.mul_apply] at hz
  rw [hz]
  rw [show (Y ^ (b + 1)) v = Y ((Y ^ b) v) from by
    rw [pow_succ', Module.End.mul_apply], pow_succ, Module.End.mul_apply,
    Nat.cast_smul_eq_nsmul]

lemma add_apply_mono (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (a b k : ℕ) (v : V) :
    (X + Y) (mono X Y a b k v) =
      mono X Y (a + 1) b k v + mono X Y a (b + 1) k v -
        (a : K) • mono X Y (a - 1) b (k + 1) v := by
  rw [LinearMap.add_apply, x_apply_mono X Y hX, y_apply_mono X Y hX hY]
  abel

lemma sum_range_eq_of_zero (f : ℕ → V) (n m : ℕ)
    (hn : ∀ j, n ≤ j → f j = 0) (hm : ∀ j, m ≤ j → f j = 0) :
    ∑ j ∈ range n, f j = ∑ j ∈ range m, f j := by
  rcases le_total n m with h | h
  · apply Finset.sum_subset (Finset.range_mono h)
    intro j hj hjn
    exact hn j (by simpa only [mem_range, not_lt] using hjn)
  · symm
    apply Finset.sum_subset (Finset.range_mono h)
    intro j hj hjm
    exact hm j (by simpa only [mem_range, not_lt] using hjm)

lemma left_apply_ordered_term (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (d a b j k : ℕ) (v : V) :
    ((ad X Y) ^ k) ((X ^ d) ((X ^ a * (-ad X Y) ^ j * Y ^ b) v)) =
      (-1 : K) ^ j • mono X Y (d + a) b (k + j) v := by
  simp only [Module.End.mul_apply]
  rw [neg_pow_apply, map_smul, map_smul, map_smul]
  congr 1
  have hc := congrArg (fun T : Module.End K V => T ((Y ^ b) v))
    (hX.pow_pow (d + a) j).eq
  simp only [Module.End.mul_apply] at hc
  calc
    ((ad X Y) ^ k) ((X ^ d) ((X ^ a) (((ad X Y) ^ j) ((Y ^ b) v)))) =
        ((ad X Y) ^ k) ((X ^ (d + a)) (((ad X Y) ^ j) ((Y ^ b) v))) := by
      rw [pow_add, Module.End.mul_apply]
    _ = ((ad X Y) ^ k) (((ad X Y) ^ j) ((X ^ (d + a)) ((Y ^ b) v))) := by rw [hc]
    _ = mono X Y (d + a) b (k + j) v := by
      simp only [mono, pow_add, Module.End.mul_apply]

/-- The genuine vector left-anchor relation. Only X^(p+1) annihilates v. -/
lemma mono_left_line_relation (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (p A B k : ℕ) (v : V) (hA : p + 1 ≤ A)
    (hx : (X ^ (p + 1)) v = 0) :
    ∑ j ∈ range (p + 2),
      lineCoeff K p B j • mono X Y (A - j) (B - j) (k + j) v = 0 := by
  let f : ℕ → V := fun j => (B.descFactorial j * (p + 1).choose j) •
      ((X ^ (p + 1 - j) * (-ad X Y) ^ j * Y ^ (B - j)) v)
  have hrel : ∑ j ∈ range (p + 2), f j = 0 := by
    rw [sum_range_eq_of_zero f (p + 2) (B + 1)]
    · simpa only [f, LinearMap.sum_apply, LinearMap.smul_apply] using
        vector_right_line_relation X Y hX hY p B v hx
    · intro j hj
      have hz : (p + 1).choose j = 0 := Nat.choose_eq_zero_of_lt (by omega)
      simp only [f, hz, mul_zero, zero_smul]
    · intro j hj
      have hz : B.descFactorial j = 0 := Nat.descFactorial_of_lt (by omega)
      simp only [f, hz, zero_mul, zero_smul]
  have hleft := congrArg (fun w : V => ((ad X Y) ^ k) ((X ^ (A - (p + 1))) w)) hrel
  simp only [map_sum, map_zero] at hleft
  rw [← hleft]
  apply Finset.sum_congr rfl
  intro j hj
  have hjp : j ≤ p + 1 := by have := mem_range.mp hj; omega
  have hidx : A - (p + 1) + (p + 1 - j) = A - j := by omega
  dsimp only [f]
  rw [map_nsmul, map_nsmul, left_apply_ordered_term X Y hX, hidx]
  simp only [lineCoeff, ← Nat.cast_smul_eq_nsmul K, smul_smul, Nat.cast_mul]
  congr 1
  ac_rfl
end ConjectureA1
