import BoundaryCases
import General

/- Read actual elaborated types, including legacy dropped typeclasses. -/
#print ConjectureA1.ConjectureA1
#print ConjectureA1.VectorConjecture
#check (@ConjectureA1.VectorConjecture :
  (K V : Type) → [Field K] → [CharZero K] → [AddCommGroup V] → [Module K V] → Prop)
#check @ConjectureA1.vector_two_cancel
#check @ConjectureA1.vector_p_one_q_one
#check @ConjectureA1.vector_p_one_q_zero
#check @ConjectureA1.vector_p_zero_q_one
#check @ConjectureA1.vector_p_zero_q_zero
#check @ConjectureA1.vector_parameters_le_one
#check @ConjectureA1.ad_pow_of_commute
#check @ConjectureA1.ad_pow_eq
#check @ConjectureA1.mul_pow_normal_order
#check @ConjectureA1.pow_mul_normal_order

#print axioms ConjectureA1.ad_def
#print axioms ConjectureA1.ad_add
#print axioms ConjectureA1.ad_zero
#print axioms ConjectureA1.ad_neg
#print axioms ConjectureA1.ad_one
#print axioms ConjectureA1.ad_mul
#print axioms ConjectureA1.ad_pow_succ
#print axioms ConjectureA1.ad_swap
#print axioms ConjectureA1.ad_pow_of_commute
#print axioms ConjectureA1.mul_pow_normal_order
#print axioms ConjectureA1.ad_pow_eq
#print axioms ConjectureA1.pow_mul_normal_order
#print axioms ConjectureA1.two_mul_add_pow_five
#print axioms ConjectureA1.two_mul_add_pow_three
#print axioms ConjectureA1.vector_two_cancel
#print axioms ConjectureA1.vector_p_one_q_one
#print axioms ConjectureA1.vector_p_one_q_zero
#print axioms ConjectureA1.vector_p_zero_q_one
#print axioms ConjectureA1.vector_p_zero_q_zero
#print axioms ConjectureA1.vector_parameters_le_one

/- New arbitrary-parameter helpers and boundary families. -/
#check @ConjectureA1.vector_nat_cancel
#check @ConjectureA1.boundary_x_action
#check @ConjectureA1.boundary_monomial_vanish
#check @ConjectureA1.boundary_add_action
#check @ConjectureA1.boundary_weighted_vanish
#check @ConjectureA1.vector_p_zero
#check @ConjectureA1.vector_q_zero
#check @ConjectureA1.vector_boundary_or_le_one
#check @ConjectureA1.innerEnd_apply
#check @ConjectureA1.mulLeft_pow_apply
#check @ConjectureA1.mulRight_pow_apply
#check @ConjectureA1.innerEnd_commute_right
#check @ConjectureA1.taylor
#check @ConjectureA1.ad_nsmul
#check @ConjectureA1.ad_iterate_pow
#check @ConjectureA1.normal_order
#check @ConjectureA1.vector_right_line_relation

#print axioms ConjectureA1.vector_nat_cancel
#print axioms ConjectureA1.boundary_x_action
#print axioms ConjectureA1.boundary_monomial_vanish
#print axioms ConjectureA1.boundary_add_action
#print axioms ConjectureA1.boundary_weighted_vanish
#print axioms ConjectureA1.vector_p_zero
#print axioms ConjectureA1.vector_q_zero
#print axioms ConjectureA1.vector_boundary_or_le_one
#print axioms ConjectureA1.innerEnd_apply
#print axioms ConjectureA1.mulLeft_pow_apply
#print axioms ConjectureA1.mulRight_pow_apply
#print axioms ConjectureA1.innerEnd_commute_right
#print axioms ConjectureA1.taylor
#print axioms ConjectureA1.ad_nsmul
#print axioms ConjectureA1.ad_iterate_pow
#print axioms ConjectureA1.normal_order
#print axioms ConjectureA1.vector_right_line_relation

/- Signature regressions for the new infinite families. -/
#check (@ConjectureA1.vector_p_zero :
  ∀ {K V : Type} [Field K] [CharZero K] [AddCommGroup V] [Module K V]
    (X Y : Module.End K V),
    Commute X (ConjectureA1.ad X Y) → Commute Y (ConjectureA1.ad X Y) →
    ∀ (q : ℕ) (v : V), X v = 0 → (Y ^ (q + 1)) v = 0 →
      ((X + Y) ^ (2 * q + 1)) v = 0)
#check (@ConjectureA1.vector_q_zero :
  ∀ {K V : Type} [Field K] [CharZero K] [AddCommGroup V] [Module K V]
    (X Y : Module.End K V),
    Commute X (ConjectureA1.ad X Y) → Commute Y (ConjectureA1.ad X Y) →
    ∀ (p : ℕ) (v : V), (X ^ (p + 1)) v = 0 → Y v = 0 →
      ((X + Y) ^ (2 * p + 1)) v = 0)

/- Complete arbitrary-parameter proof and its newly checked dependency layer. -/
#print axioms ConjectureA1.sparseEuler_coeff
#print axioms ConjectureA1.sparseEuler_support_subset
#print axioms ConjectureA1.eq_monomial_of_sparseEuler_eq_zero
#print axioms ConjectureA1.sparseRootProperty
#print axioms ConjectureA1.coeff_linePolynomial
#print axioms ConjectureA1.one_sub_X_pow_expansion
#print axioms ConjectureA1.coeff_line_product
#print axioms ConjectureA1.factorial_mul_coeff_line_product
#print axioms ConjectureA1.support_line_product_subset
#print axioms ConjectureA1.scalar_line_vanish
#print axioms ConjectureA1.line_vanish
#print axioms ConjectureA1.neg_pow_apply
#print axioms ConjectureA1.x_apply_mono
#print axioms ConjectureA1.y_mul_x_pow
#print axioms ConjectureA1.y_apply_mono
#print axioms ConjectureA1.add_apply_mono
#print axioms ConjectureA1.sum_range_eq_of_zero
#print axioms ConjectureA1.left_apply_ordered_term
#print axioms ConjectureA1.mono_left_line_relation
#print axioms ConjectureA1.pow_apply_zero_of_le
#print axioms ConjectureA1.weighted_iterate_vanish
#print axioms ConjectureA1.weighted_monomial_vanish_of_line
#print axioms ConjectureA1.vector_monomial_cutoff
#print axioms ConjectureA1.vector_general
#print axioms ConjectureA1.vector_conjecture

#check (@ConjectureA1.vector_general :
  ∀ {K V : Type} [Field K] [CharZero K] [AddCommGroup V] [Module K V]
    (X Y : Module.End K V),
    Commute X (X * Y - Y * X) → Commute Y (X * Y - Y * X) →
    ∀ (p q : ℕ) (v : V), (X ^ (p + 1)) v = 0 → (Y ^ (q + 1)) v = 0 →
      ((X + Y) ^ (2 * p + 2 * q + 1)) v = 0)
#print ConjectureA1.vector_conjecture
#check (@ConjectureA1.vector_conjecture :
  ∀ (K V : Type) [Field K] [CharZero K] [AddCommGroup V] [Module K V],
    ConjectureA1.VectorConjecture K V)
