import LineRecurrence
import Lean.Elab.Tactic.Omega

open scoped BigOperators

namespace ConjectureA1

section IndexAssembly
variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]

/-- The finite-line kernel consumed by the operator assembly. -/
def LineVanishing : Prop :=
  ∀ (p lo D M b0 : ℕ) (u : ℕ → V),
    (∀ b, b < lo → u b = 0) → (∀ b, D < b → u b = 0) →
    lo ≤ b0 → b0 ≤ M → LineRecurrence (K := K) p b0 M u →
    (b0 - lo) + (D + p + 1 - M) ≤ p + 1 → ∀ b, u b = 0

lemma pow_apply_zero_of_le (Y : Module.End K V) (v : V) (n m : ℕ)
    (hn : (Y ^ n) v = 0) (hm : n ≤ m) : (Y ^ m) v = 0 := by
  obtain ⟨r, hr⟩ := Nat.exists_eq_add_of_le hm
  have hmr : m = r + n := by omega
  rw [hmr, pow_add, Module.End.mul_apply, hn, map_zero]

/-- Pure weighted induction: a degree-one action and vanishing at one weight suffice. -/
lemma weighted_iterate_vanish (T : Module.End K V) (w : ℕ → ℕ → ℕ → V) (N : ℕ)
    (hzero : ∀ a b k, a + b + 2 * k = N → w a b k = 0)
    (hstep : ∀ a b k, T (w a b k) =
      w (a + 1) b k + w a (b + 1) k - (a : K) • w (a - 1) b (k + 1))
    (n a b k : ℕ) (hweight : n + a + b + 2 * k = N) :
    (T ^ n) (w a b k) = 0 := by
  induction n generalizing a b k with
  | zero =>
    simp only [pow_zero, Module.End.one_apply]
    exact hzero a b k (by omega)
  | succ n ih =>
    rw [pow_succ, Module.End.mul_apply, hstep, map_sub, map_add, map_smul,
      ih (a + 1) b k (by omega), ih a (b + 1) k (by omega)]
    cases a with
    | zero => simp
    | succ a =>
      rw [show a + 1 - 1 = a by omega, ih a b (k + 1) (by omega)]
      simp

/-- The line argument, expressed entirely with nonnegative indices. The two supplied
facts are separately discharged by the sparse-root kernel and the actual operator relation. -/
lemma weighted_monomial_vanish_of_line
    (X Y : Module.End K V) (v : V) (p q : ℕ)
    (hy : (Y ^ (q + 1)) v = 0)
    (hvanish : LineVanishing (K := K) (V := V))
    (hline : ∀ A B k, p + 1 ≤ A →
      ∑ j ∈ Finset.range (p + 2), lineCoeff K p B j •
        (((ad X Y) ^ (k + j)) ((X ^ (A - j)) ((Y ^ (B - j)) v))) = 0)
    (A B k : ℕ) (hw : A + B + 2 * k = 2 * p + 2 * q + 1) :
    ((ad X Y) ^ k) ((X ^ A) ((Y ^ B) v)) = 0 := by
  classical
  by_cases hB : q < B
  · rw [pow_apply_zero_of_le Y v (q + 1) B hy (by omega), map_zero, map_zero]
  have hBq : B ≤ q := by omega
  by_cases hAB : B ≤ A
  · let d := A - B
    let M := B + k
    have hAd : A = B + d := by dsimp [d]; omega
    have hN : 2 * M + d = 2 * p + 2 * q + 1 := by dsimp [M, d]; omega
    have hd : 0 < d := by omega
    let u : ℕ → V := fun b => if b ≤ M then
      ((ad X Y) ^ (M - b)) ((X ^ (b + d)) ((Y ^ b) v)) else 0
    have hlo : ∀ b, b < 0 → u b = 0 := by intro b hb; omega
    have hhi : ∀ b, min M q < b → u b = 0 := by
      intro b hb
      dsimp only [u]
      split_ifs with hbM
      · have hqb : q < b := by
          by_contra hn
          have := Nat.le_min.mpr ⟨hbM, (show b ≤ q by omega)⟩
          omega
        rw [pow_apply_zero_of_le Y v (q + 1) b hy (by omega), map_zero, map_zero]
      · rfl
    have hanchor : p + 1 - d ≤ M := by omega
    have hrel : LineRecurrence (K := K) p (p + 1 - d) M u := by
      intro b hb0 hbM
      have hA : p + 1 ≤ b + d := by omega
      have h := hline (b + d) b (M - b) hA
      convert h using 1
      apply Finset.sum_congr rfl
      intro j hj
      by_cases hjb : j ≤ b
      · have heX : b + d - j = b - j + d := by omega
        have heZ : M - b + j = M - (b - j) := by omega
        simp only [u, if_pos (show b - j ≤ M by omega), heX, heZ]
      · have he : lineCoeff K p b j = 0 := by
          unfold lineCoeff
          rw [Nat.descFactorial_eq_zero_iff_lt.mpr (by omega : b < j)]
          simp
        simp only [he, zero_smul]
    have hcount : (p + 1 - d - 0) + (min M q + p + 1 - M) ≤ p + 1 := by
      by_cases hd' : p + 1 ≤ d
      · have hmin := min_le_left M q
        omega
      · have hMq : q ≤ M := by omega
        rw [min_eq_right hMq]
        omega
    have hu := hvanish p 0 (min M q) M (p + 1 - d) u hlo hhi
      (Nat.zero_le _) hanchor hrel hcount B
    have hBM : B ≤ M := by dsimp [M]; omega
    have hMk : M - B = k := by dsimp [M]; omega
    simpa only [u, if_pos hBM, hMk, ← hAd] using hu
  · let r := B - A
    let M := B + k
    have hr : 0 < r := by dsimp [r]; omega
    have hrB : r ≤ B := by dsimp [r]; omega
    have hrq : r ≤ q := by omega
    have hAr : B - r = A := by dsimp [r]; omega
    have hN : 2 * M = 2 * p + 2 * q + 1 + r := by dsimp [M, r]; omega
    have hM : p + q + 1 ≤ M := by omega
    have hanchor : p + 1 + r ≤ M := by omega
    let u : ℕ → V := fun b => if r ≤ b ∧ b ≤ M then
      ((ad X Y) ^ (M - b)) ((X ^ (b - r)) ((Y ^ b) v)) else 0
    have hlo : ∀ b, b < r → u b = 0 := by
      intro b hb
      simp only [u, if_neg (show ¬ (r ≤ b ∧ b ≤ M) by omega)]
    have hhi : ∀ b, q < b → u b = 0 := by
      intro b hb
      dsimp only [u]
      split_ifs
      · rw [pow_apply_zero_of_le Y v (q + 1) b hy (by omega), map_zero, map_zero]
      · rfl
    have hrel : LineRecurrence (K := K) p (p + 1 + r) M u := by
      intro b hb0 hbM
      have hA : p + 1 ≤ b - r := by omega
      have h := hline (b - r) b (M - b) hA
      convert h using 1
      apply Finset.sum_congr rfl
      intro j hj
      have hjp : j ≤ p + 1 := by have := Finset.mem_range.mp hj; omega
      have hjb : j ≤ b := by omega
      have heX : b - r - j = b - j - r := by omega
      have heZ : M - b + j = M - (b - j) := by omega
      simp only [u, if_pos (show r ≤ b - j ∧ b - j ≤ M by omega), heX, heZ]
    have hcount : (p + 1 + r - r) + (q + p + 1 - M) ≤ p + 1 := by omega
    have hBM : B ≤ M := by dsimp [M]; omega
    have hMk : M - B = k := by dsimp [M]; omega
    have hu := hvanish p r q M (p + 1 + r) u hlo hhi
      (by omega) hanchor hrel hcount B
    simpa only [u, if_pos (show r ≤ B ∧ B ≤ M from ⟨hrB, hBM⟩), hMk, hAr] using hu

end IndexAssembly
end ConjectureA1
