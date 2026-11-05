import Lake
open Lake DSL

package «conjectureA1» where
  -- Lean 4 + Mathlib project for `ConjectureA1.lean`.
  -- The toolchain pin below must be replaced by the version required by the
  -- Mathlib revision you check out (`lake exe cache get` will tell you).

require mathlib from git
  "https://github.com/leanprover-community/mathlib4"

@[default_target]
lean_lib «ConjectureA1» where
  roots := #[`ConjectureA1]
