# 接续审查与形式化进展 — 2026-11-05

**书面一般证明和逐参数最优性成立；Lean 为经过编译的实质性部分结果。**
原猜想的任意正参数一般情形尚未完成形式化。

## 接续状态已独立核实

首次读取工作树为干净状态，HEAD 与 fork 的 `audit/lean-a1-2026-11-05`
均为 `f4fd26601025c86e99eea76401591756c7f1b98f`。重新 fetch 后，上游 main
仍为 `f8f7235dca197933cd97ac74b6d35d64f67e693d`；原分支恰好领先两个提交。

交付改用从上游 main 新建的 `audit/a1-clean-2026-11-05`，只迁入数学、代码和
可复现说明。原本地工作树、两个已推送提交和旧远端分支均保留，没有重写或强推。

## 书面证明的判断与修正

直接对照 [原文 Conjecture A.1，Appendix A](https://arxiv.org/pdf/1811.10137v2#page=42)：
K 为任意特征零域，V 任意维，Z=XY−YX，仅要求 XZ=ZX、YZ=ZY；对任意自然 p,q，

\[
X^{p+1}v=Y^{q+1}v=0\quad\Longrightarrow\quad (X+Y)^{2p+2q+1}v=0.
\]

没有把向量湮灭改为算子幂零，也没有要求 Z 位于整个 End(V) 的中心。

[独立数学审稿](paper-review.md)逐项核对 PBW 分次、左理想化归、纯 Z 单项式的
度传播、正规序系数、三类直线的锚点与边界、向量系数的标量化及原文 Serre 应用。
修订稿的这些步骤闭合。对每一对 p,q，张量模型给出

\[
(X+Y)^{2(p+q)}v=\frac{(2p+2q)!}{2^{p+q}}
\varepsilon_3^{\otimes p}\otimes e_1^{\otimes q}\ne0.
\]

空张量覆盖 p=q=0。因此所需一致指数恰为 2p+2q+1；不是从 49 例计算外推。

从旧分支保留并核实的修正包括：两处归纳系数、正确左理想模型、撤回错误的
单侧 Z 幂断言与个别 Z^k B_m 的充要阈值、向量多项式标量化、应用范围及一般最优性构造。
本轮进一步修正：

- **附带双边命题的底环假设。** 特征零环仍可有整数挠。
  `R=Z×M₂(F₂)`、`x=(0,E12)`、`y=(0,E21)` 给出 x²=y²=0、中心交换子，
  但 (x+y)^5=x+y≠0。两份 TeX 现在明确为特征零域上的结合代数，并解释整数系数的可逆性。
- **零参数的理想性质。** p=q=0 时 I 是双边增广理想，故将“一定不是双边理想”改为
  “一般不能视为双边理想”。主证明仍只用左理想性质。
- 将交换情形的 iff 明确限定到普适多项式环 K[X,Y]。
- 更正技术文档与附录中正规序公式的专门化参数和阶乘系数转换。
- 限定计算覆盖范围，删除未获得可核查记录的历史搜索断言，将一般最优性归于张量证明。
- 重排越界长公式，移除未使用的 mathrsfs 导入，重编两份 PDF。

## Lean 的准确范围

固定 Lean **4.31.0**、Mathlib **fabf563a7c95a166b8d7b6efca11c8b4dc9d911f**，
及锁文件中的八个传递依赖。九个 checkout 的 HEAD、tracked-clean 状态和 Mathlib
工具链均已核对。现有外部 `.olean` 作为可信预构建输入，只读使用。

旧 20 个声明已重新编译，本轮新增 17 个，累计 **37 个引理/定理**，包括：

- 任意 q 的 `vector_p_zero`：Xv=0、Y^(q+1)v=0 ⇒ (X+Y)^(2q+1)v=0。
- 任意 p 的对称 `vector_q_zero`；以及原有 p=q=1 的五次幂结论。
- `vector_boundary_or_le_one` 以原指数 2p+2q+1 合并上述范围。
- 一般环上的 `taylor`、`ad_iterate_pow`、`normal_order`。
- 任意 p、B 的 `vector_right_line_relation`，保留真正右湮灭因子所给出的带 (-Z)^j 关系。
- 边界向量模中的一般单项式与加权消失引理。

当前六个 material 模块 fresh compilation 全部成功；37/37 传递公理查询只有
`propext`、`Classical.choice`、`Quot.sound` 的子集。没有 unfinished term、额外公理、
`unsafe` 或 `native_decide`。扫描器的 quoted-identifier 编码缺陷也已修复，并有五组回归测试。
实际声明、证明机制与命令详见 [PROGRESS](../../formalization/PROGRESS.md)，
独立类型审读和契约比较单列于 [Lean 审查](lean-review.md)。

**剩余形式化义务：** 正参数直线族的索引与端点包装、外区三角消元、内区少项式重数及
向量支撑论证、一般主定理组装。一般三项式展开和张量最优性模型也未完整形式化。
`VectorConjecture` 仍是忠实的命题定义，不是一般定理。旧 ambient-centrality 定义仅为兼容保留。

## 实跑检查

| 检查 | 结果与范围 |
|---|---|
| `python verification/run_all.py` | 9/9 子脚本退出 0；十组 unittest 通过；49 对参数的精确商模计算及独立张量样本 |
| 故障路径 | 篡改真实系数预测、真实超时、`python -O` 均导致非零退出；在临时沙盒执行 |
| 左理想模型与覆盖 | 完整齐次左倍生成集；新增 144 个原仅打印的高次数 Z^k B_m 消失断言；详见 [exact-checks](exact-checks.md) |
| Lean | 六模块重新编译；37 个声明的公理探针全部返回；最终 validate 报告 passed=true |
| 独立语义审查 | 盲读全部 37 个实际声明；另一审查者比较原题，五个根接口与独立宇宙的 Guard 编译通过 |
| 扫描器回归 | 5/5 组通过，覆盖嵌套注释、普通/raw 字符串和 quoted identifiers |
| PowerShell | build/setup 源语法解析通过 |
| LaTeX/PDF | 两份最终源各成功编译两遍；15 页主报告、6 页技术文档；21 页渲染检查完成 |
| 发布差异 | `git diff --check` 通过；候选新增内容的隐私模式检查无命中 |

PDF 已替换为本次最终源码的输出。无缺字、未定义引用或越界公式；剩余的非关键
字体样式替代和本机 LaTeX 版本警告不影响所检查页面。旧基线 PDF 仍可从上游和保留分支取得。

## 运行模型与 Fast

当前实际会话记录显示 `gpt-6.1-sol`、reasoning `max`；各分工也显式选择相同模型和强度。
本地有效配置为 `service_tier=priority`，模型目录将其标为 **Fast**。
会话未提供独立的服务端 tier 回显，因此这里报告已配置的 Fast/priority，不报告实测加速比。
机器路径、启动参数和会话记录没有带入 PR。

## 未运行与交付边界

未运行完整联网依赖获取路线、Mathlib 全源码重建或独立替代内核。
可选 SymPy 证书发现程序本轮未重跑，Lean 中显式证书本身已经重新编译。
系统性新颖性检索和全部参考书的逐页核对未执行。
一般 Lean 根定理尚缺，上述已证明声明和书面数学结论的范围分别保留。

对旧两个提交的 200 个变更文件作了模式扫描，确认多份日志含机器路径、会话标识和启动细节；
支持的令牌模式没有匹配。新分支排除这些原始运行记录，将必要数学结论转为便携报告。
这不删除旧分支已经公开的数据，也不等于排除所有可能的密钥格式。若需清理旧远端历史，
仍须另行确定影响并获得重写授权。

原始运行输出只在被忽略的本地目录保留。复现入口：

```powershell
python verification/run_all.py
python -m unittest discover -s formalization -p test_validate.py
# LEAN_BIN 与 MATHLIB_CACHE 指向匹配版本的已有工具链和 checkout。
python formalization/validate.py --lean-bin $env:LEAN_BIN --mathlib-cache $env:MATHLIB_CACHE
```

交付方式为新分支的 draft PR，不合并；最终提交与 PR 标识以 Git/GitHub 的实际记录为准。
