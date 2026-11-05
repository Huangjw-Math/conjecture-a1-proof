import Lake
open Lake DSL

package «conjectureA1» where
  -- Lean 4 + Mathlib project for `ConjectureA1.lean`.
  -- Reproducible online dependency; offline cached checking is documented in PROGRESS.md.

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "fabf563a7c95a166b8d7b6efca11c8b4dc9d911f"

@[default_target]
lean_lib «ConjectureA1» where
  roots := #[`ConjectureA1, `SpecialCases, `VectorCases, `BoundaryCases, `NormalOrder, `AxiomAudit]
