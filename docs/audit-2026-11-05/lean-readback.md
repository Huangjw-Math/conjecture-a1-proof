# Lean 形式陈述盲读报告

日期：2026-11-05

## 读回结论

本包定义了两个一般命题，并给出 37 个带证明的 lemma/theorem：12 个基础交换子引理、2 个有限环恒等式证书、6 个小参数向量结果、8 个边界结果、9 个正规序与线关系结果。

对 \(X^{p+1}v=Y^{q+1}v=0\Longrightarrow(X+Y)^{2p+2q+1}v=0\) 这一形状的结论，已证参数范围是
\[
p=0\quad\text{或}\quad q=0\quad\text{或}\quad(p\leq1\ \text{且}\ q\leq1),
\]
结论指数为 \(2p+2q+1\)。在正参数区域，这个集合只含 \((p,q)=(1,1)\)。一般的 VectorConjecture 是值为 Prop 的定义，包内没有声明它的证明。任意参数的正规序公式和线关系是已证辅助结果，不能按其名称读成一般向量消去定理。

本报告依据六份实际 Lean 源及随包的 ActualTypes.txt 读回；后者用于核对编译后的实例参数和公理输出。另核对了 Mathlib 的下降阶乘定义及线性自同态乘法定义。未使用原题、作者意图、论文或项目进度材料；本次未重新运行编译。

## 1. 统一记号、实际域与隐式参数

以下名称均属于 ConjectureA1 命名空间。使用下列缩写：
\[
Z=ad(X,Y)=XY-YX,\qquad S=X+Y,
\]
\[
H_X:\operatorname{Commute}(X,Z),\qquad
H_Y:\operatorname{Commute}(Y,Z).
\]
小写环元素的情形同样写 \(z=ad(x,y)\)。这些是报告中的缩写；除旧命题显式量化一个 \(z\) 外，源码中的交换子都直接写成 ad，不另量化独立的 \(Z\)。

### 共同前缀

为完整列出类型而不逐条重复，后文使用三个前缀：

* **R 前缀**：隐式 \(\{R:\mathrm{Type}\ u\}\)，实例参数 [Ring R]。
* **V₀ 前缀**：隐式 \(\{K:\mathrm{Type}\ u\}\)、\(\{V:\mathrm{Type}\ v\}\)，实例参数按顺序为 [Field K]、[AddCommGroup V]、[Module K V]。
* **Vχ 前缀**：同样的两个隐式类型参数，实例参数按顺序为 [Field K]、[CharZero K]、[AddCommGroup V]、[Module K V]。

\(u,v\) 是任意宇宙层级，不要求相同。方括号均表示实例隐式参数。除这些隐式类型及实例参数外，下文列出的元素、自然数和证明前提均为显式参数。没有未列出的维数、非零向量或全局幂零性参数。

### 结构的含义

* Ring 是含单位、乘法结合的环，不要求乘法交换，也没有附加 Nontrivial。因而 R 前缀允许正特征以及平凡环。
* Field 是交换域并含非平凡性；Vχ 再要求其特征为零。V₀ 没有特征零约束。
* V 是 K-模，其加法为交换群；没有有限维性要求，也没有 Nontrivial V。零空间被允许，但非零空间同样在量化范围内。
* Module.End K V 是 K-线性自同态环。乘法是复合：
  \[
  (AB)v=A(Bv),\qquad 1v=v.
  \]
  因而右端因子先作用于向量。
* Commute A B 是环等式 \(AB=BA\)。对线性自同态，它要求在整个 V 上相等，不只是对当前 \(v\) 相等。\(H_X,H_Y\) 仅要求交换子分别与 X、Y 交换，不要求 X 与 Y 交换，也不要求 Z 与整个自同态环交换。
* 自然数系数 \(n\mathbin{\bullet}w\) 表示加法群中的 n 次相加；它不预设特征零。有限环证书中的整数数码则是环内整数系数。

### 自然数减法与下降阶乘

所有指数和参数 \(a,b,j,n,p,q,B\) 都是自然数。\(a-j\) 是截断减法 \(\max(a-j,0)\)，不存在负指数。

Mathlib 中
\[
b_{\underline 0}=1,\qquad
b_{\underline{j+1}}=(b-j)b_{\underline j},
\]
其中减法也在自然数中。因此
\[
b_{\underline j}=0\iff b<j.
\]
只有在 \(j\leq b\) 时才可把它写作 \(b!/(b-j)!\)。越界后不能用带负阶乘的形式代替。二项式系数 \(\binom{a}{j}\) 在 \(j>a\) 时为零。

## 2. 两个命题定义，不是两个已证定理

### ConjectureA1

实际定义的前缀为

~~~lean
(R : Type u) (V : Type v)
[Ring R] [AddCommGroup V] [Module R V]
~~~

这里 R、V 是显式类型参数。实际类型**没有 [Algebra ℚ R]**；尽管源码的 section 写了该实例，最终定义没有保留它。

所定义命题是：
\[
\begin{aligned}
\forall x,y,z\in R,\quad&
z=xy-yx\ \Longrightarrow\
(\forall w\in R,\ zw=wz)\ \Longrightarrow\\
&\forall p,q\in\mathbb N,\ \forall v\in V,\\
&x^{p+1}\mathbin{\bullet}v=0\ \Longrightarrow\
y^{q+1}\mathbin{\bullet}v=0\ \Longrightarrow\
(x+y)^{2p+2q+1}\mathbin{\bullet}v=0.
\end{aligned}
\]

它量化一般环及其模，要求交换子在整个 R 中中心化；它既没有实际的有理数代数参数，也没有实际的特征零参数、域参数或忠实模参数。

### VectorConjecture

实际定义的前缀为

~~~lean
(K : Type u) (V : Type v)
[Field K] [CharZero K] [AddCommGroup V] [Module K V]
~~~

K、V 同样是显式类型参数；CharZero 在定义自身直接写成实例隐式 binder，而非仅在 section 中引入，最终类型保留了它。

所定义命题是：
\[
\begin{aligned}
\forall X,Y\in\operatorname{End}_K(V),\quad&
H_X\ \Longrightarrow\ H_Y\ \Longrightarrow\\
&\forall p,q\in\mathbb N,\ \forall v\in V,\\
&X^{p+1}v=0\ \Longrightarrow\
Y^{q+1}v=0\ \Longrightarrow\
S^{2p+2q+1}v=0.
\end{aligned}
\]

这里的幂零性前提和结论都针对同一个给定向量 v。没有前提 \(X^{p+1}=0\)、\(Y^{q+1}=0\)，结论也不是自同态等式 \(S^{2p+2q+1}=0\)。

两个定义均仅构造一个命题；定义一个 Prop 不构造该命题的证明。

## 3. ConjectureA1.lean 的基础已证引理

本节每条均采用 R 前缀，没有 Field、CharZero、Algebra 或模参数。

### 基础运算

ad 的定义是 \(ad(x,y)=xy-yx\)。以下是各引理的全部显式参数及结论：

1. **ad_def**：\((x,y:R)\)，
   \[
   ad(x,y)=xy-yx.
   \]
2. **ad_add**：\((x,y,z:R)\)，
   \[
   ad(x,y+z)=ad(x,y)+ad(x,z).
   \]
3. **ad_zero**：\((x:R)\)，\(ad(x,0)=0\)。
4. **ad_neg**：\((x,y:R)\)，\(ad(x,-y)=-ad(x,y)\)。
5. **ad_one**：\((x:R)\)，\(ad(x,1)=0\)。
6. **ad_mul**：\((x,y,z:R)\)，
   \[
   ad(x,yz)=ad(x,y)z+y\,ad(x,z).
   \]
7. **ad_pow_succ**：\((x,w:R)(r:\mathbb N)\)，
   \[
   x(wx^r)=wx^{r+1}+ad(x,w)x^r.
   \]
   它不要求任何交换性。
8. **ad_swap**：\((x,y:R)\)，\(ad(y,x)=-ad(x,y)\)。

### 单侧幂正规序

9. **ad_pow_of_commute**：\((x,y:R)\)，显式前提 \(hy:\operatorname{Commute}(y,z)\)，再给 \((n:\mathbb N)\)：
   \[
   ad(x,y^{n+1})=(n+1)\mathbin{\bullet}(y^nz).
   \]
10. **mul_pow_normal_order**：与上一条相同的参数、同一个 hy：
    \[
    xy^{n+1}=y^{n+1}x+(n+1)\mathbin{\bullet}(y^nz).
    \]
11. **ad_pow_eq**：同样仅假定 \(\operatorname{Commute}(y,z)\)，\((n:\mathbb N)\)：
    \[
    ad(x,y^n)=n\mathbin{\bullet}(y^{n-1}z).
    \]
    当 \(n=0\) 时，右侧是 \(0\mathbin{\bullet}(y^0z)=0\)，与 \(ad(x,1)=0\) 一致。
12. **pow_mul_normal_order**：\((x,y:R)\)，显式前提 \(hx:\operatorname{Commute}(x,z)\)，再给 \((n:\mathbb N)\)：
    \[
    x^{n+1}y=yx^{n+1}+(n+1)\mathbin{\bullet}(x^nz).
    \]

第 9–11 条不需要 \(x\) 与 \(z\) 交换；第 12 条不需要 \(y\) 与 \(z\) 交换。不能把这些不同的单侧前提统一读成两个前提都存在。

## 4. NormalOrder.lean：全部实际声明

前八个已证引理均采用 R 前缀。最后一个向量线关系改用 V₀ 前缀，既不含外围 R 参数，也不含 CharZero。

### innerEnd 及四个运算引理

**innerEnd** 是定义，不是额外假设：
\[
innerEnd(x)=L_x-R_x:\operatorname{AddMonoid.End}(R),
\quad L_x(w)=xw,\quad R_x(w)=wx.
\]
这里是加法自同态的复合环，未预设 innerEnd 幂零。

1. **innerEnd_apply**：显式 \((x,w:R)\)，
   \[
   innerEnd(x)(w)=ad(x,w).
   \]
2. **mulLeft_pow_apply**：显式 \((x,w:R)(n:\mathbb N)\)，
   \[
   (L_x^n)(w)=x^nw.
   \]
3. **mulRight_pow_apply**：显式 \((x,w:R)(n:\mathbb N)\)，
   \[
   (R_x^n)(w)=wx^n.
   \]
4. **innerEnd_commute_right**：显式 \((x:R)\)，
   \[
   \operatorname{Commute}(innerEnd(x),R_x).
   \]
   这是从结合律得到的恒等式，不是关于外部元素 y 的附加交换假设。

### 一般 Taylor 公式及自然数线性

5. **taylor**：显式 \((x,w:R)(n:\mathbb N)\)，没有交换前提：
   \[
   x^nw=\sum_{j=0}^{n}
   \binom nj\mathbin{\bullet}
   \bigl((ad(x,\cdot))^{[j]}(w)\,x^{n-j}\bigr).
   \]
   \((ad(x,\cdot))^{[j]}\) 是函数的 j 次迭代，零次是恒等函数；它不是环元素的 j 次幂，也不是 \(ad(x^j,w)\)。求和恰为 Finset.range (n+1)，所以本公式中的 \(n-j\) 不会在求和范围内越界。

   实际证明将 \(L_x=innerEnd(x)+R_x\) 写成两个交换的加法自同态之和，应用有限二项式公式后在 w 处求值。没有使用某个迭代最终为零的前提。

6. **ad_nsmul**：显式 \((x,w:R)(n:\mathbb N)\)，
   \[
   ad(x,n\mathbin{\bullet}w)=n\mathbin{\bullet}ad(x,w).
   \]

### 迭代交换子与任意幂正规序

7. **ad_iterate_pow**：显式 \((x,y:R)\)，随后是
   \[
   hx:\operatorname{Commute}(x,z),\quad
   hy:\operatorname{Commute}(y,z),
   \]
   再给 \((b,j:\mathbb N)\)，结论为
   \[
   (ad(x,\cdot))^{[j]}(y^b)
   =b_{\underline j}\mathbin{\bullet}(y^{b-j}z^j).
   \]
   b、j 没有大小约束。若 \(j>b\)，下降阶乘为零，右侧整体为零，即使截断指数 \(b-j=0\)。这证明 ad 在每个特定 \(y^b\) 上经过足够多次迭代后为零，不是 ad 在整个 R 上具有某个统一幂零指数。

8. **normal_order**：显式 \((x,y:R)\)、hx、hy，再给 \((a,b:\mathbb N)\)：
   \[
   x^ay^b
   =\sum_{j=0}^{a}
   \left(\binom aj b_{\underline j}\right)\mathbin{\bullet}
   \bigl(y^{b-j}z^jx^{a-j}\bigr).
   \]
   无需 \(a\leq b\) 或 \(b\leq a\)。求和范围是 \(0\leq j\leq a\)；其中 \(j>b\) 的项系数为零，有效范围因而可读为 \(0\leq j\leq\min(a,b)\)。乘积顺序是 y、z、x，不能在不说明前提时按交换多项式重排。

这两条均只使用局部的 x–z、y–z 交换条件，没有环境中心性或特征零条件。在正特征中，系数还可能因特征而消失；实际类型仍是一般环恒等式。

### 右端消去线关系

9. **vector_right_line_relation** 采用 V₀ 前缀。全部显式参数依次为：
   \[
   (X,Y:\operatorname{End}_K(V)),\ H_X,\ H_Y,\
   (p,B:\mathbb N),\ (v:V),\
   hx:X^{p+1}v=0.
   \]
   其结论是
   \[
   \left(
   \sum_{j=0}^{B}
   \left(B_{\underline j}\binom{p+1}{j}\right)\mathbin{\bullet}
   \bigl(X^{p+1-j}(-Z)^jY^{B-j}\bigr)
   \right)v=0.
   \]

   p、B 都任意；没有 q，也没有关于 Y 消去 v 的前提。没有 CharZero、[Ring R]、有限维性或算子全局幂零性参数。

   实际证明对 \(Y^BX^{p+1}\) 使用交换 X、Y 后的 normal_order，并用 \(ad(Y,X)=-Z\)。因此求和中的自同态等于 \(Y^BX^{p+1}\)，作用于给定 v 后为零。负号保留在 \((-Z)^j\) 中，不能直接改成 \(Z^j\)。

   若 \(j>p+1\)，二项式系数为零，故截断指数 \(p+1-j\) 不造成负幂问题；求和范围保证 \(j\leq B\)。这是一条向量关系，不逐项断言每个正规单项式为零。证明也没有把“消去 v 的算子”当成可任意右乘的双边理想。

## 5. BoundaryCases.lean：全部八个已证声明

除明确标为 V₀ 的两条作用公式外，本节采用 Vχ 前缀。所有含 \(H_X,H_Y\) 的声明都按先 \(H_X\)、后 \(H_Y\) 的顺序取两个显式前提。

### 5.1 vector_nat_cancel

前缀：Vχ。显式参数依次为
\[
(n:\mathbb N),\ (hn:n\ne0),\ (v:V),\
(h:n\mathbin{\bullet}v=0).
\]
结论：\(v=0\)。

K 虽然不在显示的结论 \(v=0\) 中，仍由 include K 保留为实际隐式类型参数，Field、CharZero 和 Module 也都保留。证明把 n 次相加改写为 \((n:K)\) 的标量作用，再乘以其逆元。\(n\ne0\) 和 CharZero 正是保证该逆元可用于消去的条件。

### 5.2 boundary_x_action

前缀：V₀，**没有 CharZero**。显式参数依次为
\[
(X,Y),\ H_X,\ H_Y,\ (v:V),\
(hv:Xv=0),\ (a,b:\mathbb N).
\]
结论：
\[
X\bigl(Z^a(Y^{b+1}v)\bigr)
=(b+1)\mathbin{\bullet}\bigl(Z^{a+1}(Y^bv)\bigr).
\]

没有 q、没有 \(Y^{q+1}v=0\)，也没有 \(a,b\) 的范围约束。它是一个作用公式，不是消去结论；证明只移动交换的因子并使用一阶正规序。

### 5.3 boundary_monomial_vanish

前缀：Vχ。显式参数依次为
\[
(X,Y),\ H_X,\ H_Y,\ (v:V),\
(hx:Xv=0),\ (q:\mathbb N),\
(hy:Y^{q+1}v=0),\
(a,b:\mathbb N),\ (hdegree:q<a+b).
\]
结论：
\[
Z^a(Y^bv)=0.
\]

判据是普通次数 \(a+b>q\)，不是 \(2a+b>q\)。没有额外条件 \(a\leq q\)、\(b\leq q\) 或 \(a,b>0\)。

实际证明对 a 归纳。a 为零时，由足够高的 Y 次幂在 v 上消去推出；归纳步对已有零向量作用 X，使用 boundary_x_action 得到 \((b+1)\) 倍的目标向量为零，再用 vector_nat_cancel 消去该正自然数。因此 CharZero 在此证明中实际承担消去系数的作用。

### 5.4 boundary_add_action

前缀：V₀，**没有 CharZero**。显式参数依次为
\[
(X,Y),\ H_X,\ H_Y,\ (v:V),\
(hv:Xv=0),\ (a,b:\mathbb N).
\]
结论：
\[
S\bigl(Z^a(Y^bv)\bigr)
=Z^a(Y^{b+1}v)
+b\mathbin{\bullet}\bigl(Z^{a+1}(Y^{b-1}v)\bigr).
\]

没有 Y 的幂消去前提。\(b=0\) 时第二项是零，\(b-1=0\) 的截断不会留下额外项。\(b>0\) 时两项的权 \(2a+b\) 都比输入高一；源码也单独处理了 \(b=0\)。

### 5.5 boundary_weighted_vanish

前缀：Vχ。显式参数依次为
\[
(X,Y),\ H_X,\ H_Y,\ (v:V),\
(hx:Xv=0),\ (q:\mathbb N),\
(hy:Y^{q+1}v=0),\
(n,a,b:\mathbb N),\
(hweight:2q<n+2a+b).
\]
结论：
\[
S^n\bigl(Z^a(Y^bv)\bigr)=0.
\]

这是三个任意自然数 n、a、b 的条件结论；没有要求 n、a、b 分别为正。严格不等式 \(2q<n+2a+b\) 是实际前提，不能改为非严格不等式。

证明对 n 归纳。n 为零时由该不等式推出 \(q<a+b\)，调用 boundary_monomial_vanish；后继步用 boundary_add_action 分成两项，利用相应权增加一，并在 \(b=0\) 时直接消去零系数项。没有使用 PBW 基、有限维性或某个双边商代数的存在性前提。

### 5.6 vector_p_zero

前缀：Vχ。显式参数依次为
\[
(X,Y),\ H_X,\ H_Y,\ (q:\mathbb N),\ (v:V),\
(hx:Xv=0),\ (hy:Y^{q+1}v=0).
\]
结论：
\[
S^{2q+1}v=0.
\]

q 任意，包含 q 为零；这是无限族，不是只检查了有限多个 q。证明在 weighted_vanish 中取 \(n=2q+1,\ a=b=0\)。

### 5.7 vector_q_zero

前缀：Vχ。显式参数依次为
\[
(X,Y),\ H_X,\ H_Y,\ (p:\mathbb N),\ (v:V),\
(hx:X^{p+1}v=0),\ (hy:Yv=0).
\]
结论：
\[
S^{2p+1}v=0.
\]

p 任意。证明交换 X、Y，使用 \(ad(Y,X)=-ad(X,Y)\) 将原来的交换前提转换后调用 vector_p_zero；没有增加交换子为零的假设。

### 5.8 vector_boundary_or_le_one

前缀：Vχ。显式参数依次为
\[
\begin{gathered}
(X,Y),\ H_X,\ H_Y,\ (p,q:\mathbb N),\\
(hcase:p=0\lor q=0\lor(p\leq1\land q\leq1)),\\
(v:V),\ (hx:X^{p+1}v=0),\ (hy:Y^{q+1}v=0).
\end{gathered}
\]
结论：
\[
S^{2p+2q+1}v=0.
\]

这是对三种条件分支的汇总，不会删除 hcase。自然数正参数 \((1,2)\)、\((2,1)\) 或 \((2,2)\) 都不满足此 hcase。证明分别调用两个任意参数边界族和 vector_parameters_le_one，没有一般正参数分支。

## 6. SpecialCases.lean 的三次、五次环证书

这两个引理都采用 R 前缀。全部显式参数是 \((x,y:R)\)、\(hX:\operatorname{Commute}(x,z)\)、\(hY:\operatorname{Commute}(y,z)\)。没有域、模、特征零或任何幂消去前提。

### two_mul_add_pow_five

定义报告中的两个非交换多项式缩写：
\[
\begin{aligned}
P_5={}&2x^3+12x^2y-4xyx+5xy^2
       +2yx^2+20yxy-10y^2x+5y^3,\\
Q_5={}&5x^3+2x^2y-4xyx+2xy^2
       +17yx^2-4yxy+12y^2x+2y^3.
\end{aligned}
\]
实际结论为
\[
2(x+y)^5=P_5x^2+Q_5y^2.
\]

### two_mul_add_pow_three

实际结论为
\[
2(x+y)^3=(2x+3y)x^2+(3x^2+6yx+2y^2)y.
\]

两条证明先用 noncomm_ring 验证带有 \(xz-zx\)、\(yz-zy\) 余项的有限多项式恒等式，再用两个 Commute 前提消去这些余项。没有除以 2。故证书在特征 2 中仍是环等式，但左侧系数 2 为零，不能从证书本身消去 2。

右端的消去因子确切地位于最右侧：五次式是 \(x^2,y^2\)，三次式是 \(x^2,y\)。这使它们能在作用于一个满足相应条件的向量后消去；不要求整个算子为零。

## 7. VectorCases.lean 的向量装配范围

除 p=q=0 单独标出的情况外，本节采用 Vχ 前缀。

1. **vector_two_cancel**：显式 \((v:V)(h:v+v=0)\)，结论 \(v=0\)。K 经 include K 保留。使用域中非零的 2 的逆元，没有交换子或算子参数。
2. **vector_p_one_q_one**：显式 \((X,Y),H_X,H_Y,(v:V)\)，再给 \(hx:X^2v=0\)、\(hy:Y^2v=0\)，结论
   \[
   S^5v=0.
   \]
3. **vector_p_one_q_zero**：显式 \((X,Y),H_X,H_Y,(v:V)\)，再给 \(hx:X^2v=0\)、\(hy:Yv=0\)，结论
   \[
   S^3v=0.
   \]
4. **vector_p_zero_q_one**：显式 \((X,Y),H_X,H_Y,(v:V)\)，再给 \(hx:Xv=0\)、\(hy:Y^2v=0\)，结论
   \[
   S^3v=0.
   \]
5. **vector_p_zero_q_zero**：采用 **V₀ 前缀**，没有 CharZero，也没有 \(H_X,H_Y\)。显式参数为 \((X,Y),(v:V),(hx:Xv=0),(hy:Yv=0)\)，结论
   \[
   S^1v=0.
   \]
6. **vector_parameters_le_one**：采用 Vχ。显式参数依次为
   \[
   (X,Y),H_X,H_Y,(p,q:\mathbb N),
   (hp:p\leq1),(hq:q\leq1),(v:V),
   (hx:X^{p+1}v=0),(hy:Y^{q+1}v=0),
   \]
   结论为 \(S^{2p+2q+1}v=0\)。

第 2、3 条将对应环证书在 v 处求值，利用右端因子消去，再用 vector_two_cancel；第 4 条通过交换 X、Y 得到；第 6 条把 p、q 分别拆成 0 或 1，汇总四个特例。这一装配没有处理更大的正参数。

## 8. AxiomAudit.lean 的作用

此文件没有新增数学定理。它导入其余层，并执行 #print、#check 与 #print axioms，检查实际类型和已命名声明的传递公理依赖。

随包输出给出的 37 个已证声明的公理依赖均在
\[
\{propext,\ Classical.choice,\ Quot.sound\}
\]
之内；ad_def 的依赖为空。输出未列出 sorryAx 或额外自设公理。这里是对给定编译输出的读回，不将“打印了一个命题定义”解释成证明了该命题。

AxiomAudit 中将某些签名标注为 Type 的 #check 是宇宙 0 的可实例化检查。实际 #print 和不加该标注的 #check 表明定义及引理仍是上述宇宙多态的声明，不因此限制到宇宙 0。

## 9. 语义疑点与范围边界

### 9.1 旧定义中的特征零约束确实消失

实际类型删除了旧 section 的 Algebra ℚ R；不能从该 section 行推断 ConjectureA1 命题只覆盖特征零。与之相对，VectorConjecture 及 Vχ 结果保留 CharZero。

这个差别具有具体数学后果。作为对实际旧定义范围的直接推论，取
\[
R=M_2(\mathbb F_2),\quad V=\mathbb F_2^2,\quad
x=\begin{pmatrix}0&1\\0&0\end{pmatrix},\quad
y=\begin{pmatrix}0&0\\1&0\end{pmatrix}.
\]
则 \(x^2=y^2=0\)、\(ad(x,y)=I\) 在整个 R 中中心化，而 \((x+y)^2=I\)。对 \(p=q=1\)、\(v=e_1\)，旧命题的前提成立但 \((x+y)^5v=e_2\ne0\)。这是按矩阵运算得到的数学反例实例，不是包内新增的 Lean 声明。它说明旧定义的实际范围与“特征零命题”不能互换；旧定义本来只是 Prop，包内没有把这个范围上的命题证明为真。

### 9.2 没有发现靠不可能前提或空载体成立的新增结果

Field 排除平凡标量域；AddCommGroup 提供零向量，因此 V 不是空类型。V 可以是零空间，但各向量定理同时量化非零空间。取 \(K=\mathbb Q,V=\mathbb Q,X=Y=0\) 即可满足所有向量消去型前提，任意自然数参数也可取到相应边界实例。

两个 Commute 条件也不强制 \(Z=0\)：在三维有理向量空间上，取 \(X(e_2)=e_1\)、\(Y(e_3)=e_2\)，其余基向量像为零，则 \(Z(e_3)=e_1\)，且 X、Y 都与 Z 交换。因而新增结果并非只覆盖交换算子。

### 9.3 需要保持的三个区分

* **条件在整个空间上，结论在一个向量上。** \(H_X,H_Y\) 是算子等式；\(X^{p+1}v=0\)、\(Y^{q+1}v=0\) 及结论是对给定 v 的等式。
* **任意幂公式不等于任意正参数消去。** normal_order 和 vector_right_line_relation 都有任意自然数参数；后者只使用一个消去前提。本包没有将这些关系装配成一般 VectorConjecture 的证明。
* **正系数消去与零系数越界是不同机制。** 边界归纳在 Vχ 中消去非零的 \(b+1\)；正规序公式在一般环中保留系数，越界项因自然数下降阶乘或二项式系数为零而消失。不能把前者的除法移到一般环证书中。

以上结论是实际形式陈述及其范围读回，不包含与任何外部原题契约的对应裁定。
