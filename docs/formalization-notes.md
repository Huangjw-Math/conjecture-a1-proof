# 形式化说明与差异文档

> 对应文件：`ConjectureA1.lean`、`lakefile.lean`、`lean-toolchain`
> 对应报告：《报告_ConjectureA1的证明.pdf》（下称"报告"）

## 0. 最重要的一条：可核验性声明

**本目录的 Lean 代码没有被编译过，也不可能在本环境中被编译。**

理由（已在会话中逐条实测）：

| 检查项 | 结果 |
|---|---|
| `lean` / `lake` / `elan` 可执行文件 | 不存在 |
| `~/.elan`、本地 Mathlib 检出 | 不存在 |
| Coq / Isabelle / Agda / Idris | 不存在 |
| 外网（github.com、raw.githubusercontent.com、pypi.org、lake.lean-lang.org） | 全部连接失败（`Invoke-WebRequest` 超时/DNS 失败） |

因此，无法用 `lake build` 验证任何 Lean 声明。**任何声称"已通过 Lean 检验"的说法在此环境下都不可信**，
本文档也不会这样声称。代码按"可编译的源码 + 明确的未完成清单"交付，而不是按"已验证产物"交付。

**同时必须说明**：`ConjectureA1.lean` 中
* 不含 `sorry`；
* 不含用户声明的 `axiom`；
* 不含 `unsafe`、`native_decide`、`@[implemented_by]` 等绕过检验的手段。

未形式化的步骤一律写成**注释**（注释不构成证明义务，因此既不是 `sorry`，也不是公理）。
这是我在"必须无 `sorry`"与"无法编译验证"两条约束下唯一诚实的处理方式。

---

## 1. 逐条对照表（报告 ↔ Lean）

记号：`[已证]` = 文件中有完整证明文本（未编译）；`[未形式化]` = 仅以注释给出精确陈述与证明路线；
`⚠` = 与报告表述存在差异，见 §2。

| # | 报告中的陈述 | Lean 中的对应 | 状态 |
|---|---|---|---|
| 0 | 约定 $[X,Y]=XY-YX$ | `def ad (x y : R) : R := x*y - y*x` | `[已证]`（定义） |
| 1 | 附录 A.2：$\mathrm{ad}_x$ 是导子 | `ad_add`, `ad_mul`, `ad_neg`, `ad_zero`, `ad_one`, `ad_pow_succ` | `[已证]` |
| 2 | 引理 4.1 正规序公式 $Y^BX^n=\sum_j(-1)^j\frac{B!}{(B-j)!}\binom{n}{j}X^{n-j}Y^{B-j}Z^j$ | `taylor` + `ad_iterate_y_pow`（取 $x:=Y,\ y:=X,\ z:=-Z$，$\pm$ 号由 $z=\mathrm{ad}\,Y\,X$ 给出）⚠ | `[未形式化]` |
| 3 | 引理 4.2 直线关系 $R(A,B,K)=(X^{A-p-1}Y^BZ^K)X^{p+1}\in I$ | `z_pow_mul_x_pow` 只覆盖**双边**版本 | `[未形式化]` |
| 4 | 命题 4.5 双边版本 $(x+y)^{2p+2q+1}=0$ | `two_sided` | `[未形式化]` |
| 5 | 定理 3.1 三项式公式 | `trinomial` ⚠（求和形式改写，见 §2-D3） | `[未形式化]` |
| 6 | §5 主定理：次数 $\ge 2p+2q+1$ 的单项式属于左理想 $I$ | **无对应**（需要 PBW 与左理想机制） | `[未形式化]` |
| 7 | Conjecture A.1（向量级） | `def ConjectureA1 : Prop` | `[仅陈述]` |
| 8 | §6 与 Serre 关系的对接 | 无（属于李代数侧，未触及） | `[未形式化]` |
| 9 | §7 最优性 | 无（见《指数sharp性分析.md》§2） | `[未形式化]` |

**结论**：Lean 文件覆盖报告的"环论核心"里的**引理 4.1 之前的部分**（即 $\mathrm{ad}$ 的导子性质与
$Y$ 与 $X$ 的基本交换关系），以及全部**陈述**；证明链的实质部分（2–6）尚未形式化。
所以：**本次交付没有给出 Conjecture A.1 的机器验证证明。**

---

## 2. 具体差异（逐项）与对结论的影响

### D1（记号）交换子约定
报告用 $[X,Y]=XY-YX$（并注明 $YX=XY-[X,Y]$），Lean 用 `ad x y = x*y - y*x`。
**影响：无。** 二者逐字一致；`ad y x = -ad x y` 的符号差在 D2 中显式出现。

### D2（符号）正规序公式的 $(-1)^j$
报告的引理 4.1 对 $Y^BX^n$ 展开，得 $(-1)^j$；Lean 的 `ad_iterate_y_pow` 对
$(\mathrm{ad}\,x)^{[j]}(y^m)$ 展开，得 $(+1)$。二者通过
$$\mathrm{ad}_Y X=\textstyle\sum_j\ldots,\qquad \mathrm{ad}_Y(X)=YX-XY=-Z$$
互换：把 Lean 的结论用于 $(x,y,z)=(Y,X,-Z)$ 即得报告的 $(-1)^j=(-Z)^j$。
**影响：无**（纯记号），但这是形式化时必须显式引入的一条 `rfl`-级重写，容易漏。

### D3（改述）三项式公式的求和形式 ⚠
报告写作 $a+b+2k=n$ 的三重求和，系数 $\frac{n!}{a!b!k!}\left(-\frac12\right)^k$。
Lean 里改为"外层 $k$ + 内层 `Finset.antidiagonal`"的二重求和，并显式写出
$$\frac{(-1)^k}{2^k\,k!}\cdot\frac{1}{a!\,b!}.$$
**影响：无**（同一个数，只是把 $\frac{n!}{a!b!k!}=\frac{n!}{k!}\cdot\frac{1}{a!b!}$ 拆开；
注意报告里是"三分配"系数，Lean 里把 $\frac{n!}{}$ 留在外层 $k$ 之外的多重求和里——
若照抄会差一个 $n!$，这是最容易出错的一处，已在注释中标注）。

### D4（参数化方式）"特征零"如何表达
报告假设"$\mathbb K$ 特征为零"；Lean 用 `[Algebra ℚ R]`。
**影响：无。** 特征零的域必含 $\mathbb Q$，故特征零域上的代数恰是 $\mathbb Q$-代数；
反之 $\mathbb Q$-代数特征必为零。二者等价（除了"域"与"环"的差别：报告只用乘法与加法，不需要除法，
所以用 `Ring R` 比 `Field` 更一般，是**加强**而非削弱）。

### D5（加强）报告的 $Z$ 中心性假设
报告写作 $[X,Z]=[Y,Z]=0$；Lean 写作 `hz : ∀ w, z * w = w * z`（$z$ 与所有元素交换）。
**影响：无**（`hz` 更强一点，但两条假设在 $X,Y$ 生成的子代数上等价，而证明只用到后者）。

### D6（关键差异）**"左理想"在 Lean 中的缺席** ⚠⚠
报告的主定理是左理想成员命题 $(X+Y)^{N}\in AX^{p+1}+AY^{q+1}$；Lean 中的 `z_pow_mul_x_pow`
与 `two_sided` 只覆盖**双边/元素级**版本（$x^{p+1}=0$ 作为等式）。

**这条差异是实质性的，且是本次形式化没有完成的主要原因。** 报告注 4.4 已给出反例
（$p=q=1$ 时 $X^2Y\notin I$）说明二者不能互推。因此：
* 双边版本（`two_sided`）**不能**推出 Conjecture A.1；
* 若只形式化双边版本并宣称"已验证猜想"，将是**错误的**；本文件因此**没有**把
  `ConjectureA1` 声明为 `theorem`。

### D7（方法差异）少项式引理需要线性泛函
报告引理 5.4 的证明取 $\lambda\in W^*$ 使 $\lambda(u_{b_*})\ne0$。
Lean 中需先证"有限个向量张成的子模是有限维的"，再用 `Basis`/`Finsupp` 构造 $\lambda$
（或用 `Module.Dual` 的分离性）。**影响：无**（数学上无问题，属构造性细节），
但这是形式化里最容易卡住的一步之一。

### D8（数值部分）不进 Lean
报告的数值核验（`验证程序/`）不进入 Lean 文件，也不作为证明。
Lean 文件不引用任何数值结果。**影响：无**（报告同样声明数值不作为证明）。

---

## 3. 未形式化的实质内容：缺口量化与路线图

报告主定理（定理 5.6）的机器验证需要下列三块基础设施，缺一不可：

**(a) PBW 基与分次结构（估计 1.5–2 人月）**
需要构造 $A=U(\mathfrak h_1)$ 的具体模型（例如 `ℕ×ℕ×ℕ →₀ ℚ` 上的 Heisenberg 乘法），
证明结合律（可借"忠实表示"或"结合律的显式验证"）、PBW 基、次数分次、
以及 $I_d=A_{d-p-1}X^{p+1}+A_{d-q-1}Y^{q+1}$。
*这是整个形式化的瓶颈*：Mathlib 目前没有现成的 $U(\mathfrak h_1)$ 与 PBW 基。

**(b) 沿直线的线性代数（估计 1 人月）**
三角形子式的可逆性（两处，$\delta\ge p+1$ 与 $\delta\le-1$）是**关于 $p,q$ 的一般性**论断，
需要把"系数矩阵"写成 $\mathbb Q$ 上的下/上三角矩阵并给出对角元非零的证明；
难点在于指标平移后要与 `Finset` 上的求和顺序对齐。

**(c) 少项式重数界 + 模值多项式（估计 1 人月）**
标量版本（`k` 项多项式根重数 $\le k-1$，用 confluent Vandermonde）是标准线性代数；
真正的困难是把"系数在模 $M$ 中的多项式 $H(t)$"化为标量：需要上面的线性泛函构造。

**总估计：3–4 人月**（有 Lean/Mathlib 经验者，且已有 (a) 的话可降到 1–1.5 人月）。

**建议的推进顺序**（每一步都可独立通过 `lake build`）：
1. `ad`、`taylor`、`ad_iterate_y_pow`（本文件已给出陈述）；
2. `z_pow_mul_x_pow` + `trinomial` + `two_sided`（**双边定理**，完全可做）；
3. (a) 的具体模型 + `I` 的定义 + "次数 $\ge N$ ⇒ 属于 $I$" 的**陈述**；
4. (b)(c) 的两个线性代数论断；
5. 组装 `ConjectureA1`。

**对报告结论的影响**：无。报告中的证明是完整的书面证明；Lean 文件的缺口是"尚未机器验证"，
不是"证明有错"。但必须强调：**在缺口补齐之前，不应把 Conjecture A.1 描述为"已形式化验证"。**

---

## 4. 构建方法（在具备 Lean/Mathlib 的机器上）

```bash
# 1) 安装 elan（会自带 lake）
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
# 2) 在本目录
cd 形式化
lake exe cache get      # 取 Mathlib 预编译缓存（若失败则 lake build 会很慢）
lake build              # 编译 ConjectureA1.lean
```

若 `lake build` 报错，最可能的三类（按概率排序）：

1. **Mathlib 名字漂移**：`smul_mul_assoc`、`Function.iterate_succ_apply'`、
   `Nat.descFactorial_succ`、`Finset.sum_range_succ'` 等在不同 Mathlib 版本中改名/换命名空间；
2. **实例缺失**：`Algebra ℚ R` 下 `ℚ • R` 与 `R` 的 `SMul`/`IsScalarTower` 实例有时需要
   显式 `haveI`；
3. **`noncomm_ring`/`abel` 的适用条件**：`noncomm_ring` 需要 `Ring`（本文件满足）。

请把编译错误贴回，我可以在有工具链的环境里逐条修复——这是唯一能把"未验证"变成"已验证"的途径。
