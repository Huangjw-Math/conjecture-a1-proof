# 已形式化的命题与剩余步骤

Lean 4.31.0、Mathlib `fabf563a7c95a166b8d7b6efca11c8b4dc9d911f` 下，
当前有 **37 个已编译的引理/定理**。完整清单、命令及公理输出范围见
[PROGRESS.md](../formalization/PROGRESS.md)；独立语义审读见
[Lean 审查](audit-2026-11-05/lean-review.md)。

## 原假设下已证明的无限家族

设 K 为任意特征零域、V 为任意 K-向量空间，X,Y 为端同态，Z=XY−YX，
只假设 XZ=ZX、YZ=ZY。

- `vector_p_zero`：任意自然 q，Xv=0、Y^(q+1)v=0 ⇒ (X+Y)^(2q+1)v=0。
- `vector_q_zero`：任意自然 p，X^(p+1)v=0、Yv=0 ⇒ (X+Y)^(2p+1)v=0。
- `vector_p_one_q_one`：X²v=Y²v=0 ⇒ (X+Y)^5v=0。
- `vector_boundary_or_le_one`：在 p=0、q=0 或 p,q≤1 时，以原目标的
  指数 2p+2q+1 合并这些结果。含零向量和零空间。

这里使用指定向量的湮灭，不要求端同态本身幂零；也不要求 Z 与整个端同态环交换。

## 可以复用到一般证明的工具

| 内容 | 已证明声明 | 范围 |
|---|---|---|
| 内导子与一次换位 | `ad_*`、`mul_pow_normal_order`、`pow_mul_normal_order` | 一般环；换位公式只用所需的局部交换关系 |
| 内导子的 Taylor 公式 | `taylor` | 任意环，无额外交换假设，任意自然指数 |
| 高阶交换子与任意幂正规序 | `ad_iterate_pow`、`normal_order` | 任意环，仅两条局部交换关系；越界下降阶乘自动为零 |
| 一般右湮灭元的向量关系 | `vector_right_line_relation` | 任意域，任意 p、B；由 X^(p+1)v=0 得到含 (-Z)^j 的有限和为零 |
| 边界模中的次数消失 | `boundary_monomial_vanish`、`boundary_weighted_vanish` | Xv=0、Y^(q+1)v=0；分别控制 a+b>q 与 n+2a+b>2q |
| 整系数小次数证书 | `two_mul_add_pow_three`、`two_mul_add_pow_five` | 非交换环恒等式，向量湮灭因子始终位于最右端 |

所有声明的实际传递公理集合只出现 `propext`、`Classical.choice`、`Quot.sound`
的子集。扫描与编译分别检查；编译输出中的 `#print axioms` 才是传递公理的依据。

## 一般正参数还缺什么

`def VectorConjecture` 忠实定义全部自然 p,q 的目标，尚没有证明该一般命题的定理。
现有正规序公式和右湮灭关系之后，仍需：

1. 乘上左侧锚点因子，把一般向量关系整理为固定加权次数的有限直线系统，证明全部端点约定。
2. 正、负两类直线的三角消元。
3. 标量少项式重数界、向量系数的标量化和支撑计数，用于中间直线。
4. 将各直线的消失组装成任意 p,q 的原目标。

一般三项式展开及张量最优性模型也未完整形式化；主证明可不以完整 PBW 构造为前置。
书面证明已独立审查；这些尚缺步骤指 Lean 覆盖，而不是书面数学缺口。

## 历史接口的含义

旧的 `ConjectureA1.ConjectureA1` 定义保留原接口。其未用到的 section
`Algebra ℚ R` 不出现在实际类型中，而且它要求交换子在整个 R 中中心。
它不是本次原猜想的证明。新的 `VectorConjecture` 显式绑定 Field/CharZero，
仅要求两个生成元分别与交换子交换。

原基线 `ad_pow_succ` 的幂乘法方向曾导致编译失败，现已修复；注释中的三项式
公式漏 n! 也已更正。注释和命题定义不计入 37 个已证明声明。
