import LineRecurrence
import Mathlib.Algebra.Polynomial.Coeff
import Mathlib.LinearAlgebra.Dual.Lemmas
import Mathlib.Order.Interval.Finset.Nat
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

open scoped BigOperators

namespace ConjectureA1

open Polynomial

noncomputable section

variable {K : Type*} [Field K]

/-- The finite exponential generating polynomial of a scalar line. -/
def linePolynomial (D : ℕ) (u : ℕ → K) : K[X] :=
  ∑ b ∈ Finset.range (D + 1), monomial b (u b / (b.factorial : K))

theorem coeff_linePolynomial (D : ℕ) (u : ℕ → K)
    (hhi : ∀ b, D < b → u b = 0) (b : ℕ) :
    (linePolynomial D u).coeff b = u b / (b.factorial : K) := by
  classical
  simp only [linePolynomial, finsetSum_coeff, coeff_monomial]
  rw [Finset.sum_ite_eq']
  by_cases hb : b ∈ Finset.range (D + 1)
  · simp [hb]
  · simp only [Finset.mem_range, not_lt] at hb
    simp [hhi b (by omega)]

theorem one_sub_X_pow_expansion (m : ℕ) :
    (1 - X : K[X]) ^ m =
      ∑ j ∈ Finset.range (m + 1), monomial j ((-1 : K) ^ j * (m.choose j : K)) := by
  classical
  rw [show (1 - X : K[X]) = -X + 1 by ring, add_pow]
  apply Finset.sum_congr rfl
  intro j hj
  rw [one_pow, mul_one, neg_pow, ← C_mul_X_pow_eq_monomial]
  simp only [← C_neg, ← C_1, ← C_pow, C_mul, ← C_eq_natCast]
  ring

theorem coeff_line_product (D m : ℕ) (u : ℕ → K)
    (hhi : ∀ b, D < b → u b = 0) (b : ℕ) :
    (((1 - X : K[X]) ^ m) * linePolynomial D u).coeff b =
      ∑ j ∈ Finset.range (m + 1),
        if j ≤ b then (-1 : K) ^ j * (m.choose j : K) *
          (u (b - j) / ((b - j).factorial : K)) else 0 := by
  classical
  rw [one_sub_X_pow_expansion, Finset.sum_mul, finsetSum_coeff]
  apply Finset.sum_congr rfl
  intro j hj
  rw [← C_mul_X_pow_eq_monomial, mul_assoc, coeff_C_mul, coeff_X_pow_mul']
  by_cases hjb : j ≤ b
  · simp [hjb, coeff_linePolynomial D u hhi]
  · simp [hjb]

variable [CharZero K]

/-- Coefficients of the generating product recover the original falling-factorial relation. -/
theorem factorial_mul_coeff_line_product (p D : ℕ) (u : ℕ → K)
    (hhi : ∀ b, D < b → u b = 0) (b : ℕ) :
    (b.factorial : K) *
        (((1 - X : K[X]) ^ (p + 1)) * linePolynomial D u).coeff b =
      ∑ j ∈ Finset.range (p + 2), lineCoeff K p b j * u (b - j) := by
  classical
  rw [coeff_line_product D (p + 1) u hhi, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  by_cases hjb : j ≤ b
  · rw [if_pos hjb]
    have hf : ((b - j).factorial : K) * (b.descFactorial j : K) =
        (b.factorial : K) := by
      exact_mod_cast Nat.factorial_mul_descFactorial hjb
    rw [← hf]
    have hn : ((b - j).factorial : K) ≠ 0 := by
      exact_mod_cast Nat.factorial_ne_zero (b - j)
    simp only [lineCoeff]
    field_simp
  · rw [if_neg hjb]
    simp [lineCoeff, Nat.descFactorial_of_lt (by omega : b < j)]

/-- Only the two boundary intervals can support the generating product. -/
theorem support_line_product_subset (p lo D M b0 : ℕ) (u : ℕ → K)
    (hlo : ∀ b, b < lo → u b = 0) (hhi : ∀ b, D < b → u b = 0)
    (hrel : LineRecurrence (K := K) p b0 M u) :
    (((1 - X : K[X]) ^ (p + 1)) * linePolynomial D u).support ⊆
      Finset.Ico lo b0 ∪ Finset.Ioc M (D + p + 1) := by
  classical
  intro b hb
  have hbne := mem_support_iff.mp hb
  have hl : lo ≤ b := by
    by_contra hl
    apply hbne
    rw [coeff_line_product D (p + 1) u hhi]
    apply Finset.sum_eq_zero
    intro j hj
    split_ifs with hjb
    · rw [hlo (b - j) (by omega)]
      simp
    · rfl
  have hh : b ≤ D + p + 1 := by
    by_contra hh
    apply hbne
    rw [coeff_line_product D (p + 1) u hhi]
    apply Finset.sum_eq_zero
    intro j hj
    have hjm : j < p + 1 + 1 := Finset.mem_range.mp hj
    split_ifs with hjb
    · rw [hhi (b - j) (by omega)]
      simp
    · rfl
  by_cases hb0 : b < b0
  · exact Finset.mem_union.mpr (Or.inl (Finset.mem_Ico.mpr ⟨hl, hb0⟩))
  · have hMb : M < b := by
      by_contra hMb
      have hr := hrel b (by omega) (by omega)
      have he := factorial_mul_coeff_line_product p D u hhi b
      simp only [smul_eq_mul] at hr
      rw [hr] at he
      have hfact : (b.factorial : K) ≠ 0 := by
        exact_mod_cast Nat.factorial_ne_zero b
      exact hbne ((mul_eq_zero.mp he).resolve_left hfact)
    exact Finset.mem_union.mpr (Or.inr (Finset.mem_Ioc.mpr ⟨hMb, hh⟩))

/-- Scalar finite-line uniqueness from sparse-root uniqueness. -/
theorem scalar_line_vanish (hsparse : SparseRootProperty K)
    (p lo D M b0 : ℕ) (u : ℕ → K)
    (hlo : ∀ b, b < lo → u b = 0) (hhi : ∀ b, D < b → u b = 0)
    (hanchor : lo ≤ b0 ∧ b0 ≤ M)
    (hrel : LineRecurrence (K := K) p b0 M u)
    (hcount : (b0 - lo) + (D + p + 1 - M) ≤ p + 1) :
    ∀ b, u b = 0 := by
  classical
  let H : K[X] := ((1 - X) ^ (p + 1)) * linePolynomial D u
  have hcard : H.support.card ≤ p + 1 := by
    calc
      H.support.card ≤ (Finset.Ico lo b0 ∪ Finset.Ioc M (D + p + 1)).card :=
        Finset.card_le_card (support_line_product_subset p lo D M b0 u hlo hhi hrel)
      _ = (Finset.Ico lo b0).card + (Finset.Ioc M (D + p + 1)).card := by
        apply Finset.card_union_of_disjoint
        apply Finset.disjoint_left.mpr
        intro b hb0 hbM
        have hl := Finset.mem_Ico.mp hb0
        have hr := Finset.mem_Ioc.mp hbM
        omega
      _ = (b0 - lo) + (D + p + 1 - M) := by simp
      _ ≤ p + 1 := hcount
  have hdiv : (X - 1 : K[X]) ^ (p + 1) ∣ H := by
    refine ⟨(-1 : K[X]) ^ (p + 1) * linePolynomial D u, ?_⟩
    dsimp [H]
    rw [show (1 - X : K[X]) = (-1) * (X - 1) by ring, mul_pow]
    ring
  have hH : H = 0 := hsparse H (p + 1) hdiv hcard
  have hone : (1 - X : K[X]) ^ (p + 1) ≠ 0 := by
    apply pow_ne_zero
    intro he
    have hc := congrArg (fun f : K[X] => f.coeff 0) he
    simp at hc
  have hU : linePolynomial D u = 0 := (mul_eq_zero.mp hH).resolve_left hone
  intro b
  have hc := congrArg (fun f : K[X] => f.coeff b) hU
  rw [coeff_linePolynomial D u hhi] at hc
  simpa using (div_eq_zero_iff.mp hc).resolve_right (by
    exact_mod_cast Nat.factorial_ne_zero b)

/-- The finite-line uniqueness theorem in an arbitrary vector space. -/
theorem line_vanish {V : Type*} [AddCommGroup V] [Module K V]
    (hsparse : SparseRootProperty K)
    (p lo D M b0 : ℕ) (u : ℕ → V)
    (hlo : ∀ b, b < lo → u b = 0) (hhi : ∀ b, D < b → u b = 0)
    (hanchor : lo ≤ b0 ∧ b0 ≤ M)
    (hrel : LineRecurrence (K := K) p b0 M u)
    (hcount : (b0 - lo) + (D + p + 1 - M) ≤ p + 1) :
    ∀ b, u b = 0 := by
  intro b
  apply (Module.forall_dual_apply_eq_zero_iff K (u b)).mp
  intro φ
  apply scalar_line_vanish hsparse p lo D M b0 (fun c => φ (u c))
    (fun c hc => by rw [hlo c hc, map_zero])
    (fun c hc => by rw [hhi c hc, map_zero]) hanchor ?_ hcount b
  intro c hc0 hcM
  have hr := congrArg φ (hrel c hc0 hcM)
  simpa only [map_sum, map_smul, RingHom.id_apply, smul_eq_mul, map_zero] using hr

end

end ConjectureA1
