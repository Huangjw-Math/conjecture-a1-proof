# 指数 $2p+2q+1$ 是否 sharp？

> 配套文件：《报告_ConjectureA1的证明.pdf》§7、《验证程序/》
> 记号同报告：$[X,Y]=XY-YX$，$Z=[X,Y]$ 中心，$X^{p+1}v=Y^{q+1}v=0$。

## 1. 问题的两种读法

设
$$\mathcal E(p,q)\;:=\;\min\{\,N:\ \text{对一切满足假设的 }(V,v)\text{ 都有 }(X+Y)^Nv=0\,\}.$$
报告证明了 $\mathcal E(p,q)\le 2p+2q+1$。问"$2p+2q+1$ 是否 sharp"，即问
$$\mathcal E(p,q)=2p+2q+1\ ?$$
注意这是**对一切模取最坏情形**的量；对单个具体的 $(V,v)$，幂零指数通常小得多（见 §5）。

**先说结论：**

| 情形 | 结论 | 依据 |
|---|---|---|
| $p=0$ 或 $q=0$ | $\mathcal E(0,q)=2q+1$，**精确** | §2（显式反例模型，已证） |
| $0\le p,q\le 6$ | $\mathcal E(p,q)=2p+2q+1$，**精确** | §3（精确有理数计算） |
| 一般 $p,q$ | **未解决**；两条自然路线都有障碍 | §4 |

即：**不存在只依赖 $(p,q)$ 的更小指数能一般成立**（至少 $p=0$ 或 $q=0$ 时不行），
所以 $2p+2q+1$ 作为"对一切模一致成立"的界是**最优**的；但一般 $(p,q)$ 的严格证明仍缺一块，
我不把一般情形列为已证。

---

## 2. $p=0$（或 $q=0$）时指数精确：显式反例

**定理 S1.** 设 $q\ge 0$。存在 $\mathbb Q$-向量空间 $V$、$v\in V$、$X,Y,Z\in\operatorname{End}(V)$，使得
$$Z=[X,Y],\quad [X,Z]=[Y,Z]=0,\quad Xv=0,\quad Y^{q+1}v=0,\quad\text{但}\quad (X+Y)^{2q}v\neq 0.$$
于是 $\mathcal E(0,q)\ge 2q+1$；结合报告的定理（给出 $\le 2q+1$）得 $\mathcal E(0,q)=2q+1$。
由 $X\leftrightarrow Y$ 对称，$\mathcal E(p,0)=2p+1$。

*构造.* 令
$$V=\mathbb Q[x,\varepsilon]/(\varepsilon^{q+1}),\qquad
X=\partial_x,\qquad Y=\varepsilon x\ (\text{乘 }\varepsilon x),\qquad Z=\varepsilon\ (\text{乘 }\varepsilon),\qquad v=1.$$
（$\varepsilon$ 是形式幂零参数；$V$ 是以 $x^a\varepsilon^b$，$b\le q$ 为基的有限维空间。）

*验证.* 记 $f=f(x,\varepsilon)$。

1. $[X,Y]f=\partial_x(\varepsilon x f)-\varepsilon x\,\partial_x f=\varepsilon f+\varepsilon x f'-\varepsilon x f'=\varepsilon f$，
   故 $Z=\varepsilon\cdot$；
2. $Z$ 与 $X,Y$ 交换（都是 $V$ 上的乘法算子 $\partial_x$、$\varepsilon x$、$\varepsilon$ 与乘 $\varepsilon$ 交换）；
3. $Xv=\partial_x 1=0$；
4. $Y^{q+1}v=(\varepsilon x)^{q+1}\cdot 1=\varepsilon^{q+1}x^{q+1}=0$，因为 $\varepsilon^{q+1}=0$；
5. 最后计算 $(X+Y)^{2q}v$。令 $T=\partial_x+\varepsilon x$。由 BCH（$[t\partial_x,t\varepsilon x]=t^2\varepsilon$ 中心）
$$e^{t\partial_x}e^{t\varepsilon x}=e^{tT+\tfrac{t^2}{2}\varepsilon}
\quad\Longrightarrow\quad
e^{tT}=e^{t\partial_x}e^{t\varepsilon x}e^{-\tfrac{t^2}{2}\varepsilon}.$$
作用在 $1$ 上：$e^{t\partial_x}$ 是平移，$e^{t\partial_x}e^{t\varepsilon x}=e^{t\varepsilon(x+t)}$，于是
$$e^{tT}(1)=e^{-\tfrac{t^2}{2}\varepsilon}\,e^{t\varepsilon x+t^2\varepsilon}
=e^{\,t\varepsilon x+\tfrac{t^2}{2}\varepsilon}
=\sum_{i,j\ge0}\frac{1}{i!\,j!\,2^{j}}\,\varepsilon^{i+j}\,t^{i+2j}\,x^{i}.$$
要 $\varepsilon^q$ 与 $t^{2q}$ 同时出现，须 $i+j=q$ 且 $i+2j=2q$，解得 $j=q,\ i=0$，系数为
$\dfrac{1}{2^{q}q!}\neq 0$。故
$$T^{2q}(1)=(2q)!\cdot\frac{1}{2^{q}q!}\,\varepsilon^{q}+\bigl(\varepsilon\text{ 次数}<q\text{ 的项}\bigr)
=(2q-1)!!\,\varepsilon^{q}+\cdots\;\neq\;0 ,$$
因为 $\varepsilon^q\neq0$（$q<q+1$），且 $(2q-1)!!=1,3,15,105,\dots$ 非零。
（已用 `验证程序/sharpness.py` 在 $q\le6$ 时精确核验：系数依次为 $1,3,15,105,945,10395$，即 $(2q-1)!!$。）∎

**注 S2.** 该模型中 $\varepsilon=Z$ 的幂零指数是 $q+1$，恰是 $\mathcal E$ 出现"翻倍"的机制：
$T$ 每作用一次最多把 $\varepsilon$ 的次数提高 $1$（通过 $\varepsilon x$），而把 $x$ 的次数提高 $1$；
要把 $x$ 的次数"压回"$0$、同时把 $\varepsilon$ 提到 $q$，至少需要 $2q$ 步。这与报告 §3 的
三项式分解完全吻合（$Z$ 幂次 $k$ 与 $(X,Y)$ 次数 $N-2k$ 的互补关系）。

---

## 3. $p,q\le 6$：精确计算

用《验证程序/》中的精确有理数程序，在万能模 $M_{p,q}=A/(AX^{p+1}+AY^{q+1})$ 上计算
$\min\{n:(X+Y)^nv_0=0\}$（$v_0=1+I$）。结果（$p,q\le6$，49 组）**全部等于 $2p+2q+1$**，
且 $Z$ 的幂零指数全部等于 $p+q+1$。

这说明 $\mathcal E(p,q)=2p+2q+1$ 至少在 $p,q\le6$ 时成立（万能模给出下界，报告的定理给出上界）。

---

## 4. 一般 $(p,q)$：归约与障碍

**命题 S3（一个天然但走不通的路线，如实记录）.** $A$ 上"$Z$ 的次数"给出一个**滤过**（不是分次）：
$(X^aY^bZ^k)(X^cY^dZ^l)$ 展开后每一项的 $Z$ 次数都 $\ge k+l$（每次交换 $Y,X$ 只增加 $Z$）。于是
$$\mathrm{gr}_Z(A)\;\cong\;\mathbb Q[X,Y][\varepsilon],\qquad \varepsilon=[Z]$$
（关系 $XY-YX=Z$ 在 $\mathrm{gr}_Z$ 中退化为 $xy=yx$）。若 $T^{N-1}\in I$，则最低 $Z$ 阶符号满足
$\sigma(T^{N-1})\in\mathrm{gr}_Z(I)$。由三项式公式，
$$\sigma(T^{N-1})=(X+Y)^{2p+2q}\qquad(\text{即 }k=0\text{ 的分量}).$$
**但这条路走不通**：在 $\mathbb Q[X,Y]$ 中 $(X+Y)^{2p+2q}\in(X^{p+1},Y^{q+1})\subseteq\mathrm{gr}_Z(I)$，
因为 $a+b=2p+2q>p+q$ 迫使每个单项式 $X^aY^b$ 都有 $a\ge p+1$ 或 $b\ge q+1$。故 $Z$-滤过**太粗**，
给不出非成员性。

**更细的障碍**：人们会转而希望"纯 $Z$ 部分"$\;Z^{p+q}\notin I$。这个方向的朴素论证也失败，因为
纯 $Z$ 项**确实**能由生成元的左倍产生：取
$$a=Y^{p+1}Z^{q-1}\quad(q\ge1),\qquad\text{则}\quad a\,X^{p+1}\in I
\ \text{ 的纯 }Z\text{ 部分}=(-1)^{p+1}(p+1)!\,Z^{p+q}\neq 0 .$$
（$aX^{p+1}=Y^{p+1}Z^{q-1}X^{p+1}$ 按正规序展开即得；已用 PBW 精确算术在
$(p,q)=(1,1),(2,1),(2,2),(3,2),(3,3),(4,3)$ 上核验，系数依次为 $2,-6,-6,24,24,-120$，即 $(-1)^{p+1}(p+1)!$。）
所以 $Z^{p+q}$ 是否为 $I$ 的元素**不能**靠单项符号直接判定，需要更精细的泛函或 Gröbner 基论证。

**结论**：对一般 $(p,q)$，$\mathcal E(p,q)=2p+2q+1$ 目前只有
(i) $p=0$ 或 $q=0$ 的**证明**（§2）与 (ii) $p,q\le6$ 的**精确验证**（§3）。
把 (i)(ii) 推广到一切 $(p,q)$ 是一个独立的、范围明确的小问题；本报告未完成它。

---

## 5. 什么时候指数可以明显变小（重要！）

$2p+2q+1$ 是"对一切模"的最坏情形。对具体的代数/模，指数常常小得多；以下三类现象值得注意：

**(a) $Z=0$（即 $X,Y$ 交换）时：$\mathcal E=p+q+1$。**
此时 $(X+Y)^{p+q+1}v=\sum_{a+b=p+q+1}\binom{p+q+1}{a}X^aY^bv$，而每一项都有 $a\ge p+1$ 或
$b\ge q+1$；利用交换性可写成 $X^{a-p-1}Y^b(X^{p+1}v)$ 或 $X^aY^{b-q-1}(Y^{q+1}v)$，故为零。
指数从 $2p+2q+1$ 降到 $p+q+1$——**量子修正项 $p+q$ 完全消失**。

**(b) §2 的模型（$X=\partial_x,\ Y=\varepsilon x$）指数为 $2q+1$，与 $p$ 无关。**
取 $v=1$ 时 $X^1v=0$ 对任意 $p$ 成立，于是同一个模型在 $(p,q)$ 下给出的幂零指数仍是 $2q+1$；
当 $p\ge1$ 时 $2q+1<2p+2q+1$。所以"$2p+2q+1$"并非任何具体模的指数。

**(c) 若 $Z$ 低阶幂零（$Z^mv=0$，$m\le p+q$）**：三项式分解中 $k\ge m$ 的分量消失，
临界指数下降（$m=1$ 即 (a) 的情形）。这与 §2 的注 S2 一致：**指数的"翻倍"完全由 $Z$ 的存活长度驱动**。

**(d) 论文的应用**：在 [1] 的仿射情形中 $p,q\in\{0,1\}$（见报告 §6），故
$$\mathcal E(p,q)\le 5,$$
且 $b_i=1$（$p=0$ 或 $q=0$）时只需 $3$；$X,Y$ 交换时只需 $p+q+1\le3$。
换言之，论文实际用到的指数远小于统一上界，$2p+2q+1$ 的意义在于"对所有可能的一般化都成立"。

---

## 6. 小结

1. **$2p+2q+1$ 对"只依赖 $(p,q)$ 的一致界"是最优的**：$p=0$（或 $q=0$）时已由显式模型证明不可改进（定理 S1），
   $p,q\le6$ 时由精确计算确认。
2. 一般 $(p,q)$ 的严格最优性证明仍缺一块（§4）；缺口是一个关于左理想 $I$ 与纯 $Z$ 项的具体交换代数问题，
   **不影响报告的主结论**（报告只证上界）。
3. 对具体模，指数通常远小于 $2p+2q+1$；§5 给出三类可改进的情形与定量结论。
