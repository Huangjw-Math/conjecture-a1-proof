import ConjectureA1

open Finset
open scoped BigOperators

namespace ConjectureA1

variable {R : Type*} [Ring R]

/-- The inner derivation as an additive endomorphism; it is not assumed nilpotent. -/
def innerEnd (x : R) : AddMonoid.End R :=
  AddMonoid.End.mulLeft x - AddMonoid.End.mulRight x

@[simp] lemma innerEnd_apply (x w : R) : innerEnd x w = ad x w := rfl

lemma mulLeft_pow_apply (x w : R) (n : ℕ) :
    ((AddMonoid.End.mulLeft x) ^ n) w = x ^ n * w := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [pow_succ']
    change x * (((AddMonoid.End.mulLeft x) ^ n) w) = x ^ (n + 1) * w
    rw [ih, pow_succ', mul_assoc]

lemma mulRight_pow_apply (x w : R) (n : ℕ) :
    ((AddMonoid.End.mulRight x) ^ n) w = w * x ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [pow_succ']
    change (((AddMonoid.End.mulRight x) ^ n) w) * x = w * x ^ (n + 1)
    rw [ih, pow_succ, mul_assoc]

lemma innerEnd_commute_right (x : R) :
    Commute (innerEnd x) (AddMonoid.End.mulRight x) := by
  apply Commute.sub_left
  · apply AddMonoidHom.ext
    intro w
    exact (mul_assoc x w x).symm
  · exact Commute.refl _

/-- General commutator Taylor formula in every ring, without any commutation hypotheses. -/
lemma taylor (x w : R) (n : ℕ) :
    x ^ n * w = ∑ j ∈ range (n + 1),
      n.choose j • (((ad x)^[j] w) * x ^ (n - j)) := by
  have hcomm := innerEnd_commute_right x
  have hsum : innerEnd x + AddMonoid.End.mulRight x = AddMonoid.End.mulLeft x :=
    sub_add_cancel _ _
  let ev : AddMonoid.End R →+ R :=
    { toFun := fun f => f w, map_zero' := rfl, map_add' := fun _ _ => rfl }
  have h := congrArg ev (hcomm.add_pow' n)
  rw [hsum, map_sum] at h
  change x ^ n * w = _
  rw [← mulLeft_pow_apply x w n]
  change ev ((AddMonoid.End.mulLeft x) ^ n) = _
  rw [h]
  rw [Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk]
  apply Finset.sum_congr rfl
  intro j hj
  rw [map_nsmul]
  change n.choose j • (((innerEnd x) ^ j *
    (AddMonoid.End.mulRight x) ^ (n - j)) w) = _
  rw [(hcomm.pow_pow j (n - j)).eq]
  change n.choose j • (((AddMonoid.End.mulRight x) ^ (n - j))
    (((innerEnd x) ^ j) w)) = _
  rw [mulRight_pow_apply, AddMonoid.End.coe_pow]
  rfl

lemma ad_nsmul (x w : R) (n : ℕ) : ad x (n • w) = n • ad x w := by
  change innerEnd x (n • w) = n • innerEnd x w
  exact map_nsmul (innerEnd x) n w

/-- Every iterated commutator on a Y-power, using only local X-Z and Y-Z commutation. -/
lemma ad_iterate_pow (x y : R)
    (hx : Commute x (ad x y)) (hy : Commute y (ad x y)) (b j : ℕ) :
    (ad x)^[j] (y ^ b) = b.descFactorial j • (y ^ (b - j) * (ad x y) ^ j) := by
  induction j with
  | zero => simp
  | succ j ih =>
    rw [Function.iterate_succ_apply', ih, ad_nsmul, ad_mul,
      show ad x ((ad x y) ^ j) = 0 from sub_eq_zero.mpr (hx.pow_right j).eq,
      mul_zero, add_zero, ad_pow_eq x y hy (b - j), smul_mul_assoc,
      smul_smul, Nat.descFactorial_succ]
    rw [Nat.mul_comm (b - j) (b.descFactorial j)]
    congr 1
    rw [Nat.sub_sub, mul_assoc, ← pow_succ']

/-- Arbitrary-power normal ordering. Terms with j>b automatically have zero coefficient. -/
lemma normal_order (x y : R)
    (hx : Commute x (ad x y)) (hy : Commute y (ad x y)) (a b : ℕ) :
    x ^ a * y ^ b = ∑ j ∈ range (a + 1),
      (a.choose j * b.descFactorial j) •
        (y ^ (b - j) * (ad x y) ^ j * x ^ (a - j)) := by
  rw [taylor]
  apply Finset.sum_congr rfl
  intro j hj
  rw [ad_iterate_pow x y hx hy, smul_mul_assoc, smul_smul]

/-- The right-annihilator line relation, valid for arbitrary parameters and vectors.
The sign is kept as a power of -Z; no two-sided ideal or operator-nilpotence assumption occurs. -/
lemma vector_right_line_relation {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (p B : ℕ) (v : V) (hx : (X ^ (p + 1)) v = 0) :
    (∑ j ∈ range (B + 1), (B.descFactorial j * (p + 1).choose j) •
      (X ^ (p + 1 - j) * (-ad X Y) ^ j * Y ^ (B - j))) v = 0 := by
  have hX' : Commute Y (ad Y X) := by rw [ad_swap]; exact hY.neg_right
  have hY' : Commute X (ad Y X) := by rw [ad_swap]; exact hX.neg_right
  have hnormal := normal_order Y X hX' hY' B (p + 1)
  rw [ad_swap] at hnormal
  have hcoeff : ∀ j, B.choose j * (p + 1).descFactorial j =
      B.descFactorial j * (p + 1).choose j := by
    intro j
    simp only [Nat.descFactorial_eq_factorial_mul_choose]
    ac_rfl
  simp_rw [hcoeff] at hnormal
  rw [← hnormal, Module.End.mul_apply, hx, map_zero]

end ConjectureA1
