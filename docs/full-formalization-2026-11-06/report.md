# Conjecture A.1 完整形式化 — 2026-11-06

**FORMALLY_VERIFIED_PROOF：原猜想主定理的完整一般证明。**

## 实际根证明

```lean
ConjectureA1.vector_conjecture (K V : Type*)
  [Field K] [CharZero K] [AddCommGroup V] [Module K V] :
  ConjectureA1.VectorConjecture K V
```

展开后：对任意特征零域 K、任意 K-向量空间 V，X,Y∈End_K(V)，Z=XY−YX，
仅假设 XZ=ZX、YZ=ZY；全部自然 p,q 及 v 均满足

$$
X^{p+1}v=Y^{q+1}v=0\quad\Longrightarrow\quad (X+Y)^{2p+2q+1}v=0.
$$

包括零参数、零向量和零空间。没有将向量湮灭改为算子幂零，也没有加强为整个
End_K(V) 的中心性。实际入口在 [General.lean](../../formalization/General.lean)。
原契约来自 [Liu–Wu–Zhang–Zhou，Appendix A，Conjecture A.1](https://arxiv.org/pdf/1811.10137v2#page=42)。

## 闭合机制

本次保留正规序与加权直线方法，使用一个较强的有限支撑内核统一处理三类直线。

1. `Fewnomial.lean` 证明标量性质：若 f 的支持至多 m 项，且 (X−1)^m 整除 f，则 f=0。
   Euler 算子 Xf′−e f 消去一个支持指数，按 m 归纳；不需要预先建立 Vandermonde 矩阵。
2. `LineSystem.lean` 对有限序列 u 构造 U=Σu_b X^b/b!、H=(1−X)^(p+1)U。
   精确的阶乘系数恒等式把真实直线关系转换为 H 的中间系数消失。
   H 的支持位于 [lo,b0)∪(M,D+p+1]，基数至多 p+1，于是 H=U=0。
   通过全部对偶泛函升到任意向量空间，不要求 V 有限维。
3. `MonomialActions.lean` 从左侧锚点作用真正的右湮灭关系，得到固定范围的有限和；
   越界项由下降阶乘或二项式系数为零处理。
4. `WeightedLines.lean` 用自然下端点编码负直线。正差 d=A−B 时取
   lo=0、D=min(M,q)、b0=p+1−d；负差 −r 时取 lo=r、D=q、b0=p+1+r。
   M=B+k，截止权次数为奇数，排除零差；所有范围和支持计数在 Lean 中证明。
5. `General.lean` 以已经证明的稀疏性质和线内核消除辅助条件，证明全部截止单项式消失。
   对 X+Y 的三项左作用做加权归纳，得到根结论。

`SparseRootProperty` 和 `LineVanishing` 是模块接口定义。最终根不以它们为额外假设；
`vector_monomial_cutoff` 实际调用 `sparseRootProperty` 和 `line_vanish` 的证明。

## 实际机器检查

固定 Lean 4.31.0（编译器提交 68218e876d2a38b1985b8590fff244a83c321783）、
Mathlib fabf563a7c95a166b8d7b6efca11c8b4dc9d911f 及八个锁定传递依赖。
九个 checkout 的 HEAD、tracked-clean 状态及 Mathlib 工具链均检查通过。

- 12 个 material 模块全部重新编译，构建退出 0。
- 62/62 个引理/定理的传递公理集合已实际返回；没有缺失探针或未检查模块。
- `vector_conjecture` 的传递公理恰为 propext、Classical.choice、Quot.sound。
- 源码无 unfinished terms、自设公理、unsafe 或 native_decide。
- 最终 `validate.py` 报告 passed=true；不读取旧构建日志充当本次结果。

每个辅助义务先单模块编译，完成后整体 fresh build。早期审计生成器从注释中多抽出一个
不存在的名字，导致第一次整体审计失败；删除该额外探针后全量通过，62 个真实声明仍全部检查。
保留兼容 namespace 的既有 linter warning，不影响根证明。

复现命令见 [PROGRESS.md](../../formalization/PROGRESS.md)。现有外部 oleans 是可信预构建输入，
本轮没有重跑联网依赖获取、整个 Mathlib 的源码构建或第二种内核。

## 独立语义验收

[独立盲读](readback.md)从实际源与编译类型重建了根陈述，未读取外部目标。
另一审查者随后[对照原论文及契约](audit.md)，裁定 **PASS：完整原猜想与实际根一致，无剩余主定理义务**。
独立 [Guard](Guard.lean) 用原始交换子、独立宇宙和完整量词检查定义、两个根及 cutoff，
并编译原论文三算子形式；退出 0。10 项独立公理查询均仅含三个标准公理。

## 范围与复现边界

当前完整形式化的是原猜想主定理。一般张量最优性仍为已审书面结果，未在 Lean 编码。
显式三项式展开及万能代数的全部高次数命题未另行形式化，也不是当前根证明的未闭合依赖。

本次未改论文 TeX/PDF 或 Python 数学模型/验证脚本；相同输入的上一轮书面审查、21 页 PDF 验收及
精确回归证据继续适用。旧的不同 legacy proposition 保留作兼容，根证明不调用它。
旧分支和原始本地文件未重写；新公开内容不带机器路径、进程/会话标识或原始运行日志。

## 发布结果与唯一交付阻碍

完整证明提交 `75a895de210d3ca4ad9c3f534b21be6608304f6b` 已正常推送到
`xsoc1/conjecture-a1-proof` 的 `audit/a1-clean-2026-11-05` 分支，未重写旧分支。

遵守用户“完整形式化后再 PR”的要求，完成上述验收后重新通过原 GitHub 集成创建 draft PR，
仍返回 **HTTP 403：Resource not accessible by integration**。该调用没有创建 PR。
证明本身已经完整；剩余的是发布权限：连接所有者修复上游仓库的 PR 权限后，由本任务继续
创建同一 draft PR。没有绕用其他凭据，没有合并。
