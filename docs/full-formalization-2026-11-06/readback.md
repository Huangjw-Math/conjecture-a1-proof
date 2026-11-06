# General 根声明的独立数学读回

日期：2026-11-06。

## 1. 读回结论

`ConjectureA1.vector_conjecture` 的准确含义如下：

> 对任意特征为零的交换域 \(K\)、任意 \(K\)-向量空间 \(V\)、任意两个 \(K\)-线性自同态 \(X,Y:V\to V\)，令
> \[
> Z=X\circ Y-Y\circ X.
> \]
> 如果作为整个 \(V\) 上的算子有
> \[
> X\circ Z=Z\circ X,\qquad Y\circ Z=Z\circ Y,
> \]
> 那么对所有自然数 \(p,q\geq0\) 和所有向量 \(v\in V\)，
> \[
> X^{p+1}v=0\quad\text{且}\quad Y^{q+1}v=0
> \quad\Longrightarrow\quad
> (X+Y)^{2p+2q+1}v=0.
> \]

这里的幂是算子复合幂，\(X^0=\operatorname{id}_V\)。两个交换关系是算子恒等式，不只是作用在该 \(v\) 上的等式；两个消去条件及结论则只针对同一个给定向量 \(v\)。

根声明没有残留 `SparseRootProperty`、`LineVanishing`、有限维性、全局算子幂零性或环境中心性假设。两个命名的中间性质在证明内部有具体证明，随后被传入条件性组装引理。未发现根证明调用未证明的 legacy 命题。

依据：`formalization/ConjectureA1.lean:29–32,141–147`；`formalization/General.lean:8–40`；`formalization/AxiomAudit.lean` 的本轮实际编译输出（本地保留）。以上结论来自定义、声明及证明体，不采用源码注释中关于“原始”“完整”或“已证明”的状态声称。

## 2. 对象、宇宙与完整量词

### 2.1 全部根类型参数

用 \(u_K,u_V\) 重命名宇宙变量，三个根声明的共同环境是：

```lean
{K : Type uK} {V : Type uV}
[Field K] [CharZero K] [AddCommGroup V] [Module K V]
```

- \(u_K,u_V\) 相互独立。`#print vector_conjecture` 实际列出两个宇宙变量 `.{u_3, u_4}`，没有将两个类型限制在同一宇宙，也没有比较它们的大小。
- `Field K` 是交换域结构，并包含 \(K\) 非平凡；不是仅有非交换除环或一般环。
- `CharZero K` 显式保留，要求自然数到 \(K\) 的标准映射单射。
- `AddCommGroup V` 和 `Module K V` 使 \(V\) 成为该域上的代数向量空间。无需拓扑、范数、完备性或有序结构。
- 没有 `[Nontrivial V]`；零空间也允许。由于 \(V\) 有零元，向量类型并非空类型。
- 没有 `[FiniteDimensional K V]`、`[Module.Finite K V]` 或给定有限基。任意维数都在量词范围内。
- 证明内部使用经典选择及自动推导的向量空间自由性、投射性；它们不是新增的调用者前提，见第 5 节。

`Module.End K V` 展开为 `V →ₗ[K] V`。其乘法满足 `(F * G) w = F (G w)`，单位为恒等映射；不是逐点乘法。`Commute F G` 展开为 `F * G = G * F`。

相关定义：`Mathlib/Algebra/Module/LinearMap/End.lean:28–59`、`Mathlib/Algebra/Group/Commute/Defs.lean:35–44`、`Mathlib/Algebra/Field/Defs.lean:116–119,180`。

### 2.2 `vector_general`

省去可从上下文恢复的结构参数后，其完整逻辑顺序是：

```lean
∀ (X Y : Module.End K V),
  Commute X (ad X Y) →
  Commute Y (ad X Y) →
  ∀ (p q : ℕ) (v : V),
    (X ^ (p + 1)) v = 0 →
    (Y ^ (q + 1)) v = 0 →
    ((X + Y) ^ (2 * p + 2 * q + 1)) v = 0
```

类型 \(K,V\) 是隐式参数；四个结构通过 typeclass 参数提供。`X Y hX hY p q v hx hy` 都是显式参数。没有额外的存在量词、统一选择的向量或依赖维数的常数。指数固定为 \(2p+2q+1\)，不只是“存在某个消去指数”。

`p,q` 独立遍历全部自然数，没有 \(p\leq q\)、正性或上界限制。特别包括 \(p=q=0\)、仅一个为零以及任意大的参数。

依据：`formalization/General.lean:8,25–34`；编译器实际类型见 `formalization/AxiomAudit.lean` 的本轮实际编译输出（本地保留）。

### 2.3 `vector_conjecture`

它显式量化 `(K : Type uK) (V : Type uV)` 以及上述四个 typeclass 参数，返回 `VectorConjecture K V`。展开该 `def` 后，正是第 2.2 节的全称命题。

`formalization/AxiomAudit.lean` 的本轮实际编译输出（本地保留） 的完整 `#print` 同时显示声明及证明体：它依次引入 `X Y hX hY p q v hx hy`，随后直接调用 `vector_general`。因此这里不是只声明了一个待证明的 `Prop`，也没有把所要返回的命题本身当作输入。

### 2.4 `vector_monomial_cutoff`

除了第 2.2 节的全部参数和两个向量消去条件，它再显式量化

```lean
(a b k : ℕ)
(hw : a + b + 2 * k = 2 * p + 2 * q + 1)
```

并证明

\[
\operatorname{mono}(X,Y,a,b,k,v)=Z^k X^aY^b v=0.
\]

准确作用顺序是先 \(Y^b\)，再 \(X^a\)，最后 \(Z^k\)。`mono` 是一个向量值定义，不是算子等式，也没有对 \(X,Y\) 强加额外条件。

该定理按声明只覆盖**恰好**等于指定权重的三元组；它没有直接声明所有更高权重的版本。`hw` 是真实的附加等式前提，但并非不可满足：总可取 \(a=2p+2q+1,b=k=0\)。

依据：`formalization/MonomialActions.lean:10–14`；`formalization/General.lean:11–22`。

## 3. 向量结论不等于算子结论

声明没有要求 \(X^{p+1}=0\) 或 \(Y^{q+1}=0\) 作为算子恒等式，也没有得出 \((X+Y)^{2p+2q+1}=0\) 作为算子恒等式。其量词允许 \(v,p,q\) 分别改变；只有当同一对 \(p,q\) 的两个消去条件对所有向量成立时，才能另用线性映射外延性推出相应算子等式。

两个简单的手算实例说明这些区分有实际内容：

1. 在 \(V=\mathbb Q^2\) 上取 \(X=Y=\operatorname{diag}(0,1)\)、\(v=(1,0)\)、\(p=q=0\)。全部前提成立，结论为 \((X+Y)v=0\)，但 \(X+Y=\operatorname{diag}(0,2)\ne0\)，而且 \(X,Y\) 都不幂零。
2. 在 \(V=\mathbb Q^3\) 上取 \(X=E_{12},Y=E_{23}\)，则 \(Z=E_{13}\ne0\)，而 \(XZ=ZX=YZ=ZY=0\)。取 \(v=e_3,p=0,q=1\) 满足两个向量消去条件。因此两个交换假设不等于要求 \(X,Y\) 相互交换，也不因要求非零交换子而矛盾。

这两项为直接代数核对，未另外执行 Lean 实例测试。

## 4. 中间性质展开后是什么

### 4.1 `SparseRootProperty`

对域 \(K\)，它定义为：对每个 \(f\in K[t]\) 及 \(m\in\mathbb N\)，

\[
(t-1)^m\mid f,\qquad
\#\{n:\operatorname{coeff}_n(f)\ne0\}\leq m
\quad\Longrightarrow\quad f=0.
\]

它计算的是非零系数的个数，不是次数。定义自身只要求 `[Field K]`；`Fewnomial.lean` 中的 `sparseRootProperty` 的证明另外要求并使用 `[CharZero K]`。它不是“对任意特征的域已经无条件成立”的性质。

证明以 \(m\) 归纳。非零 \(f\) 时取 \(e=\deg f\)，构造

\[
g=t f'-e f.
\]

系数公式是 \(g_n=(n-e)f_n\)，其支持包含在 \(f\) 的支持删去 \(e\) 后的集合中；由 \((t-1)^{m+1}\mid f\) 得到 \((t-1)^m\mid g\)。归纳给出 \(g=0\)，特征零使不同自然数的标量像不同，故 \(f\) 只能是一个单项式。它在 \(t=1\) 消失，进而该单项式为零。\(m=0\) 分支直接由支持大小为零处理。

依据：`formalization/LineRecurrence.lean:9–11`；`formalization/Fewnomial.lean:15–93`。

### 4.2 线系数与 `LineRecurrence`

记下降阶乘为 \(b_{\underline j}=b(b-1)\cdots(b-j+1)\)，并采用其自然数递归定义：\(b_{\underline0}=1\)，\(j>b\) 时为零。定义

\[
c_{p,b,j}=(-1)^j b_{\underline j}\binom{p+1}{j}\in K.
\]

对序列 \(u:\mathbb N\to V\)，`LineRecurrence p b0 M u` 是：

\[
\forall b\in\mathbb N,\quad
b_0\leq b\leq M\Longrightarrow
\sum_{j=0}^{p+1}c_{p,b,j}\,u(b\mathbin{\dot-}j)=0.
\]

符号 \(b\mathbin{\dot-}j=\max(b-j,0)\) 明确表示 Lean 自然数截断减法。不是把 \(u\) 的定义域扩展成了整数。\(j>b\) 的项由下降阶乘系数为零而消失。

依据：`formalization/LineRecurrence.lean:14–21`。

### 4.3 `LineVanishing`

它量化所有 \(p,\ell,D,M,b_0\in\mathbb N\) 和所有 \(u:\mathbb N\to V\)。在以下条件下断言 \(u(b)=0\) 对所有自然数 \(b\) 成立：

1. \(b<\ell\Rightarrow u(b)=0\)，且 \(D<b\Rightarrow u(b)=0\)；
2. \(\ell\leq b_0\leq M\)；
3. 上述 `LineRecurrence p b0 M u`；
4. \((b_0\mathbin{\dot-}\ell)+(D+p+1\mathbin{\dot-}M)\leq p+1\)。

它不要求 \(D\leq M\)、\(b_0\leq D\) 或 \(\ell\leq D\)。这些不同排列可能使支持的一部分为空，但不会改变定义。条件 2 确保递推区间不倒置，也使后述两个边界区间不交。

标量情形以有限多项式

\[
U(t)=\sum_{b=0}^{D}\frac{u(b)}{b!}t^b,
\qquad H(t)=(1-t)^{p+1}U(t)
\]

编码。\(b!\,H_b=\sum_{j=0}^{p+1}c_{p,b,j}u(b\mathbin{\dot-}j)\)。由递推及支持限制，

\[
\operatorname{supp}(H)\subseteq
[\ell,b_0)\ \cup\ (M,D+p+1].
\]

两个区间的总基数不超过 \(p+1\)，同时 \((t-1)^{p+1}\mid H\)。`SparseRootProperty` 给出 \(H=0\)，继而 \(U=0\) 和全部 \(u(b)=0\)。

向量情形不是通过选择有限维子空间证明，而是对所有代数线性泛函 \(\varphi:V\to K\) 应用标量结论，再用代数对偶分离向量。

依据：`formalization/WeightedLines.lean:12–16`；`formalization/LineSystem.lean:19–185`。

## 5. 假设如何在根证明内解除

实际主依赖链为：

```text
vector_conjecture
└─ vector_general
   ├─ vector_monomial_cutoff
   │  ├─ weighted_monomial_vanish_of_line
   │  ├─ mono_left_line_relation
   │  │  └─ vector_right_line_relation
   │  │     └─ normal_order
   │  │        ├─ taylor
   │  │        └─ ad_iterate_pow
   │  └─ 内部 LineVanishing 证明
   │     ├─ sparseRootProperty
   │     │  └─ sparseEuler 及多项式导数整除引理
   │     └─ line_vanish
   │        ├─ scalar_line_vanish
   │        │  └─ 线多项式的系数/支持引理
   │        └─ Module.forall_dual_apply_eq_zero_iff
   ├─ add_apply_mono
   │  └─ x_apply_mono、y_apply_mono 等交换子运算引理
   └─ weighted_iterate_vanish
```

- `scalar_line_vanish`、`line_vanish` 的确把 `SparseRootProperty K` 当作输入；`weighted_monomial_vanish_of_line` 也确实把 `LineVanishing` 和真实算子线关系当作输入。单独引用这些引理应保留这些前提。
- `vector_monomial_cutoff` 在 `General.lean:16–19` 用 `line_vanish (sparseRootProperty K)` 构造所需 `LineVanishing`，因此该性质不再暴露于根类型。
- 它在 `General.lean:20–22` 以 `mono_left_line_relation ... hx` 提供所需算子线关系；没有将该关系作为根定理的未证明假设。
- `Module.forall_dual_apply_eq_zero_iff` 的库声明有 `[Module.Projective K V]` 要求，但该实例可由任意域上的向量空间是自由模、自由模是投射模自动得到，未要求有限维。对应源码：`Mathlib/LinearAlgebra/Dual/Lemmas.lean:205–210`、`Mathlib/LinearAlgebra/Basis/VectorSpace.lean:149–155`、`Mathlib/Algebra/Module/Projective.lean:150–161`。
- 没有循环使用 `vector_general` 或 `vector_conjecture` 去证明上述核性质；它们在 `General.lean` 中位于组装链的末端。

## 6. 两个关键桥实际使用的数学关系

### 6.1 从向量消去条件得到线关系

一般正序公式在环中给出

\[
x^a y^b=
\sum_{j=0}^{a}\binom aj b_{\underline j}
y^{b\mathbin{\dot-}j}Z^j x^{a\mathbin{\dot-}j},
\qquad Z=xy-yx,
\]

前提仅为 \(xZ=Zx,yZ=Zy\)。交换 \(x,y\) 后，交换子为 \(-Z\)。对向量 \(v\) 使用 \(X^{p+1}v=0\)，从 \(Y^B X^{p+1}v=0\) 得到

\[
\sum_{j=0}^{B}
B_{\underline j}\binom{p+1}{j}
X^{p+1\mathbin{\dot-}j}(-Z)^jY^{B\mathbin{\dot-}j}v=0.
\]

将求和上限改写为 \(p+1\) 时，两个尾部均有明确的零系数。然后对零向量施加 \(Z^kX^{A-(p+1)}\)，其中 \(A\geq p+1\)，得到

\[
\sum_{j=0}^{p+1}c_{p,B,j}\,
Z^{k+j}X^{A-j}Y^{B\mathbin{\dot-}j}v=0.
\]

这里不曾把 \(X^{p+1}v=0\) 扩大成 \(X^{p+1}=0\)，也不曾断言 \(X^{p+1}\) 自动消去任意 \(Y\)-后继向量。

依据：`formalization/NormalOrder.lean:43–117`；`formalization/MonomialActions.lean:84–132`。

### 6.2 从线唯一性到权重截断，再到和算子幂

对目标三元组 \(A,B,k\)，先用 \(B>q\) 时 \(Y^Bv=0\) 的直接分支。其余 \(B\leq q\) 时：

- 若 \(B\leq A\)，设 \(d=A-B,M=B+k\)，则 \(2M+d=2p+2q+1\)，所以 \(d>0\)。取
  \[
  u(b)=\begin{cases}Z^{M-b}X^{b+d}Y^bv,&b\leq M,\\0,&b>M,\end{cases}
  \]
  并使用 \(\ell=0,D=\min(M,q),b_0=(p+1)\mathbin{\dot-}d\)。
- 若 \(A<B\)，设 \(r=B-A>0,M=B+k\)，则 \(2M=2p+2q+1+r\)。取
  \[
  u(b)=\begin{cases}Z^{M-b}X^{b-r}Y^bv,&r\leq b\leq M,\\0,&\text{其他},\end{cases}
  \]
  并使用 \(\ell=r,D=q,b_0=p+1+r\)。

两个分支分别证明支持边界、锚点、递推区间和基数不等式，再应用 `LineVanishing` 取 \(b=B\)。奇数权重排除 \(A=B\) 的方式是当前 `hw` 的合法推论，而非对整个定理加入不可满足前提。

最后，实际算子作用公式为

\[
(X+Y)\operatorname{mono}(a,b,k)=
\operatorname{mono}(a+1,b,k)+
\operatorname{mono}(a,b+1,k)-
a\,\operatorname{mono}(a\mathbin{\dot-}1,b,k+1).
\]

当 \(a>0\) 时右侧三个指标的权重都增加一；当 \(a=0\) 时最后一项的标量系数为零。`weighted_iterate_vanish` 对迭代次数归纳，把权重 \(N\) 的单项式全消去转换成

\[
(X+Y)^n\operatorname{mono}(a,b,k)=0
\quad\text{在 }n+a+b+2k=N\text{ 时}.
\]

`vector_general` 取 \(N=n=2p+2q+1,a=b=k=0\)，并把 `mono X Y 0 0 0 v` 化为 \(v\)。

依据：`formalization/WeightedLines.lean:18–144`；`formalization/MonomialActions.lean:24–70`；`formalization/General.lean:29–34`。

## 7. 边界、截断及下降阶乘检查

| 位置 | 实际处理 | 读回结果 |
|---|---|---|
| `ad_pow_eq` 的 \(n=0\) | 单独分支；\(0\) 倍消去含 \(n\mathbin{\dot-}1\) 的项 | 没有负指数解释 |
| `ad_iterate_pow` 的 \(j>b\) | \(b_{\underline j}=0\)；递归中使用自然数下降阶乘公式 | 截断幂的项由零系数消去 |
| 下降阶乘端点 | \(b_{\underline0}=1\)，\(b_{\underline b}=b!\)，\(b_{\underline{b+1}}=0\) | 未将“阶乘比”错误延伸到 \(j>b\) |
| 两种线关系求和范围 | \(j>p+1\) 用二项式系数为零；\(j>B\) 用下降阶乘为零 | 改写求和范围有依据 |
| 左乘线关系的 \(A-j\) | \(A\geq p+1,j\leq p+1\)，再证明减法重排 | 未无条件使用自然数减法消去律 |
| 递推中的 \(b\mathbin{\dot-}j\) | \(j>b\) 时线系数为零；其余项按非负指标重排 | 没有把负指标项错误归入 \(u(0)\) |
| 指数生成函数中的阶乘除法 | \(j\leq b\) 分支使用 \((b-j)!b_{\underline j}=b!\)；其他分支用零系数 | 特征零保证所除阶乘非零 |
| 权重归纳中的 \(a=0\) | 单独分支用零标量，不调用最后一项的错误权重归纳式 | 截断减法不产生额外边界项 |
| \(p=0\) 或 \(q=0\) | 根量词及统一证明均保留，不转交缺失的特殊情形假设 | 得到指数 \(2q+1\) 或 \(2p+1\)；均为零时指数为 \(1\) |

下降阶乘定义及关键事实见 `Mathlib/Data/Nat/Factorial/Basic.lean:324–369,388–395`；其余位置见第 4–6 节所列源码。

## 8. Legacy 命题与证明信任范围

### 8.1 同名 legacy `def` 不是根结论，也不是根假设

`ConjectureA1.ConjectureA1` 是另外一个命题定义。编译器实际类型要求 `[Ring R] [AddCommGroup V] [Module R V]`，量化 \(x,y,z\in R\)，要求 \(z=xy-yx\) 以及 \(z\) 与所有 \(w\in R\) 交换，再陈述环元素对模的消去结论。

尽管源码外层曾列 `[Algebra ℚ R]`，它没有进入该 `def` 的实际类型；`formalization/AxiomAudit.lean` 的本轮实际编译输出（本地保留） 清楚显示这一点。不能把该 legacy 定义读成已经带有特征零假设的定理。

本次根返回的是另一个定义 `VectorConjecture K V`。阅读的根证明和实际依赖没有把 legacy `ConjectureA1 R V` 当成已证明引理或假设使用。本报告没有把根结果扩大成任意环/模版本的证明。

### 8.2 提供的实际公理输出

`formalization/AxiomAudit.lean` 的本轮实际编译输出（本地保留） 对以下三个根均列出同一公理集合：

```text
vector_monomial_cutoff : [propext, Classical.choice, Quot.sound]
vector_general         : [propext, Classical.choice, Quot.sound]
vector_conjecture      : [propext, Classical.choice, Quot.sound]
```

没有列出 `sorryAx` 或项目自定义公理。上游 `sparseRootProperty`、`scalar_line_vanish`、`line_vanish` 及关键桥的公理输出亦在该文件中。逐一阅读的八份 Lean 源码没有发现 `sorry`、`admit`、自定义 `axiom` 或用未给证明的 proposition 充当定理的环节。

这支持“上述三个形式根的依赖中没有暴露待证数学假设”的结论；不是对任意外部文字陈述的证明认可。

## 9. 本轮完成与未做的检查

**已完成：**

- 阅读冻结包内八份指定 Lean 源码和 `ActualTypes.txt`；展开根声明、算子和单项式、稀疏根性质及线递推定义。
- 跟踪两个条件性接口在根内的解除方式，检查向量/算子层级、全部参数范围、奇数权重分支、自然数截断、下降阶乘及 \(0\) 参数端点。
- 只读核对相关 Mathlib 定义，尤其是算子复合方向、对偶分离所需实例及下降阶乘端点。
- 从所读声明、证明和给定实际类型输出中，未发现改变第 1 节数学含义的残留假设或语义疑点。

**未做：**

- 未读取或比对非形式原题、论文、作者意图或历史审稿，因此不作最终契约一致性裁定，也不作新颖性评价。
- 未重新运行 Lean、构建、`#print` 或 `#print axioms`；本报告引用冻结包已提供的编译器输出，不把源码阅读称为一次新构建验收。
- 未独立复建或校验编译环境、依赖版本及输出生成过程；未执行另一个内核检查器。
- 未修改源包或项目，不执行提交、推送或普通文件哈希计算。

后续目标比对者可将第 1–3 节的准确数学陈述和第 8 节的信任范围直接与其持有的目标材料比较。
