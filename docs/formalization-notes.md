# 原猜想的完整 Lean 证明

从 `General` 导入实际根证明：

```lean
import General

example (K V : Type*) [Field K] [CharZero K]
    [AddCommGroup V] [Module K V] : ConjectureA1.VectorConjecture K V :=
  ConjectureA1.vector_conjecture K V
```

`vector_general` 是展开后的逐向量接口：任意特征零域 K、任意 K-向量空间 V，
X,Y 为线性自同态，Z=XY−YX，只要求 XZ=ZX、YZ=ZY；对全部自然 p,q 及 v，

$$
X^{p+1}v=Y^{q+1}v=0\quad\Longrightarrow\quad (X+Y)^{2p+2q+1}v=0.
$$

包含所有零参数、零向量和零空间。没有有限维性、环境中心性或算子本身幂零的额外前提。

## 从辅助命题到闭合根证明

- `sparseRootProperty`（`Fewnomial.lean`）：利用 Euler 算子消去一个支持指数，证明至多 m 项的多项式
  若被 (X−1)^m 整除则为零。特征零用于消去不同自然指数之差。
- `line_vanish`（`LineSystem.lean`）：生成多项式的精确系数与两端支持界；通过全部线性泛函升到任意向量空间。
- `mono_left_line_relation`（`MonomialActions.lean`）：把真实右湮灭关系从左锚点作用，获得固定范围的直线关系。
- `weighted_monomial_vanish_of_line`（`WeightedLines.lean`）：用非负下端点统一编码正负直线，验证全部指标和计数。
- `vector_monomial_cutoff`（`General.lean`）：由已经证明的少项式性质消除线内核的条件，得到截止次数的全部单项式消失。
- `vector_general`（`General.lean`）、`vector_conjecture`：由三项左作用作加权归纳，得到原猜想。不需要完整 PBW 构造或显式三项式展开。

`SparseRootProperty`、`LineVanishing` 是辅助接口，不是额外公理。
最终根证明实际调用它们的已证实现，不再把它们作为假设。

## 版本与证据

固定 Lean 4.31.0、Mathlib `fabf563a7c95a166b8d7b6efca11c8b4dc9d911f` 及其八个锁定依赖。
12 个 material 模块重新编译，62 个证明声明的传递公理已逐项查询，全部仅使用
`propext`、`Classical.choice`、`Quot.sound` 的子集。详见
[完整报告](full-formalization-2026-11-06/report.md)及[复现进度](../formalization/PROGRESS.md)。

## 其余结果与历史接口

任意边界参数和小参数定理保留，已有调用不变。旧的 `ConjectureA1.ConjectureA1`
是一个不同的、未证明的 legacy 命题，既缺实际特征零绑定又要求环境中心性；新根证明不依赖它。

全参数最优性张量构造仍为经过审查的书面证明，未在 Lean 编码；它不是原猜想根证明的依赖。
独立显式三项式展开也未单独形式化，当前加权归纳已完成其在主定理中的作用。
