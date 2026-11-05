import VectorCases
import Lean.Elab.Tactic.Omega

namespace ConjectureA1

variable {K V : Type*} [Field K] [CharZero K] [AddCommGroup V] [Module K V]

include K in
/-- A positive natural coefficient can be cancelled on a characteristic-zero vector space. -/
lemma vector_nat_cancel (n : ℕ) (hn : n ≠ 0) (v : V) (h : n • v = 0) : v = 0 := by
  have hn' : (n : K) ≠ 0 := Nat.cast_ne_zero.mpr hn
  have h' : (n : K) • v = 0 := by simpa only [Nat.cast_smul_eq_nsmul] using h
  have h'' := congrArg (fun w : V => (n : K)⁻¹ • w) h'
  simpa only [smul_smul, inv_mul_cancel₀ hn', one_smul, smul_zero] using h''

omit [CharZero K] in
/-- On a vector killed by X, X differentiates the Y part of a normal monomial. -/
lemma boundary_x_action (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (v : V) (hv : X v = 0) (a b : ℕ) :
    X (((ad X Y) ^ a) ((Y ^ (b + 1)) v)) =
      (b + 1) • (((ad X Y) ^ (a + 1)) ((Y ^ b) v)) := by
  have hmove := congrArg (fun T : Module.End K V => T ((Y ^ (b + 1)) v))
    (hX.pow_right a).eq
  have hnormal := congrArg (fun T : Module.End K V => T v)
    (mul_pow_normal_order X Y hY b)
  have hYZ := (hY.pow_left b).eq
  simp only [Module.End.mul_apply] at hmove
  rw [hmove]
  simp only [Module.End.mul_apply, LinearMap.add_apply, LinearMap.smul_apply,
    hv, map_zero, zero_add] at hnormal
  rw [hnormal, map_nsmul]
  congr 1
  have hcomm := congrArg (fun T : Module.End K V => T v) hYZ
  simp only [Module.End.mul_apply] at hcomm
  rw [hcomm]
  simp only [pow_succ, Module.End.mul_apply]

/-- The boundary cyclic module has no monomials Z^a Y^b v of total degree above q. -/
lemma boundary_monomial_vanish (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (v : V) (hx : X v = 0) (q : ℕ) (hy : (Y ^ (q + 1)) v = 0)
    (a b : ℕ) (hdegree : q < a + b) :
    ((ad X Y) ^ a) ((Y ^ b) v) = 0 := by
  induction a generalizing b with
  | zero =>
    obtain ⟨r, hr⟩ := Nat.exists_eq_add_of_le (show q + 1 ≤ b by omega)
    have hb : b = r + (q + 1) := by omega
    rw [hb, pow_add]
    simp only [pow_zero, Module.End.mul_apply, hy, map_zero]
  | succ a ih =>
    have hprev := ih (b + 1) (by omega)
    have hdiff := congrArg X hprev
    rw [boundary_x_action X Y hX hY v hx a b, map_zero] at hdiff
    exact vector_nat_cancel (K := K) (b + 1) (by omega) _ hdiff

omit [CharZero K] in
/-- Left multiplication by X+Y raises the weight 2a+b by one. -/
lemma boundary_add_action (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (v : V) (hv : X v = 0) (a b : ℕ) :
    (X + Y) (((ad X Y) ^ a) ((Y ^ b) v)) =
      ((ad X Y) ^ a) ((Y ^ (b + 1)) v) +
        b • (((ad X Y) ^ (a + 1)) ((Y ^ (b - 1)) v)) := by
  have hmoveY := congrArg (fun T : Module.End K V => T ((Y ^ b) v))
    (hY.pow_right a).eq
  simp only [Module.End.mul_apply] at hmoveY
  cases b with
  | zero =>
    have hmoveX := congrArg (fun T : Module.End K V => T v) (hX.pow_right a).eq
    simp only [Module.End.mul_apply] at hmoveX
    simp only [pow_zero, Module.End.one_apply, LinearMap.add_apply, zero_nsmul,
      add_zero]
    rw [hmoveX, hv, map_zero, zero_add]
    simpa using hmoveY
  | succ b =>
    rw [LinearMap.add_apply, boundary_x_action X Y hX hY v hv a b, hmoveY]
    rw [show b + 1 + 1 = (b + 1) + 1 by omega, pow_succ' Y (b + 1)]
    simp only [Module.End.mul_apply, Nat.add_sub_cancel]
    exact add_comm _ _

/-- All sufficiently high weighted monomials in the boundary cyclic module vanish.
The result also controls arbitrary further powers of X+Y, without a PBW construction. -/
lemma boundary_weighted_vanish (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (v : V) (hx : X v = 0) (q : ℕ) (hy : (Y ^ (q + 1)) v = 0)
    (n a b : ℕ) (hweight : 2 * q < n + 2 * a + b) :
    ((X + Y) ^ n) (((ad X Y) ^ a) ((Y ^ b) v)) = 0 := by
  induction n generalizing a b with
  | zero =>
    simp only [pow_zero, Module.End.one_apply]
    exact boundary_monomial_vanish X Y hX hY v hx q hy a b (by omega)
  | succ n ih =>
    rw [pow_succ (X + Y) n, Module.End.mul_apply,
      boundary_add_action X Y hX hY v hx a b, map_add, map_nsmul,
      ih a (b + 1) (by omega)]
    cases b with
    | zero => simp only [zero_nsmul, add_zero]
    | succ b =>
      rw [show b + 1 - 1 = b by omega, ih (a + 1) b (by omega)]
      simp only [smul_zero, add_zero]

/-- The full p=0 family of Conjecture A.1, for every natural q. -/
theorem vector_p_zero (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (q : ℕ) (v : V) (hx : X v = 0) (hy : (Y ^ (q + 1)) v = 0) :
    ((X + Y) ^ (2 * q + 1)) v = 0 := by
  have h := boundary_weighted_vanish X Y hX hY v hx q hy (2 * q + 1) 0 0 (by omega)
  simpa only [pow_zero, Module.End.one_apply] using h

/-- The symmetric full q=0 family, for every natural p. -/
theorem vector_q_zero (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (p : ℕ) (v : V) (hx : (X ^ (p + 1)) v = 0) (hy : Y v = 0) :
    ((X + Y) ^ (2 * p + 1)) v = 0 := by
  have hX' : Commute Y (ad Y X) := by rw [ad_swap]; exact hY.neg_right
  have hY' : Commute X (ad Y X) := by rw [ad_swap]; exact hX.neg_right
  simpa only [add_comm] using vector_p_zero Y X hX' hY' p v hy hx

/-- The exact frozen exponent whenever p=0, q=0, or both parameters are at most one. -/
theorem vector_boundary_or_le_one (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (p q : ℕ) (hcase : p = 0 ∨ q = 0 ∨ (p ≤ 1 ∧ q ≤ 1))
    (v : V) (hx : (X ^ (p + 1)) v = 0) (hy : (Y ^ (q + 1)) v = 0) :
    ((X + Y) ^ (2 * p + 2 * q + 1)) v = 0 := by
  rcases hcase with rfl | rfl | ⟨hp, hq⟩
  · simpa only [Nat.mul_zero, Nat.zero_add] using
      vector_p_zero X Y hX hY q v (by simpa using hx) hy
  · simpa only [Nat.mul_zero, Nat.add_zero] using
      vector_q_zero X Y hX hY p v hx (by simpa using hy)
  · exact vector_parameters_le_one X Y hX hY p q hp hq v hx hy

end ConjectureA1
