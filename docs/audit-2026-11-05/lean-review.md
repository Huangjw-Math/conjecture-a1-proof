# Lean 独立语义与契约审计

日期：2026-11-05。

## 裁定：可接受为部分形式化，完整命题仍未形式化证明

实际声明与独立盲读报告一致。候选已证明原题的全部零参数边界族，以及
\((p,q)=(1,1)\)；也证明了任意参数的 Taylor、正规序及右端湮灭关系。
未发现这些已证结果通过增加算子幂零性、环境中心性、有限维性或不可能前提缩小原题。

精确已完成的参数集合为
\[
\{(p,q)\in\mathbb N^2:p=0\text{ 或 }q=0\text{ 或 }(p,q)=(1,1)\}.
\]
`VectorConjecture` 忠实定义了完整目标，但仍是 `Prop` 的定义，没有该命题的证明。
因此本次接受范围是上述部分结果，不包括任意正参数的 Lean 证明或一般最优性证明。

本审计由独立比较者完成：未参与候选证明编写，也不是形式陈述盲读者。
本审计将实际六模块、编译类型输出与盲读报告，同原题、契约和机器证据逐项比较。
根 `AGENTS.md` 和 `formalization/PROGRESS.md` 的状态文字不作为通过依据。

## 原题与实际 Lean 目标相符

直接核对了 [arXiv:1811.10137v2](https://arxiv.org/pdf/1811.10137v2) Appendix A，
印刷页 42 的 Conjecture A.1 及页 42–43 的 Lemmas A.3–A.4。
原题是特征零域上任意向量空间的向量级命题；原文边界结果允许另一参数任意，
并非仅允许 \(p,q\le1\)。`docs/audit-2026-11-05/problem_contract.md` 保留了这些量词。

`formalization/ConjectureA1.lean:141–149` 的实际目标有以下含义：

- \(K:\mathrm{Type}\ u\)、\(V:\mathrm{Type}\ v\) 的宇宙独立，
  实例为 `[Field K] [CharZero K] [AddCommGroup V] [Module K V]`。
  标量域非平凡；向量空间允许零空间，也量化所有非零空间，没有维数限制。
- `Module.End K V` 是线性自同态环，乘法为复合，\((AB)v=A(Bv)\)。
  因此 \(Z=XY-YX\) 的符号与原文一致。
- `Commute X Z`、`Commute Y Z` 是整个空间上的两个算子等式，
  既不要求 \(XY=YX\)，也不要求 \(Z\) 与整个自同态环交换。
- \(p,q\) 是包含零的自然数。前提仅为同一个向量上的
  \(X^{p+1}v=Y^{q+1}v=0\)，结论是同一向量上的
  \((X+Y)^{2p+2q+1}v=0\)，不是算子恒等于零。

独立 Guard 使用原始表达式 `X * Y - Y * X`，而不是只复用 `ad` 名称；
定义展开等式以 `rfl` 编译通过。另对目标类型本身检查了特征零实例与两个任意宇宙。

## 已证根接口与辅助层

### 无限边界族与小参数

`formalization/BoundaryCases.lean:104–133` 的三个根接口分别给出：

\[
Xv=0,\ Y^{q+1}v=0\implies (X+Y)^{2q+1}v=0
\quad(q\in\mathbb N),
\]
\[
X^{p+1}v=0,\ Yv=0\implies (X+Y)^{2p+1}v=0
\quad(p\in\mathbb N),
\]
以及带显式前提
`p = 0 ∨ q = 0 ∨ (p ≤ 1 ∧ q ≤ 1)` 的统一指数结果。
该前提未被省略；例如 \((1,2),(2,1),(2,2)\) 不在已证一般接口的参数范围内。

边界证明先由 \(a+b>q\) 得到 \(Z^aY^bv=0\)，再对进一步作用的
\((X+Y)^n\) 归纳，得到 \(n+2a+b>2q\) 时消失。
归纳中的 \(b+1\) 确实在特征零域上消去；没有把一般环的非零整数当成可消去标量。
\(b=0\)、\(n=0\)、\(q=0\) 分支均包含在证明中。

`formalization/VectorCases.lean:16–26` 的 \((1,1)\) 根结论为 \((X+Y)^5v=0\)。
其有限环证书的消去因子在最右端，作用于向量后才消去，再由特征零消去系数 2。
`vector_p_zero_q_zero` 甚至不需要特征零或交换子前提。

### 任意参数公式的系数、符号与范围正确

令 \(z=xy-yx\)，\(b_{\underline j}=b(b-1)\cdots(b-j+1)\)。
`formalization/NormalOrder.lean:43–95` 实际证明
\[
x^nw=\sum_{j=0}^{n}\binom nj
   \bigl((\operatorname{ad}x)^{[j]}(w)\,x^{n-j}\bigr),
\]
以及
\[
(\operatorname{ad}x)^{[j]}(y^b)
 =b_{\underline j}\,y^{b-j}z^j,
\qquad
x^ay^b=\sum_{j=0}^{a}\binom aj b_{\underline j}
   y^{b-j}z^jx^{a-j}.
\]
这些是一般环恒等式；第一条无交换前提，后两条只使用局部的 \(xz=zx,yz=zy\)。
Taylor 公式中的上标 \([j]\) 是函数迭代，不是某个算子的全局幂零性假设。

`formalization/NormalOrder.lean:101–119` 的向量关系为
\[
\left(\sum_{j=0}^{B}
 B_{\underline j}\binom{p+1}{j}
 X^{p+1-j}(-Z)^jY^{B-j}\right)v=0,
\qquad X^{p+1}v=0.
\]
它适用于任意 \(p,B\in\mathbb N\)，没有关于 \(Y\) 湮灭 \(v\) 的前提，也没有
`CharZero` 或多余的外围环参数。它来自 \(Y^BX^{p+1}\) 的正规序后在 \(v\) 处求值。
交换 \(X,Y\) 后的负号保留为 \((-Z)^j\)，系数转换利用
\(n_{\underline j}=j!\binom nj\)，无需除法。

所有自然数减法均为截断减法。已核对 Mathlib 的下降阶乘定义及
`Nat.descFactorial_eq_zero_iff_lt`：\(j>b\) 时下降阶乘为零；
右端关系在 \(j>p+1\) 时二项式系数为零。
因此越界幂不会产生虚假的非零项。该关系只断言整条向量线性关系为零，
没有逐项消去，也没有把向量湮灭子的左理想误作双边理想。

### 遗留旧定义必须继续与原题分开

`formalization/ConjectureA1.lean:128–132` 的旧 `ConjectureA1` 实际类型只有
环和模实例；section 中未使用的 `[Algebra ℚ R]` 被 Lean 删除。
它还要求环境中心性，因此不是本次原题的同义定义。
例如在 \(M_2(\mathbb F_2)\) 的自然模上取 \(x=E_{12},y=E_{21}\)，则
\(x^2=y^2=0\)、\([x,y]=I\)，但 \((x+y)^5e_1=e_2\ne0\)。
旧定义的实际全范围命题因而不真。

候选已把此项明确标为 legacy、未证明的不同命题；新增结果不调用它。
这不阻断上述部分交付，但发布结论不能把这个旧名称或其定义行当成原题的证明。

## 机器证据：复用有效构建，新增独立 typed guard

读取并逐项比对了 `formalization/evidence/validation-build.log` 与
`formalization/evidence/validation-report.json`，没有只采信 `passed` 字段：

- 六模块各有实际 `CHECKED` 记录，日志以 `EXIT=0` 结束；构建目标逐模块调用 Lean，
  并把本次项目输出放在导入路径首位。
- 从五个数学源模块枚举到 37 个 lemma/theorem，与日志的 37 个传递公理输出及
  JSON 的 37 项映射逐项一致。分布为基础层 12、有限证书 2、小参数向量层 6、
  边界层 8、正规序层 9；`AxiomAudit.lean` 不新增数学定理。
- 实际六模块未见 `sorry`、`admit`、`sorryAx`、自设公理、`unsafe` 或
  `native_decide`。源码扫描用于定位，根声明的传递公理输出才是闭合依据。
- 37 个实际公理集合均是允许集合
  \(\{\texttt{propext},\texttt{Classical.choice},\texttt{Quot.sound}\}\)
  的子集；没有 `sorryAx` 或额外研究假设。

随后在仓库外编写并实际编译了下附 `Guard.lean`：

- Lean 4.31.0，编译器提交 `68218e876d2a38b1985b8590fff244a83c321783`。
  依赖沿用现有构建的锁定缓存，Mathlib 提交
  `fabf563a7c95a166b8d7b6efca11c8b4dc9d911f`。
- 目标定义的类型检查、定义展开等式，以及五个根定理的完整类型断言全部通过；
  Guard 编译退出码 0，无错误或警告。所有检查均保留两个独立宇宙。
- 独立重读这五个实际根的传递公理：每个集合均恰为上述三个允许公理。

本次新增编译只针对 Guard，没有重复全项目或全 Mathlib 构建。
项目六模块的新鲜证明检查采用已有实际构建证据；外部 `.olean` 仍是受信任的缓存输入，
没有在本次审计中从源重建全部依赖或运行第二种内核实现。

## 完整 Lean 证明还缺什么

1. 把任意参数右端关系打包到固定权次数的直线族
   \(u_b=X^{b+\delta}Y^bZ^{m-b}v\)，给出自然数/整数指标之间的合法转换、
   非法指标的零约定、已知 \(Y\)-端点和次数奇偶性。
2. 形式化外侧 \(\delta\ge p+1\) 与 \(\delta\le-1\) 的三角消去。
3. 形式化少项式重数界及其向量值版本，完成内侧 \(1\le\delta\le p\) 的消去；
   尤其需要保留向量系数到标量多项式的有效桥梁。
4. 证明 \((X+Y)^{2p+2q+1}v\) 落在已消失单项式的线性张成中，
   并交付一个实际具有类型 `VectorConjecture K V` 的证明。

这些是 Lean 未实现的义务。书面稿 `report/src/report.tex` 的 §§3–5 已写出
三项式展开、直线关系、三角/少项式论证及主定理装配；本审计未把“尚未形式化”
归类为书面证明缺口。书面论证的正确性由相应独立数学审计另行判断。

## 附录：本次实际通过的独立 Guard

用现有构建后的项目库和锁定依赖库组成 `LEAN_PATH`，将项目库置于首位，执行
`lean -o Guard.olean Guard.lean`。Guard 自身与输出置于独立审计目录；不写项目源或依赖缓存。

独立检查的完整可执行源码见 [Guard.lean](Guard.lean)。
