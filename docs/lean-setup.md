# Lean 环境安装与形式化构建方案

> 本文件给出**可执行**的安装/构建方案，并记录本会话实测到的网络限制与绕过办法。
> 目标：把《报告_ConjectureA1的证明》的证明链在 Lean 4 + Mathlib 中真正编译通过。

## 0. 本会话实测的环境结论（重要）

| 通道 | 结果 | 说明 |
|---|---|---|
| `Invoke-WebRequest https://github.com` | ❌ `接收时发生错误` | Windows PowerShell 5.1 + schannel，TLS 握手失败 |
| 强制 TLS 1.2 后重试 | ❌ 仍失败 | 不是协议版本问题 |
| `curl.exe https://...` | ❌ `schannel: AcquireCredentialsHandle failed: SEC_E_NO_CREDENTIALS` | 沙箱未授予安全凭据访问 |
| TCP 443 连通性 | ✅ | 网络本身通 |
| **Node.js `https` 模块** | ✅ **status 200** | **唯一可用通道** |
| `elan-init.exe` 初始化 | ⚠️ 部分成功（生成了 `bin/`），`.elan` 写入受沙箱限制 | 见 §1.2 的 `ELAN_HOME` 处理 |

**因此：下载必须走 Node.js。** 本目录的 `setup.ps1` 就是这么做的（已实测：用 Node 成功下载
`elan-x86_64-pc-windows-msvc.zip` 2.5 MB（完整）、并成功查询 GitHub API 的 release 资产列表）。

## 1. 方案 A（推荐）：Lean 工具链 + Mathlib

### 1.1 体积与时间预估

| 项目 | 体积 | 备注 |
|---|---|---|
| Lean 4 工具链（`lean-4.x.y-windows.zip`） | **约 850 MB** | 实测 release 资产：`lean-4.35.0-windows.zip` = 860 MB |
| Mathlib 源码（tarball） | 约 60 MB | `github.com/leanprover-community/mathlib4/archive/refs/tags/vX.Y.Z.tar.gz` |
| Mathlib 预编译缓存（`.olean`） | 约 4–6 GB | 否则需本地编译 **数小时** |
| 依赖包（batteries / Qq / aesop / proofwidgets / importGraph / Cli） | 约 100 MB | 可由 tarball 手动放入 `.lake/packages/` |

### 1.2 步骤（`setup.ps1` 已实现 1–3 步）

```powershell
# 1) 用 Node 下载 Lean 工具链并解压到工作区（避免写入用户目录）
#    资产名形如：lean-4.35.0-windows.zip
.\setup.ps1 -LeanVersion 4.35.0

# 2) 把 lean.exe / lake.exe 加入当前会话 PATH
$env:PATH = "D:\...\形式化\.lean\lean-4.35.0-windows\bin;" + $env:PATH
lean --version      # 期望输出 Lean (version 4.35.0, ...)

# 3) （可选）Mathlib：下载源码 tarball + 依赖到 .lake/packages（需与 lean-toolchain 匹配）
.\setup.ps1 -LeanVersion 4.35.0 -WithMathlib

# 4) 编译
.\build.ps1 -File ConjectureA1.lean -Mathlib
```

**关键点**

* `ELAN_HOME` 必须指向**工作区内**目录，否则沙箱拒绝写入 `%USERPROFILE%\.elan`（实测 error 5）；
* `elan-init.exe -y --no-modify-path` 可避免改注册表/PATH；若仍失败，直接用 §1.2 的
  "下载工具链 zip + 解压 + 手动加 PATH" 路线（不依赖 elan 的 TLS）；
* `lake exe cache get` 需要访问 Azure/AWS 缓存（可能同样被 schannel 阻断）。若阻断，
  用 Node 下载 `mathlib4` 对应 commit 的 `.olean` 包并解压到 `mathlib/.lake/build/lib/`。

### 1.3 版本匹配（最容易踩的坑）

`lean-toolchain`、Mathlib 的 `lean-toolchain`、以及 Mathlib 缓存必须**严格一致**。
本目录的 `lean-toolchain` 写的是 `leanprover/lean4:v4.15.0`，请替换成你要用的 Mathlib 版本
（查 `mathlib4` 仓库根目录的 `lean-toolchain` 文件）。

## 2. 方案 B（轻量）：只用 Lean 核心，不用 Mathlib

若不想下载 4–6 GB 缓存，可以只用 Lean 4 核心（`Init`/`Std`，约 850 MB 工具链即可），
代价是**需要自己定义环结构**（核心库没有 `Ring`/`Module` 类型类）。可行性评估：

| 需要的构件 | 核心库有无 | 工作量 |
|---|---|---|
| `Nat`、`Nat.choose`、`Nat.descFactorial` | ✅ 有 | — |
| `Finset`、`Finset.sum` | ❌ 无（只有 `List`/`Array`） | 需自写 `List.sum`/`range` |
| `Ring`/`Algebra`/`Module` 类型类 | ❌ 无 | 需自定义（约 100–200 行） |
| `simp`/`omega`/`decide` 战术 | ✅ 有 | — |
| `ring`/`noncomm_ring`/`abel` | ❌ 无 | 需手工 `rw` 重写 |

**结论**：方案 B 能省下载，但证明长度会膨胀 3–5 倍，**不建议**用于本项目的完整形式化，
只适合验证 §3 的局部引理。

## 3. 形式化的实际推进顺序（每步都应 `lake build` 通过后再前进一步）

| 阶段 | 内容 | 预计 |
|---|---|---|
| 1 | `ad` 是导子（已在 `ConjectureA1.lean` 中给出证明文本） | 0.5 天（主要是 API 对齐） |
| 2 | `taylor`（Taylor 展开）+ `ad_iterate_y_pow` | 3–5 天 |
| 3 | `z_pow_mul_x_pow`（降 $J$ 归纳）+ `trinomial`（三项式公式） | 1–2 周 |
| 4 | `two_sided`（**双边定理**，报告命题 4.5） | 3–5 天 |
| 5 | $A=U(\mathfrak h_1)$ 的具体模型 + PBW 基 + 次数分次 | **3–6 周（瓶颈）** |
| 6 | 左理想 $I$ 的成员判定 + 直线关系 + 三角形子式 | 2–3 周 |
| 7 | 少项式界 + 模值多项式的线性泛函化 | 2–3 周 |
| 8 | 组装 `ConjectureA1`（主定理） | 1 周 |

（阶段 1–4 与 5–8 可以并行；5 是三期工程，Mathlib 目前没有 $U(\mathfrak h_1)$ 的 PBW 基。）

## 4. 我现在能/不能做什么（边界声明）

* **能**：给出全部 Lean 声明与证明路线（已在 `ConjectureA1.lean` 中）；
  给出并实测下载通道（Node.js）与安装脚本；
  在**有工具链的环境**里逐条修编译错误（这是纯机械循环）。
* **不能**（本会话）：下载 850 MB 工具链 + 4–6 GB Mathlib 缓存并完成 3–4 人月的形式化工作；
  因此**不能**声称 Conjecture A.1 已被机器验证。

**最省事的下一步**：在本机运行 `.\setup.ps1 -LeanVersion <版本>`（约 850 MB 下载），
把 `lean --version` 的输出贴回；我就可以开始阶段 1–2 的编译-修复循环。
