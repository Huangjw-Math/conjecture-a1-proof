import Fewnomial
import LineSystem
import MonomialActions
import WeightedLines

namespace ConjectureA1

variable {K V : Type*} [Field K] [CharZero K] [AddCommGroup V] [Module K V]

/-- Every ordered monomial at the conjectured cutoff weight kills the vector. -/
theorem vector_monomial_cutoff (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (p q : ℕ) (v : V) (hx : (X ^ (p + 1)) v = 0) (hy : (Y ^ (q + 1)) v = 0)
    (a b k : ℕ) (hw : a + b + 2 * k = 2 * p + 2 * q + 1) :
    mono X Y a b k v = 0 := by
  have hkernel : LineVanishing (K := K) (V := V) := by
    intro p lo D M b0 u hlo hhi hlow hhigh hrel hcount
    exact line_vanish (sparseRootProperty K) p lo D M b0 u hlo hhi
      ⟨hlow, hhigh⟩ hrel hcount
  apply weighted_monomial_vanish_of_line X Y v p q hy hkernel ?_ a b k hw
  intro A B k hA
  exact mono_left_line_relation X Y hX hY p A B k v hA hx

/-- Conjecture A.1 in its original hypotheses, for all natural parameters. -/
theorem vector_general (X Y : Module.End K V)
    (hX : Commute X (ad X Y)) (hY : Commute Y (ad X Y))
    (p q : ℕ) (v : V) (hx : (X ^ (p + 1)) v = 0) (hy : (Y ^ (q + 1)) v = 0) :
    ((X + Y) ^ (2 * p + 2 * q + 1)) v = 0 := by
  have hz := weighted_iterate_vanish (X + Y) (fun a b k => mono X Y a b k v)
    (2 * p + 2 * q + 1)
    (fun a b k hw => vector_monomial_cutoff X Y hX hY p q v hx hy a b k hw)
    (fun a b k => add_apply_mono X Y hX hY a b k v)
    (2 * p + 2 * q + 1) 0 0 0 (by omega)
  simpa only [mono, pow_zero, Module.End.one_apply] using hz

/-- The full, universe-polymorphic original conjecture is proved. -/
theorem vector_conjecture (K V : Type*) [Field K] [CharZero K]
    [AddCommGroup V] [Module K V] : VectorConjecture K V := by
  intro X Y hX hY p q v hx hy
  exact vector_general X Y hX hY p q v hx hy

end ConjectureA1
