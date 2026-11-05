# Conjecture A.1（Liu–Wu–Zhang–Zhou）的证明、sharp 性分析与形式化尝试

**English abstract.** This repository contains a complete proof of *Conjecture A.1* from
S.-Q. Liu, C.-Z. Wu, Y. Zhang, X. Zhou, *Drinfeld–Sokolov hierarchies and diagram automorphisms
of affine Kac–Moody algebras*, Comm. Math. Phys. **375** (2020) 785–832 (Appendix A):
if $X,Y,Z\in\operatorname{End}(V)$ satisfy $Z=[X,Y]=XY-YX$ with $Z$ central, and
$X^{p+1}v=Y^{q+1}v=0$, then $(X+Y)^{2p+2q+1}v=0$. Alongside the paper we ship
(a) a technical note collecting every tool used, (b) a rigorous sharpness analysis,
(c) exact rational-arithmetic verification scripts, and (d) a **partial** Lean 4
formalisation with a precise statement-by-statement gap report.

---

## 1. 一句话结论

$$X^{p+1}v=0,\quad Y^{q+1}v=0,\quad Z=[X,Y]\ \text{中心}
\qquad\Longrightarrow\qquad (X+Y)^{\,2p+2q+1}v=0 .$$

该命题**对一切 $p,q\ge 0$ 成立**（不是特例）；指数 $2p+2q+1$ 在
$p=0$ 或 $q=0$ 时**已被证明不能再改进**，在 $p,q\le 6$ 时**已精确验证**，
一般 $(p,q)$ 的最优性**尚未证明**（见 [`docs/general-vs-sharp.md`](docs/general-vs-sharp.md)）。

## 2. 状态声明（务必先读）

| 项目 | 状态 |
|---|---|
| 定理（Conjecture A.1，一切 $p,q\ge0$） | ✅ 书面证明完整（`report/ConjectureA1-proof.pdf` §5） |
| 技术文档（所用六类工具） | ✅ 完整，含证明与失效边界 |
| sharp 性：$p=0$ 或 $q=0$ | ✅ 严格证明（显式反例模型） |
| sharp 性：$p,q\le 6$ | ✅ 精确有理数验证（非证明） |
| sharp 性：一般 $(p,q)$ | ⚠️ **未证明**（有强证据） |
| Lean 4 形式化 | ⚠️ **部分完成**：仅第 1 层引理有证明文本，**未编译**；主定理只以 `def` 陈述 |

> **本仓库不包含机器验证的证明。** `formalization/` 中的 Lean 文件无 `sorry`、无公理，
> 但未在 Lean 中编译通过（作者环境无工具链）；缺口与路线见
> [`docs/formalization-notes.md`](docs/formalization-notes.md)。

## 3. 证明的结构（三段）

1. **化归**：取 Heisenberg 代数 $A=U(\mathfrak h_1)=\mathbb K\langle X,Y,Z\rangle/([X,Y]=Z,\ Z\text{ 中心})$，
   左理想 $I=AX^{p+1}+AY^{q+1}$。猜想 $\iff (X+Y)^{2p+2q+1}\in I$（万能模 $M=A/I$，$v_0=1+I$）。
2. **广义二项式定理（三项式公式）**：
   $(X+Y)^n=\sum_{a+b+2k=n}\frac{n!}{a!b!k!}\left(-\frac12\right)^kX^aY^bZ^k$，
   把 $(X+Y)^n$ 按 $Z$ 幂次分块，解释指数 $=2(p+q)+1$ 的来源。
3. **沿"直线"的线性代数**：按 $\delta=a-b$ 分线，用 $(X^{A-p-1}Y^BZ^K)X^{p+1}\in I$ 得到一阶方程组；
   三种情形（$\delta\ge p+1$ 下三角 / $1\le\delta\le p$ 少项式重数界 / $\delta\le-1$ 上三角）穷尽。

## 4. 目录结构与文件说明

> 仓库内文件名使用 ASCII（跨平台、避免 zip/编码问题），括号内为中文原题。

```
report/
  ConjectureA1-proof.pdf         主报告（14 页，含附录 A = 技术文档）
  TechnicalNotes-Methods.pdf     技术文档（6 页，独立可读）
  src/report.tex                 主报告 LaTeX 源码（xelatex + ctex）
  src/techdoc.tex                技术文档 LaTeX 源码
docs/
  general-vs-sharp.md            结论界定：一般性 vs sharp 性 vs 可改进情形（"两种情形"的精确区分）
  sharpness.md                   指数 sharp 性分析（含 p=0 反例证明、一般情形障碍）
  formalization-notes.md         形式化说明与差异：逐条对照表、8 项差异、缺口量化
  lean-setup.md                  Lean 环境安装与构建方案（含实测网络限制与绕过）
formalization/
  ConjectureA1.lean               Lean 4 源码（无 sorry / 无公理；未编译）
  lakefile.lean, lean-toolchain   Lake 工程与版本钉住
  setup.ps1, build.ps1           用 Node 下载 Lean（绕过 schannel）与编译脚本
verification/
  README.md                      脚本说明与运行方法
  conj2.py                       万能模中的极小幂零指数（表 1）、Hilbert 函数
  verify.py                      三项式公式、正规序公式、Z 幂零指数
  verify2.py                     直线关系、三角形子式、少项式计数条件
  structure.py                   单个单项式在 M_{p,q} 中的消失模式（表 3）
  sharpness.py                   sharp 性反例模型（(2q-1)!! 系数）
  pureZ_check.py                 a·X^{p+1} 的纯 Z 分量 = (-1)^{p+1}(p+1)!（PBW 精确核验）
scripts/
  push.ps1                       创建 GitHub 仓库并推送（需 PAT）
```

### 4.1 未上传的文件及原因（重要备注）

| 未上传 | 原因 |
|---|---|
| `lwzz.pdf`（原论文 PDF） | **受 Springer 版权保护**，不得转载；请按 DOI 获取：<https://doi.org/10.1007/s00220-019-03568-4> |
| `_tools/lwzz.txt`（从该 PDF 提取的全文） | 与上同属版权内容，且为中间产物 |
| `*_tex/*.aux, *.log, *.toc, *.out` | LaTeX 构建产物（可由源码重生成） |
| `形式化/.leanenv/`、`.lean/` | Lean 工具链下载物（约 860 MB，不宜入库） |
| `probe.py`、`run_check3.py`、`check4.py` | 一次性探索脚本，结论已并入 `verification/` 中保留的脚本 |

## 5. 复现方法

**报告（需要 TeX Live + ctex + XeLaTeX）**

```bash
cd report/src
xelatex report.tex && xelatex report.tex
xelatex techdoc.tex && xelatex techdoc.tex
```

**数值核验（只需 Python 3.9+ 标准库，精确有理数）**

```bash
cd verification
python conj2.py        # 表 1：min{n : (X+Y)^n·1 = 0} = 2p+2q+1，p,q ≤ 6
python verify.py       # 三项式公式 / 正规序公式 / Z 的幂零指数
python verify2.py      # 直线关系、三角形子式、少项式计数
python sharpness.py    # sharp 性反例模型
python pureZ_check.py  # 纯 Z 分量
```

**Lean（可选；需先装工具链，见 `docs/lean-setup.md`）**

```powershell
cd formalization
.\setup.ps1 -LeanVersion 4.35.0     # 约 860 MB，用 Node 下载
.\build.ps1
```

> 注：本机 git 的 `http.sslBackend=schannel` 在此环境失效，仓库已把
> `http.sslBackend=openssl` 写入 **本地** `.git/config`（不改全局配置）。

## 6. 引用

见 [`CITATION.cff`](CITATION.cff)。若引用其中的数学结果，请同时引用原论文：

```bibtex
@article{LWZZ2020,
  author  = {Liu, Si-Qi and Wu, Chao-Zhong and Zhang, Youjin and Zhou, Xu},
  title   = {Drinfeld--Sokolov hierarchies and diagram automorphisms of affine Kac--Moody algebras},
  journal = {Communications in Mathematical Physics},
  volume  = {375}, pages = {785--832}, year = {2020},
  doi     = {10.1007/s00220-019-03568-4}
}
```

## 7. 许可

MIT（见 [`LICENSE`](LICENSE)）。PDF/文档内容请以学术规范引用。
