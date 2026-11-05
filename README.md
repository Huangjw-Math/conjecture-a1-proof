# Conjecture A.1（Liu–Wu–Zhang–Zhou）的证明、sharp 性分析与形式化尝试

> **2026-11-05 接续审查。** 主证明与全参数最优性构造已重新独立审查，并修复附命题的底环假设和零参数措辞。两份 PDF 已从本次 TeX 重编。Lean 新增任意零参数边界家族；一般主定理仍未完成形式化。详见[本轮报告](docs/audit-2026-11-05/audit_report.md)。

**English abstract.** This repository contains a complete proof of *Conjecture A.1* from
S.-Q. Liu, C.-Z. Wu, Y. Zhang, X. Zhou, *Drinfeld–Sokolov hierarchies and diagram automorphisms
of affine Kac–Moody algebras*, Comm. Math. Phys. **375** (2020) 785–832 (Appendix A):
For a vector space over any characteristic-zero field, if
$X,Y,Z\in\operatorname{End}(V)$ satisfy $Z=[X,Y]=XY-YX$, $XZ=ZX$, $YZ=ZY$, and
$X^{p+1}v=Y^{q+1}v=0$ for natural $p,q$, then $(X+Y)^{2p+2q+1}v=0$. Alongside the paper we ship
(a) a technical note collecting every tool used, (b) an all-parameter tensor-model proof of sharpness,
(c) exact rational-arithmetic verification scripts, and (d) a compiled **partial** Lean 4
formalisation with a precise statement-by-statement gap report.

---

## 1. 一句话结论

在任意特征零域上的任意向量空间中，

$$X^{p+1}v=0,\quad Y^{q+1}v=0,\quad Z=[X,Y],\quad XZ=ZX,\ YZ=ZY
\qquad\Longrightarrow\qquad (X+Y)^{\,2p+2q+1}v=0 .$$

该命题**对一切 $p,q\ge 0$ 成立**；修正后的书面证明保持原假设。指数 $2p+2q+1$
对每一对参数都**不能改进**，由显式张量模型证明；$p,q\le6$ 的 49 例也已重新精确验证
（见 [`docs/sharpness.md`](docs/sharpness.md) 与[审稿记录](docs/audit-2026-11-05/paper-review.md)）。

## 2. 状态声明（务必先读）

| 项目 | 状态 |
|---|---|
| 定理（Conjecture A.1，一切 $p,q\ge0$） | ✅ 修正后的 TeX 书面证明获独立数学审稿 PASS |
| 技术文档 | ✅ TeX 中系数、归纳方向、少项式说明和范围已修正 |
| sharp 性：$p=0$ 或 $q=0$ | ✅ 严格证明（显式反例模型） |
| sharp 性：$p,q\le 6$ | ✅ 精确有理数验证（非证明） |
| sharp 性：一般 $(p,q)$ | ✅ 张量模型给出一般书面证明，含零参数 |
| Lean 4 形式化 | ✅ **部分已编译**：一般辅助引理、$p=0$ 或 $q=0$ 的任意参数家族及 $p=q=1$；一般目标仍为 `def` |

> **一般 Conjecture A.1 尚未完整形式化。** 已证明家族使用原假设的局部交换性和向量湮灭条件；
> 未使用 `sorry`、额外公理或 `native_decide`。标准公理集合、真实编译命令、声明范围与剩余义务见
> [`formalization/PROGRESS.md`](formalization/PROGRESS.md)、[形式化说明](docs/formalization-notes.md)
> 和[独立 Lean 审计](docs/audit-2026-11-05/lean-review.md)。


## 3. 证明的结构（三段）

1. **化归**：取 Heisenberg 代数 $A=U(\mathfrak h_1)=\mathbb K\langle X,Y,Z\rangle/([X,Y]=Z,\ Z\text{ 中心})$，
   左理想 $I=AX^{p+1}+AY^{q+1}$。猜想 $\iff (X+Y)^{2p+2q+1}\in I$（万能模 $M=A/I$，$v_0=1+I$）。
2. **辅助的广义二项式定理（三项式公式）**（主证明可直接用次数消失闭合）：
   $(X+Y)^n=\sum_{a+b+2k=n}\frac{n!}{a!b!k!}\left(-\frac12\right)^kX^aY^bZ^k$，
   把 $(X+Y)^n$ 按 $Z$ 幂次分块，解释指数 $=2(p+q)+1$ 的来源。
3. **沿"直线"的线性代数**：按 $\delta=a-b$ 分线，用 $(X^{A-p-1}Y^BZ^K)X^{p+1}\in I$ 得到一阶方程组；
   三种情形（$\delta\ge p+1$ 下三角 / $1\le\delta\le p$ 少项式重数界 / $\delta\le-1$ 上三角）穷尽。

## 4. 目录结构与文件说明

> 仓库内文件名使用 ASCII（跨平台、避免 zip/编码问题），括号内为中文原题。

```
report/
  ConjectureA1-proof.pdf         本次修订 TeX 生成并检查的主报告 PDF
  TechnicalNotes-Methods.pdf     本次修订 TeX 生成并检查的技术文档 PDF
  src/report.tex                 主报告 LaTeX 源码（xelatex + ctex）
  src/techdoc.tex                技术文档 LaTeX 源码
docs/
  general-vs-sharp.md            结论界定：一般性 vs sharp 性 vs 可改进情形（"两种情形"的精确区分）
  sharpness.md                   全参数张量最优性构造及历史路线的界限
  formalization-notes.md         真实形式化范围、陈述差异与剩余义务
  lean-setup.md                  固定版本与两种构建路径
formalization/
  ConjectureA1.lean               已编译的一般辅助引理、忠实目标定义及历史说明
  SpecialCases.lean, VectorCases.lean  已核验的有限恒等式和四个向量特例
  BoundaryCases.lean              任意 p=0 或 q=0 的向量定理
  NormalOrder.lean                一般 Taylor、正规序及向量直线关系
  PROGRESS.md                    形式化范围、版本、命令和未完成义务
  lakefile.lean, lean-toolchain   Lake 工程与版本钉住
  setup.ps1, build.ps1           可选工具链获取与固定版本编译入口
verification/
  README.md                      脚本说明与运行方法
  conj2.py                       万能模极小指数，实际覆盖 49 例；诊断脚本另给 Hilbert 函数
  verify.py                      三项式公式、正规序公式、Z 幂零指数
  verify2.py                     直线关系、三角形子式、少项式计数条件
  structure.py                   单个单项式在 M_{p,q} 中的消失模式（表 3）
  sharpness.py                   sharp 性反例模型（(2q-1)!! 系数）
  pureZ_check.py                 a·X^{p+1} 的纯 Z 分量 = (-1)^{p+1}(p+1)!（PBW 精确核验）
  run_all.py, audit_checks.py     全部脚本的退出状态检查与针对已发现错误的回归检查
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
xelatex -halt-on-error -output-directory=.. -jobname=ConjectureA1-proof report.tex
xelatex -halt-on-error -output-directory=.. -jobname=ConjectureA1-proof report.tex
xelatex -halt-on-error -output-directory=.. -jobname=TechnicalNotes-Methods techdoc.tex
xelatex -halt-on-error -output-directory=.. -jobname=TechnicalNotes-Methods techdoc.tex
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

**Lean（已固定 Lean 4.31.0 与 Mathlib 提交；见 `docs/lean-setup.md`）**

```powershell
cd formalization
lake exe cache get
python validate.py
```

> 当前实际通过的是固定版本的离线 Lake 检查目标，复用本机只读 Mathlib 缓存；上面的联网安装路径未在本次重跑。
> `build.ps1` 的缓存参数、实际命令和日志见 `formalization/PROGRESS.md`。精确 Python 全量检查可从仓库根目录运行 `python verification/run_all.py`。

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
