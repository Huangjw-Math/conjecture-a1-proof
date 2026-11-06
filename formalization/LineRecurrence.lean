import ConjectureA1
import Mathlib.Algebra.Polynomial.Basic

open scoped BigOperators

namespace ConjectureA1

/-- A scalar uniqueness property at the nonzero point 1; proved from CharZero in Fewnomial. -/
def SparseRootProperty (K : Type*) [Field K] : Prop :=
  ∀ (f : Polynomial K) (m : ℕ),
    (Polynomial.X - 1) ^ m ∣ f → f.support.card ≤ m → f = 0

/-- Coefficients of the genuine right-annihilator relation. -/
def lineCoeff (K : Type*) [Field K] (p b j : ℕ) : K :=
  (-1 : K) ^ j * (b.descFactorial j : K) * ((p + 1).choose j : K)

/-- A finite interval of line relations; values at negative indices have zero coefficient. -/
def LineRecurrence {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    (p b0 M : ℕ) (u : ℕ → V) : Prop :=
  ∀ b, b0 ≤ b → b ≤ M →
    ∑ j ∈ Finset.range (p + 2), lineCoeff K p b j • u (b - j) = 0

end ConjectureA1
