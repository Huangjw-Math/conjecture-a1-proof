import LineRecurrence
import Mathlib.Algebra.Polynomial.Derivative
import Mathlib.Tactic.Ring

/-!
A polynomial with at most `m` nonzero terms cannot vanish at 1 to order `m`
unless it is zero. Euler elimination removes one support index and lowers
vanishing order by at most one, so induction uses support size, not degree.
-/

namespace ConjectureA1

open Polynomial

noncomputable def sparseEuler {K : Type*} [Field K]
    (f : Polynomial K) (e : ℕ) : Polynomial K :=
  X * derivative f - C (e : K) * f

lemma sparseEuler_coeff {K : Type*} [Field K]
    (f : Polynomial K) (e n : ℕ) :
    (sparseEuler f e).coeff n = ((n : K) - (e : K)) * f.coeff n := by
  cases n with
  | zero => simp [sparseEuler, coeff_sub]
  | succ n =>
    simp only [sparseEuler, coeff_sub, coeff_X_mul, coeff_derivative, coeff_C_mul]
    push_cast
    ring

lemma sparseEuler_support_subset {K : Type*} [Field K]
    (f : Polynomial K) (e : ℕ) :
    (sparseEuler f e).support ⊆ f.support.erase e := by
  classical
  intro n hn
  rw [Finset.mem_erase]
  constructor
  · intro hne
    subst n
    exact (mem_support_iff.mp hn) (by rw [sparseEuler_coeff]; simp)
  · by_contra hnf
    have hf0 : f.coeff n = 0 := by simpa only [mem_support_iff, not_not] using hnf
    exact (mem_support_iff.mp hn) (by rw [sparseEuler_coeff, hf0, mul_zero])

lemma eq_monomial_of_sparseEuler_eq_zero {K : Type*} [Field K] [CharZero K]
    (f : Polynomial K) (e : ℕ) (h : sparseEuler f e = 0) :
    f = monomial e (f.coeff e) := by
  ext n
  by_cases hn : n = e
  · subst n
    simp
  · have hne : ((n : K) - (e : K)) ≠ 0 := sub_ne_zero.mpr (by exact_mod_cast hn)
    have hcoef := congrArg (fun p : Polynomial K => p.coeff n) h
    rw [sparseEuler_coeff, coeff_zero] at hcoef
    have hfn : f.coeff n = 0 := (mul_eq_zero.mp hcoef).resolve_left hne
    simp [coeff_monomial, Ne.symm hn, hfn]

/-- At the nonzero point 1, vanishing order is strictly smaller than the number
of nonzero coefficients of any nonzero polynomial over a characteristic-zero field. -/
theorem sparseRootProperty (K : Type*) [Field K] [CharZero K] : SparseRootProperty K := by
  classical
  intro f m
  induction m generalizing f with
  | zero =>
    intro _ hc
    exact card_support_eq_zero.mp (Nat.eq_zero_of_le_zero hc)
  | succ m ih =>
    intro hd hc
    by_cases hf : f = 0
    · exact hf
    let e := f.natDegree
    let g := sparseEuler f e
    have hgcard : g.support.card ≤ m := by
      have hs := Finset.card_le_card (sparseEuler_support_subset f e)
      have he : e ∈ f.support := natDegree_mem_support_of_nonzero hf
      rw [Finset.card_erase_of_mem he] at hs
      dsimp [g]
      omega
    have hdf : (X - 1 : Polynomial K) ^ m ∣ f :=
      dvd_trans (pow_dvd_pow _ (Nat.le_succ m)) hd
    have hder : (X - 1 : Polynomial K) ^ m ∣ derivative f := by
      simpa using pow_sub_one_dvd_derivative_of_pow_dvd hd
    have hgdvd : (X - 1 : Polynomial K) ^ m ∣ g :=
      (hder.mul_left X).sub (hdf.mul_left (C (e : K)))
    have hg : g = 0 := ih g hgdvd hgcard
    have hm : f = monomial e (f.coeff e) := eq_monomial_of_sparseEuler_eq_zero f e hg
    have hroot : f.eval 1 = 0 := by
      obtain ⟨q, hq⟩ := hd
      have hev := congrArg (Polynomial.eval (1 : K)) hq
      simpa using hev
    have he0 : f.coeff e = 0 := by
      rw [hm, eval_monomial, one_pow, mul_one] at hroot
      exact hroot
    rw [hm, he0]
    simp

end ConjectureA1
