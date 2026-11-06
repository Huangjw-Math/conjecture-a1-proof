import BoundaryCases
import NormalOrder

open scoped BigOperators

universe u v

-- Independent interface checks use the raw commutator, not the project's alias.
#check (@ConjectureA1.VectorConjecture.{u, v} :
  (K : Type u) → (V : Type v) →
    [Field K] → [CharZero K] → [AddCommGroup V] → [Module K V] → Prop)

example (K : Type u) (V : Type v)
    [Field K] [CharZero K] [AddCommGroup V] [Module K V] :
    ConjectureA1.VectorConjecture K V =
      (∀ (X Y : Module.End K V),
        Commute X (X * Y - Y * X) → Commute Y (X * Y - Y * X) →
        ∀ (p q : ℕ) (w : V),
          (X ^ (p + 1)) w = 0 → (Y ^ (q + 1)) w = 0 →
          ((X + Y) ^ (2 * p + 2 * q + 1)) w = 0) := rfl

#check (@ConjectureA1.vector_p_zero.{u, v} :
  ∀ {K : Type u} {V : Type v}
    [Field K] [CharZero K] [AddCommGroup V] [Module K V]
    (X Y : Module.End K V),
    Commute X (X * Y - Y * X) → Commute Y (X * Y - Y * X) →
    ∀ (q : ℕ) (w : V), X w = 0 → (Y ^ (q + 1)) w = 0 →
      ((X + Y) ^ (2 * q + 1)) w = 0)

#check (@ConjectureA1.vector_q_zero.{u, v} :
  ∀ {K : Type u} {V : Type v}
    [Field K] [CharZero K] [AddCommGroup V] [Module K V]
    (X Y : Module.End K V),
    Commute X (X * Y - Y * X) → Commute Y (X * Y - Y * X) →
    ∀ (p : ℕ) (w : V), (X ^ (p + 1)) w = 0 → Y w = 0 →
      ((X + Y) ^ (2 * p + 1)) w = 0)

#check (@ConjectureA1.vector_boundary_or_le_one.{u, v} :
  ∀ {K : Type u} {V : Type v}
    [Field K] [CharZero K] [AddCommGroup V] [Module K V]
    (X Y : Module.End K V),
    Commute X (X * Y - Y * X) → Commute Y (X * Y - Y * X) →
    ∀ (p q : ℕ), (p = 0 ∨ q = 0 ∨ (p ≤ 1 ∧ q ≤ 1)) →
    ∀ (w : V), (X ^ (p + 1)) w = 0 → (Y ^ (q + 1)) w = 0 →
      ((X + Y) ^ (2 * p + 2 * q + 1)) w = 0)

#check (@ConjectureA1.vector_p_one_q_one.{u, v} :
  ∀ {K : Type u} {V : Type v}
    [Field K] [CharZero K] [AddCommGroup V] [Module K V]
    (X Y : Module.End K V),
    Commute X (X * Y - Y * X) → Commute Y (X * Y - Y * X) →
    ∀ (w : V), (X ^ 2) w = 0 → (Y ^ 2) w = 0 →
      ((X + Y) ^ 5) w = 0)

-- No characteristic-zero, Y-annihilation, or extraneous ambient-ring binder.
#check (@ConjectureA1.vector_right_line_relation.{u, v} :
  ∀ {K : Type u} {V : Type v}
    [Field K] [AddCommGroup V] [Module K V]
    (X Y : Module.End K V),
    Commute X (X * Y - Y * X) → Commute Y (X * Y - Y * X) →
    ∀ (p B : ℕ) (w : V), (X ^ (p + 1)) w = 0 →
      (∑ j ∈ Finset.range (B + 1),
        (B.descFactorial j * (p + 1).choose j) •
          (X ^ (p + 1 - j) * (-(X * Y - Y * X)) ^ j * Y ^ (B - j))) w = 0)

#print axioms ConjectureA1.vector_p_zero
#print axioms ConjectureA1.vector_q_zero
#print axioms ConjectureA1.vector_boundary_or_le_one
#print axioms ConjectureA1.vector_p_one_q_one
#print axioms ConjectureA1.vector_right_line_relation
