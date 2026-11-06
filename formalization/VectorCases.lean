import SpecialCases

namespace ConjectureA1

variable {K V : Type*} [Field K] [CharZero K] [AddCommGroup V] [Module K V]

include K in
/-- Cancellation used to pass from the integral certificates to vectors. -/
lemma vector_two_cancel (v : V) (h : v + v = 0) : v = 0 := by
  have h' : (2 : K) • v = 0 := by simpa only [two_smul] using h
  have h'' := congrArg (fun w : V => (2 : K)⁻¹ • w) h'
  simpa only [smul_smul, inv_mul_cancel₀ (by norm_num : (2 : K) ≠ 0),
    one_smul, smul_zero] using h''

/-- Complete vector-level p=q=1 case, in arbitrary dimension. -/
theorem vector_p_one_q_one (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (v : V) (hx : (X ^ 2) v = 0) (hy : (Y ^ 2) v = 0) :
    ((X + Y) ^ 5) v = 0 := by
  have h := congrArg (fun T : Module.End K V => T v)
    (two_mul_add_pow_five X Y hX hY)
  have hzero : ((2 : Module.End K V) * (X + Y) ^ 5) v = 0 := by
    simpa only [LinearMap.add_apply, Module.End.mul_apply, hx, hy,
      map_zero, add_zero] using h
  apply vector_two_cancel (K := K)
  simpa only [two_mul, LinearMap.add_apply] using hzero

/-- Complete vector-level p=1,q=0 case. -/
theorem vector_p_one_q_zero (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (v : V) (hx : (X ^ 2) v = 0) (hy : Y v = 0) :
    ((X + Y) ^ 3) v = 0 := by
  have h := congrArg (fun T : Module.End K V => T v)
    (two_mul_add_pow_three X Y hX hY)
  have hzero : ((2 : Module.End K V) * (X + Y) ^ 3) v = 0 := by
    simpa only [pow_one, LinearMap.add_apply, Module.End.mul_apply, hx, hy,
      map_zero, add_zero] using h
  apply vector_two_cancel (K := K)
  simpa only [two_mul, LinearMap.add_apply] using hzero

/-- Complete vector-level p=0,q=1 case, with commutator sign handled explicitly. -/
theorem vector_p_zero_q_one (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (v : V) (hx : X v = 0) (hy : (Y ^ 2) v = 0) :
    ((X + Y) ^ 3) v = 0 := by
  have hX' : Commute Y (ad Y X) := by rw [ad_swap]; exact hY.neg_right
  have hY' : Commute X (ad Y X) := by rw [ad_swap]; exact hX.neg_right
  simpa only [add_comm] using vector_p_one_q_zero Y X hX' hY' v hy hx

omit [CharZero K] in
/-- Boundary p=q=0; this case needs no commutator assumptions. -/
theorem vector_p_zero_q_zero (X Y : Module.End K V)
    (v : V) (hx : X v = 0) (hy : Y v = 0) :
    ((X + Y) ^ 1) v = 0 := by
  simp only [pow_one, LinearMap.add_apply, hx, hy, add_zero]

/-- The frozen target for every p,q ≤ 1, uniformly over characteristic-zero fields. -/
theorem vector_parameters_le_one (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (p q : ℕ) (hp : p ≤ 1) (hq : q ≤ 1)
    (v : V) (hx : (X ^ (p + 1)) v = 0) (hy : (Y ^ (q + 1)) v = 0) :
    ((X + Y) ^ (2 * p + 2 * q + 1)) v = 0 := by
  rcases Nat.le_one_iff_eq_zero_or_eq_one.mp hp with rfl | rfl <;>
    rcases Nat.le_one_iff_eq_zero_or_eq_one.mp hq with rfl | rfl
  · exact vector_p_zero_q_zero X Y v (by simpa using hx) (by simpa using hy)
  · exact vector_p_zero_q_one X Y hX hY v (by simpa using hx) hy
  · exact vector_p_one_q_zero X Y hX hY v hx (by simpa using hy)
  · exact vector_p_one_q_one X Y hX hY v hx hy

end ConjectureA1
