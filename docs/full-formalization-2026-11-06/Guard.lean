import General

/-!
Independent contract checks for the full Conjecture A.1 root.
The field and vector-space universes are deliberately independent.
The expected statements use the raw commutator, not the project's `ad`.
-/

universe u v

namespace FullContractAudit

theorem definition_matches_raw
    (K : Type u) (V : Type v) [Field K] [CharZero K]
    [AddCommGroup V] [Module K V] :
    ConjectureA1.VectorConjecture K V =
      (∀ (X Y : Module.End K V),
        Commute X (X * Y - Y * X) →
        Commute Y (X * Y - Y * X) →
        ∀ (p q : ℕ) (w : V),
          (X ^ (p + 1)) w = 0 →
          (Y ^ (q + 1)) w = 0 →
          ((X + Y) ^ (2 * p + 2 * q + 1)) w = 0) := rfl

theorem general_has_exact_type :
    ∀ {K : Type u} {V : Type v} [Field K] [CharZero K]
      [AddCommGroup V] [Module K V] (X Y : Module.End K V),
      Commute X (X * Y - Y * X) →
      Commute Y (X * Y - Y * X) →
      ∀ (p q : ℕ) (w : V),
        (X ^ (p + 1)) w = 0 →
        (Y ^ (q + 1)) w = 0 →
        ((X + Y) ^ (2 * p + 2 * q + 1)) w = 0 :=
  @ConjectureA1.vector_general.{u, v}

theorem conjecture_has_full_polymorphic_type :
    ∀ (K : Type u) (V : Type v) [Field K] [CharZero K]
      [AddCommGroup V] [Module K V],
      ConjectureA1.VectorConjecture K V :=
  @ConjectureA1.vector_conjecture.{u, v}

theorem conjecture_has_raw_type :
    ∀ (K : Type u) (V : Type v) [Field K] [CharZero K]
      [AddCommGroup V] [Module K V] (X Y : Module.End K V),
      Commute X (X * Y - Y * X) →
      Commute Y (X * Y - Y * X) →
      ∀ (p q : ℕ) (w : V),
        (X ^ (p + 1)) w = 0 →
        (Y ^ (q + 1)) w = 0 →
        ((X + Y) ^ (2 * p + 2 * q + 1)) w = 0 :=
  @ConjectureA1.vector_conjecture.{u, v}

theorem cutoff_has_raw_type :
    ∀ {K : Type u} {V : Type v} [Field K] [CharZero K]
      [AddCommGroup V] [Module K V] (X Y : Module.End K V),
      Commute X (X * Y - Y * X) →
      Commute Y (X * Y - Y * X) →
      ∀ (p q : ℕ) (w : V),
        (X ^ (p + 1)) w = 0 →
        (Y ^ (q + 1)) w = 0 →
        ∀ (a b k : ℕ), a + b + 2 * k = 2 * p + 2 * q + 1 →
          ((X * Y - Y * X) ^ k) ((X ^ a) ((Y ^ b) w)) = 0 :=
  @ConjectureA1.vector_monomial_cutoff.{u, v}

/-- The original form with an explicitly quantified third operator follows
without adding a premise beyond its defining commutator equality. -/
theorem original_three_operator_form
    (K : Type u) (V : Type v) [Field K] [CharZero K]
    [AddCommGroup V] [Module K V]
    (X Y Z : Module.End K V) (hZ : Z = X * Y - Y * X)
    (hX : X * Z - Z * X = 0) (hY : Y * Z - Z * Y = 0)
    (p q : ℕ) (w : V)
    (hx : (X ^ (p + 1)) w = 0) (hy : (Y ^ (q + 1)) w = 0) :
    ((X + Y) ^ (2 * p + 2 * q + 1)) w = 0 := by
  subst Z
  exact general_has_exact_type X Y (sub_eq_zero.mp hX) (sub_eq_zero.mp hY) p q w hx hy

end FullContractAudit

set_option pp.universes true

#print ConjectureA1.VectorConjecture
#check @ConjectureA1.vector_general
#print ConjectureA1.vector_conjecture
#check @ConjectureA1.vector_monomial_cutoff
#check @ConjectureA1.sparseRootProperty
#check @ConjectureA1.scalar_line_vanish
#check @ConjectureA1.line_vanish

#print axioms ConjectureA1.vector_conjecture
#print axioms ConjectureA1.vector_general
#print axioms ConjectureA1.vector_monomial_cutoff
#print axioms ConjectureA1.sparseRootProperty
#print axioms ConjectureA1.scalar_line_vanish
#print axioms ConjectureA1.line_vanish
#print axioms ConjectureA1.mono_left_line_relation
#print axioms ConjectureA1.weighted_monomial_vanish_of_line
#print axioms ConjectureA1.weighted_iterate_vanish
#print axioms FullContractAudit.original_three_operator_form
