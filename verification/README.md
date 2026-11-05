# 验证程序说明（数值核验，不是证明）

这些脚本对报告中的每个中间结论做**精确有理数**核验。全部使用 Python 标准库
（`fractions.Fraction`、`math.comb`），无需安装任何第三方包。

运行环境：Python 3.9+。在 PowerShell 中：

```powershell
$py = "C:\Users\Lenovo\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe"
& $py .\conj2.py        # 万能模 M_{p,q} 中的幂零指数（报告表 1）
& $py .\verify.py       # 三项式公式 + 正规序公式 + Z 幂零指数
& $py .\verify2.py      # 直线关系、三角形子式、少项式计数条件
& $py .\structure.py    # p=q=1, (1,2), (2,2) 的单多项式消失模式（报告表 3）
```

## 设定

$A=U(\mathfrak h_1)=\mathbb K\langle X,Y,Z\rangle/([X,Y]=Z,\ Z\ \text{中心})$，
PBW 基 $X^aY^bZ^k$，$I=AX^{p+1}+AY^{q+1}$，$M_{p,q}=A/I$。
由分次性 $M_d=A_d/I_d$，其中 $I_d=A_{d-p-1}X^{p+1}+A_{d-q-1}Y^{q+1}$，
故每一步都是有限维 $\mathbb Q$-线性代数。

## 主要结论（脚本输出）

1. `conj2.py`：对 $0\le p,q\le 6$（49 组），
   $\min\{n:(X+Y)^nv_0=0\}=2p+2q+1$，**恰为**猜想中的指数（既非更小，也不更大）。
2. `verify.py`：
   - 三项式公式 $(X+Y)^n=\sum_{a+b+2k=n}\frac{n!}{a!b!k!}(-\frac12)^kX^aY^bZ^k$，$n\le 8$ 全部成立；
   - $Y^BX^{p+1}$ 的正规序展开（直线关系的来源），$p,B\le 5$ 全部成立；
   - $Z$ 在 $M_{p,q}$ 中的幂零指数 $=p+q+1$。
3. `verify2.py`：
   - 直线关系 $(X^{A-p-1}Y^BZ^K)X^{p+1}=R(A,B,K)$ 在 $A$ 中逐项成立；
   - 情形 $\delta\ge p+1$ 与 $\delta\le-1$ 的系数矩阵（限制到未知量后）对 $p,q\le4$ 及一切 $\delta$
     均列满秩；显式给出三角形子式的行列式（例如 $(p,q,\delta)=(2,2,-1)$ 时 $1440$）；
   - 情形 $1\le\delta\le p$ 的少项式计数条件 $b_0+\max(0,D+p+1-M)\le p+1$ 对 $p,q\le5$ 全部成立。

## 注意

这些计算是**独立检验**，用于发现符号、指标、系数上的错误，**不构成证明**。
报告中的定理对一切 $p,q$ 有纯符号证明（第 4--5 节）。

## 补充脚本（sharpness 相关）

```powershell
& $py .\sharpness.py     # 反例模型 V=Q[x,eps]/(eps^{q+1}), X=d/dx, Y=eps*x, Z=eps, v=1
& $py .\pureZ_check.py   # 在 A 的 PBW 基上核验 a*X^(p+1) 的纯 Z 分量 = (-1)^(p+1)(p+1)! Z^(p+q)
```
