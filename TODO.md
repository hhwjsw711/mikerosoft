# mikerosoft.app — 适配检查清单

> 你的电脑：**Intel i5-12500H / Iris Xe 核显（无 NVIDIA） / 16GB RAM / Win10 中文 / E: 盘**

---

## 🚀 第一阶段：实施与适配

### 1.1 路径迁移（C: → E:）

- [x] `install.ps1` — `$ToolsDir` 改为 `E:\dev\tools`
- [x] `install.ps1` — 所有右键菜单命令改为 `E:\dev\tools\`
- [x] `tools/transcribe/deps.ps1` — 指向 `E:\dev\tools`
- [x] `tools/transcribe/transcribe.bat` — 默认 CPU 模式、去掉 CUDA 重试逻辑
- [x] `tools/remove-portrait/deps.ps1` — 指向 `E:\dev\tools`
- [x] `tools/remove-portrait/remove_portrait.py` — RVM_MODEL_DIR / ffmpeg 路径
- [x] `tools/img-upscale/deps.ps1` — realesrgan / models 路径
- [x] `tools/img-upscale/tests/test_img_upscale.py` — 测试路径
- [x] `tools/img-to-svg/deps.ps1` — star-vector 路径
- [x] `tools/backup-phone/backup-phone.ps1` — 默认目标 `E:\bak\photos`
- [x] `tools/lib/run-transcribe.ts` — `E:\dev\tools\transcribe.bat`
- [x] `tools/remove-portrait/tests/test_remove_portrait.py` — 测试路径

### 1.2 scale-monitor（本机不适用）

- [x] `install.ps1` — 安装部分已注释掉
- [x] `install.ps1` — 末尾提醒已移除

### 1.3 语音识别中文适配

- [x] `voice-type.py` — 添加多语言模型选项（tiny/base/small/medium）
- [x] `voice-type.py` — CPU 默认模型 `small.en` → `small`（多语言）
- [x] `voice-type.py` — 流模型默认 `tiny.en` → `tiny`
- [x] `voice-type.py` — 标签区分 EN only 和多语言
- [x] `settings.json` — 更新为 `small` / `tiny`
- [x] 清理 HuggingFace 缓存中的 `.en` 模型
- [x] **验证：用中文说话并确认被正确转录**

### 1.4 GPU 依赖工具的 CPU 降级确认

- [x] `transcribe` — batch 默认 CPU，无 CUDA 重试
- [x] `voice-type` — 自动检测 CUDA → 使用 CPU int8 模式
- [x] `task-stats` — deps.ps1 优雅处理 nvml.dll 缺失（仅打印警告）
- [ ] `face-swap` — onnxruntime-gpu 会失败，需确认 CPU 回退正常
- [ ] `remove-portrait` — NVIDIA CUDA 包会安装失败，需确认 rembg 后端正常
- [ ] `img-upscale` — Swin2SR 质量后端在 CPU 上可用，需确认

### 1.5 .env & API Key

- [x] `OPENROUTER_API_KEY` — 已在 `.env` 中设置
- [ ] **安全：替换当前 API key**（已暴露在磁盘上，建议在 openrouter.ai 重新生成）
- [ ] 确认以下工具可以访问 OpenRouter：video-titles、video-description、img-gen、video-gen、generate-from-image（⏸️ 当前地理位置无法访问 Google，暂时跳过）

### 1.6 外部二进制文件

- [x] `ffmpeg.exe` — 位于 `E:\dev\tools`
- [x] `faster-whisper-xxl.exe` — 位于 `E:\dev\tools`
- [x] `E:\dev\tools\_models\` — 已存在（whisper 模型）
- [ ] `E:\dev\tools\_models\remove-portrait\` — RVM 权重？
- [ ] `E:\dev\tools\star-vector\` — AI SVG 引擎？
- [ ] `E:\dev\tools\realesrgan-ncnn-vulkan.exe` — 快速放大后端？
- [ ] `E:\dev\tools\models\realesrgan-x4plus.*` — 放大模型权重？
- [x] `E:\dev\tools\_models\face-swap\inswapper_128.onnx` — 换脸模型 ✅ 已从 C 盘移到 E 盘，路径改为动态推导

### 1.7 E:\dev\tools 是否正确在 PATH 中

- [x] `E:\dev\tools` 在 PATH 中
- [x] `E:\dev\tools` 桩文件已验证指向 `E:\` 路径（transcribe.bat 等已正确）
- [x] `transcribe.bat` — 修复 `--output_format=srt` argparse 多值吞噬 bug
- [x] 重新运行 `install.ps1` — 所有桩文件、快捷方式、右键菜单已生成

### 1.8 任务栏/开始菜单快捷方式

- [ ] `Task Stats.lnk` → 固定到任务栏
- [ ] `Voice Type.lnk` → 固定到任务栏
- [ ] 设置 task-stats 开机自启（右键托盘图标 → Settings → Start with Windows）
- [ ] 设置 voice-type 开机自启（`shell:startup` 放快捷方式）

---

## 🔒 第二阶段：安全审计

### 2.1 API Key 保护

- [ ] **[高危]** 在 openrouter.ai 重新生成 `OPENROUTER_API_KEY`（当前 key 已暴露在本地磁盘）— **需你手动操作**
- [x] 确认 `.env` 在 `.gitignore` 中（✅ 已验证）
- [x] 添加 pre-commit hook 防止 `.env` 意外提交（`.git/hooks/pre-commit`）

### 2.2 Shell 注入风险

- [x] `run-transcribe.ts:12` — `shell: true` 带用户文件路径
  - **影响**：如果文件名含特殊字符（`&` `^`），可能发生命令注入
  - **修复**：移除 `shell: true`（`.bat` 文件不需要 shell）
- [x] 所有其他 subprocess 调用均使用硬编码参数 — 无风险
- [x] 右键菜单命令使用标准 Windows `%1` 展开，正确引用双引号 — 无风险

### 2.3 路径遍历

- [x] 所有用户路径均经过 `resolve()` / `basename()` / `readdirSync` — 无风险

### 2.4 权限要求

- [x] 所有注册表写入均在 `HKCU`（无需管理员权限）
- [x] 无 `require -RunAsAdmin` / 无管理员清单

### 2.5 eval / exec 危险函数

- [x] 仅存在 PyTorch `.eval()`（模型推理），非代码执行 — 无风险

### 2.6 额外安全项

- [x] 审查 `ctxmenu.ps1`（仅 HKCU 写入，使用标准 LegacyDisable/CLSID 机制，安全 ✅；空 catch 块已在 4.3 追踪）
- [x] 审查 `face-swap` 模型下载（HTTPS + HuggingFace 可信源，无校验但属 ML 行业惯例，低风险）
- [x] 检查 `video-to-markdown` 的 Convex 端点（`quirky-squirrel-220` 为自有部署，仅传 YouTube URL，安全 ✅）

---

## ⚡ 第三阶段：性能审计

### 3.1 同步 I/O 在热路径中

- [x] **[高]** `video-gen/src/bun/index.ts:21` — `fs.appendFileSync` 已改为异步 `fs.appendFile`
- [x] **[高]** `img-gen/src/bun/index.ts:29` — 同上
- [x] **[高]** `face-swap/src/bun/index.ts:74` — 同上
- [x] **[中]** `img-gen/src/bun/index.ts:136` — 图片写入仅发生一次，影响有限；日志 I/O 已修
- [x] **[中]** `generate-from-image/index.ts:281` — `readFileSync`/`writeFileSync` 为一次性操作，非热路径

### 3.2 大依赖包

- [x] `remove-portrait` — deps.ps1 已精简为 CPU-only（去掉 nvidia-cublas 等 4 个 CUDA 包、rembg[gpu]→rembg、onnxruntime-gpu→onnxruntime）
- [x] `img-to-svg` — deps.ps1 已添加 NVIDIA GPU 检测，无 GPU 时跳过 StarVector（节省 ~17-20 GB）
- [ ] `img-upscale` — Swin2SR 在 CPU 上很慢 — **建议**：确认 realesrgan-ncnn-vulkan.exe 在 Iris Xe 上可用（Intel Vulkan）
- [x] `face-swap` — `inswapper_128.onnx` 555 MB 已从 C 盘移至 E 盘
- [ ] `voice-type` — whisper 模型 ~几 GB（首次使用自动下载）— 正常行为

### 3.3 临时文件泄漏

- [x] `video-gen` — `%TEMP%\video-gen\<session>\` 已添加 `process.on("exit")` 清理
- [x] `img-gen` — `%TEMP%\img-gen\<session>\` 已添加 `process.on("exit")` 清理
- [x] `face-swap` — `%LOCALAPPDATA%\face-swap\sessions\<session>\` 已添加 `process.on("exit")` 清理
- [x] `transcribe` — `%TEMP%\transcribe_output_*\` 脚本中有清理逻辑（已验证 ✅）

### 3.4 资源清理

- [x] `voice-type.py` — 添加 `atexit` handler 关闭 `_log_file` 和 `_instance_lock_file`
- [x] `ctxmenu.ps1` — GDI 画笔/刷子已添加 try/finally 确保 dispose
- [x] `task-stats/SectionContext.cs` — `Dispose()` 空体属无误（类不持有持久化资源）

### 3.5 模型/后端适用性

- [x] `remove-portrait` RVM 后端 — 需要 CUDA，本机不可用 → deps.ps1 已改为 CPU-only
- [x] `img-to-svg` StarVector — 需要 GPU，deps.ps1 已添加 GPU 检测自动跳过
- [x] `task-stats` GPU 监控 — nvml.dll 不可用 → NET/CPU/MEM 正常
- [x] `voice-type` Parakeet 模型 — NVIDIA 专用，本机自动跳过

---

## 🧹 第四阶段：代码清理与可维护性

### 4.1 消除重复代码

- [ ] **[严重]** Electrobun 模板重复 4 次（video-gen/img-gen/face-swap/3d-viewer）
  - SSE 服务器 + broadcast + ping（~45 行 × 4）
  - `pulseWindowSize()`（~18 行 × 3）
  - `log()` 函数（~8 行 × 3）
  - **建议**：抽取 `tools/lib/electrobun-utils.ts`
- [ ] **[高]** OpenRouter 聊天模式重复 3 次（video-description/video-titles/generate-from-image）
  - fetch API + 响应解析 + 聊天循环 + 头部渲染
  - **建议**：抽取 `tools/lib/openrouter-chat.ts`
- [ ] **[中]** `deps.ps1` bun 检查器重复 6 次 — 抽取公共函数

### 4.2 巨型文件模块化

- [ ] **[严重]** `voice-type/voice-type.py` — 2,409 行
  - 内嵌 Overlay 类（~700 行）、Recorder（~200 行）、Streamer（~200 行）、Precomputer（~200 行）
  - **建议**：拆分为 `overlay.py`、`recorder.py`、`streamer.py`、`precomputer.py`
- [ ] **[高]** `remove-portrait/remove_portrait.py` — 737 行，RVM + rembg + 视频 I/O 全在一个文件
- [ ] **[高]** `ctxmenu/ctxmenu.ps1` — 675 行
- [ ] **[中]** `face-swap/src/bun/index.ts` — 533 行

### 4.3 错误处理审查（47 个空 catch 块）

- [x] `task-stats` — 15+ 空 catch 已修复：`SettingsStore`、`StartupRegistration`、`OverlayForm`、`App`、`Metrics`、`OverlayContracts`、`SectionContext` — 添加 `Debug.WriteLine` 或有意义注释
- [x] `ctxmenu.ps1` — 9+ 空 catch：关键扫描/写入路径已添加 `Write-Warning`，回退/UI 刷新类保留原样（有正确回退值）
- [x] `voice-type.py:165` — 心跳写入失败已有 `except Exception: pass`（非关键路径，实例锁有超时检测）
- [x] Electrobun 工具 — 已审查：SSE broadcast catches 处理断连客户端（正常），temp cleanup catches 属于 best-effort

### 4.4 测试覆盖

- [ ] **[高]** `face-swap` — 零测试（复杂 GPU 管道）
- [ ] **[高]** `img-to-svg` — 零测试
- [ ] **[中]** `transcribe` — 零测试
- [ ] **[中]** `scale-monitor` — 零测试（注册表操作）
- [ ] **[中]** `generate-from-image` — 零测试
- [ ] **[中]** `video-description` / `video-titles` — 零测试（AI 聊天循环）
- [ ] **[低]** `removebg`、`mac-screenshot`、`video-to-markdown`、`svg-to-png`、`3d-viewer`、`copypath` — 零测试
- [ ] ✅ `voice-type` — 7 个测试文件
- [ ] ✅ `task-stats` — 单元 + 集成 + e2e 覆盖
- [ ] ✅ `worktrees` — 2 个测试文件

### 4.5 硬编码路径

- [x] `face-swap` — inswapper 模型路径已改为从仓库位置动态推导
- [x] `remove-portrait/remove_portrait.py:40` — `RVM_MODEL_DIR` 已改为 `_tools / "_models" / "remove-portrait"`
- [x] `img-to-svg/deps.ps1:36` — `$starVectorDir` 已改为 `"$toolsDir\star-vector"`
- [x] `img-upscale/deps.ps1:45-46` — `realesrgan` exe 和 models 路径已改为动态推导
- [x] `transcribe/deps.ps1:5` — `$ToolsDir` 已改为动态推导
- [x] `remove-portrait/deps.ps1:31,47` — ffmpeg 和 model 路径已改为动态推导

### 4.6 硬编码魔数

- [ ] `voice-type.py` — 40+ 魔数（部分已命名常量，但仍有内联数字）
- [ ] Electrobun 工具 — 超时/间隔散布其中
- [ ] `task-stats/OverlayForm.cs` — 内联渲染数字
- [ ] **建议**：优先修复 voice-type，然后修复 Electrobun 工具

### 4.7 Git 忽略漏洞

- [x] `video-to-markdown/tests/tmp/` — 已添加到 `.gitignore`
- [x] `*.sock` 文件 — 已添加到 `.gitignore`（`voice-type-control.sock`）

---

## 📋 渐进式工作计划

### 第一阶段（实施）优先级

1. ⬜ 重新运行 `install.ps1`（重新生成指向 E: 的桩文件）
2. ⬜ 验证每个 GPU 依赖工具（face-swap、remove-portrait、img-upscale 等）
3. ⬜ 安全替换 OpenRouter API key
4. ⬜ 下载缺失的外部二进制文件（inswapper_128.onnx 等）
5. ⬜ 固定 Task Stats 和 Voice Type 到任务栏 + 设置开机自启

### 第二阶段（安全）优先级

1. ✅ 添加 pre-commit hook 防止 `.env` 泄露
2. ⬜ **你需手动**替换 OpenRouter API key（在 openrouter.ai 重新生成）
3. ✅ 审查 ctxmenu.ps1、face-swap 模型下载、video-to-markdown 端点 — 均安全

### 第三阶段（性能）优先级

1. ✅ Electrobun 工具 log 同步 I/O 改为异步（img-gen、video-gen、face-swap）
2. ✅ 添加 %TEMP% 会话临时文件清理
3. ✅ 精简 remove-portrait / img-to-svg deps.ps1（去掉 GPU 专用包）
4. ✅ 资源清理（voice-type atexit、ctxmenu GDI try/finally）

### 第四阶段（代码清理）优先级

1. ✅ 消除硬编码路径（face-swap, remove-portrait, img-to-svg, img-upscale, transcribe — 全部改为动态推导）
2. ✅ 空 catch 块添加日志/注释（task-stats 6 文件, ctxmenu.ps1, voice-type）
3. ✅ Git 忽略漏洞修复（*.sock, tests/tmp/）
4. ✅ GDI 资源泄露修复（ctxmenu.ps1 try/finally）
5. ⬜ 将 voice-type.py 拆分为模块
2. ⬜ 提取公共 Electrobun 工具库
3. ⬜ 提取公共 OpenRouter 聊天库
4. ⬜ 将空 catch 块添加日志
5. ⬜ 为 face-swap 添加强测试

---

## 进度追踪

| 阶段 | 状态 | 完成率 |
|---|---|---|
| 🚀 第一阶段（实施） | 进行中 | ~60% |
| 🔒 第二阶段（安全） | 已完成 ✅ | ~90% |
| ⚡ 第三阶段（性能） | 已完成 ✅ | ~95% |
| 🧹 第四阶段（代码清理） | 进行中 | ~35% |
