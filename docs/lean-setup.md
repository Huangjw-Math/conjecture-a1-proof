# 固定版本与构建方法

版本：Lean `leanprover/lean4:v4.31.0`；Mathlib 提交
`fabf563a7c95a166b8d7b6efca11c8b4dc9d911f`。`lake-manifest.json` 固定传递依赖。

## 已有 elan 的标准路径

在 `formalization/` 运行：

```powershell
lake exe cache get
python validate.py
```

需要网络能获取固定工具链和依赖。此轮未重跑全部依赖的联网下载或 Mathlib 源码构建。
具体通过的构建入口和当前声明清单见 [PROGRESS.md](../formalization/PROGRESS.md)。

## 复用匹配版本的本地缓存

已有原生工具链和同一提交 Mathlib 缓存时，可在 PowerShell 设置本机位置：

```powershell
$leanBin = Join-Path $HOME '.elan/toolchains/leanprover--lean4---v4.31.0/bin'
$mathlibCache = $env:MATHLIB_CACHE
# MATHLIB_CACHE 应指向已有 Mathlib checkout，而不是其 build 子目录。
./formalization/build.ps1 -LeanBin $leanBin -MathlibCache $mathlibCache
python formalization/validate.py
```

脚本检查版本与缓存，调用 `lake -f lakefile.offline.lean build`。
项目源文件重新编译，项目生成物写入自身 `.lake/`；外部缓存仅作读取输入。
这条离线检查路径与从源码重建整个依赖库的范围不同。
原始编译日志保留在本机忽略目录；公开审查结论和准确范围见
[形式化进度](../formalization/PROGRESS.md)和[本轮报告](audit-2026-11-05/audit_report.md)。

`setup.ps1` 是可选的局部工具链获取辅助脚本；已有环境无需重装。
