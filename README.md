<p align="center">
  <img src="https://img.shields.io/badge/version-7.7-blue?style=flat-square" alt="version">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="license">
  <img src="https://img.shields.io/badge/platform-OpenWrt%20%7C%20OpenClash-orange?style=flat-square" alt="platform">
  <img src="https://img.shields.io/badge/CI-passing-brightgreen?style=flat-square" alt="CI">
</p>

# 🛡️ OpenClash SafeOps Skill

> **AI Agent 安全运维 OpenClash 的技能包 — 诊断、修复、审计、脱敏报告，所有操作零 OpenWrt 系统风险。**

<a id="english"></a>

## 🇬🇧 English

### 🎯 What It Does

A WorkBuddy / OpenClaw AI Agent skill for safely diagnosing, repairing, and auditing [OpenClash](https://github.com/vernesong/OpenClash) on OpenWrt routers — without ever touching network, DHCP, or firewall system configs.

### ✨ Core Features

- 🔍 **Read-Only Diagnosis First** — Always diagnose before acting; 32 scripts, all safe-by-default
- 🩺 **DNS Conflict Audit** — Detect SmartDNS/Dnsmasq/OpenClash DNS collision patterns
- 📡 **Subscription Health Check** — Verify proxy provider URLs, expiry, and update failures
- 🔒 **Multi-Subscription Protection** — Never merge airports; preserve 1:1 subscription-to-config mappings
- 🔗 **Active Config Binding Audit** — Detect when OpenClash auto-switches between provider configs and the `config_update_url` is inconsistent
- 📋 **Aethersailor Template Application** — Generate single-file candidate YAMLs following [Aethersailor/Custom_OpenClash_Rules](https://github.com/Aethersailor/Custom_OpenClash_Rules) patterns
- 🔐 **Unified Redaction** — 8 sensitive-field mask modes (URL, password, token, API key, Bearer, secret, dashboard path); applied to all reports automatically
- 📝 **Redacted Report Generation** — Every workflow ends with `openclash_fix_report.md` + timestamped backup
- 🏗️ **Upstream Reference Hardening** — Authority-graded upstream source index with safe translation rules; runtime-fetch-and-execute is forbidden
- 📚 **Shared Shell Library** — `lib_safeops.sh` with POSIX-sh redaction, backup, validation, and guard functions
- 🔄 **CI Pipeline** — `.github/workflows/ci.yml` with pyc regression check, YAML frontmatter validation, YAML lint, and ShellCheck

### 📁 Directory Structure

```
openclash-safeops/
├── SKILL.md                    # Main skill instructions
├── README.md                   # This file
├── LICENSE                     # MIT License
├── .gitignore
├── .editorconfig / .prettierrc / .yamllint
├── scripts/                    # 32 executable scripts
│   ├── lib_safeops.sh          #    Shared shell function library
│   ├── openclash_diagnose.sh   #    Read-only diagnosis
│   ├── openclash_redact.py     #    Unified redaction (8 modes)
│   ├── openclash_report_writer.py  #  Report generator
│   ├── openclash_active_binding_audit.sh  # Binding consistency
│   └── ... (28 more)
├── references/                 # 12 reference documents
│   ├── document-index.md       #    Full doc map
│   ├── scripts-reference.md    #    Script risk levels
│   ├── upstream-sources.md     #    Authority-graded source index
│   ├── skill-authoring.md      #    Skill packaging rules
│   ├── reporting.md            #    Report generation workflow
│   ├── aethersailor-current-safe.md  # Template guide
│   └── ...
├── templates/                  # YAML template fragments
├── docs/kb/                    # 30+ knowledge base articles
├── examples/                   # 11 usage examples
├── tools/                      # CI/validation tools
│   └── check_skill_frontmatter.py
└── .github/workflows/
    └── ci.yml                  # CI pipeline
```

### 🚀 Quick Start

**Install as a WorkBuddy Skill:**

1. Download `openclash-safeops-skill-v7.7.zip` from [Releases](https://github.com/yjw8448/openclash-safeops-skill/releases)
2. In WorkBuddy → Skills → Import → select the zip
3. Or place the folder under `~/.workbuddy/skills/openclash-safeops/`

**For OpenClaw / other AI agents:**
Place the skill folder in your agent's skills directory and configure the SKILL.md as a system instruction.

### 🧪 Typical Use Cases

```
User: "OpenClash 挂了，帮我看看"
→ Diagnosis → Subscription health check → Report

User: "DNS 解析有问题"
→ DNS conflict audit → Identify collision → Suggest fix

User: "按 Aethersailor 规则配置我的 config.yaml"
→ Template mode → Generate candidate → Lint → User approval → Apply

User: "两个机场的配置混在一起了"
→ Multi-sub audit → Binding audit → Quarantine unbound configs

User: "LuCI 显示无订阅信息"
→ No-subinfo audit → Fingerprint → Identify source → Report
```

### 🛡️ Safety Guarantees

| Guarantee | How |
|-----------|-----|
| 🔴 Never modify `network/dhcp/firewall` | Absolute rule; scripts enforce it |
| 🟡 Write-capable scripts need explicit `--apply` + env var | `I_UNDERSTAND_SAFEOPS_WRITE=1` |
| 🟢 Always backup before write | `openclash_backup.sh` runs first |
| 🔐 All reports redacted | 8-mode unified redaction pipeline |

### 📚 References

| Source | Authority | Link |
|--------|-----------|------|
| 🏛️ OpenClash Wiki | Highest | [vernesong/OpenClash/wiki](https://github.com/vernesong/OpenClash/wiki) |
| 🏛️ OpenWrt Docs | Highest | [openwrt.org/docs](https://openwrt.org/docs/start) |
| 🏛️ Mihomo/MetaCubeX | Highest | [wiki.metacubex.one](https://wiki.metacubex.one/en/config/) |
| 📘 Agent Skills Spec | High | [agentskills.io](https://agentskills.io/specification) |
| 📗 Aethersailor Rules | Medium | [Aethersailor/Custom_OpenClash_Rules](https://github.com/Aethersailor/Custom_OpenClash_Rules/wiki/OpenClash-%E8%AE%BE%E7%BD%AE%E6%96%B9%E6%A1%88) |
| 📗 FFAni Config Guide | Medium | [ffani.com](https://ffani.com/post/openwrt-openclash-recommended-config-guide/) |

> Full authority-graded index with safe translation rules: [`references/upstream-sources.md`](references/upstream-sources.md)

### 📄 License

MIT — see [LICENSE](LICENSE).

---

<a id="chinese"></a>

## 🇨🇳 中文

### 🎯 功能简介

面向 WorkBuddy / OpenClaw 等 AI Agent 的 OpenClash 安全运维技能包，能在 OpenWrt 路由器上安全诊断、修复、审计 OpenClash — **全程不碰 network、dhcp、firewall 系统配置**。

### ✨ 核心特性

- 🔍 **只读诊断优先** — 先诊断再动手；32 个脚本默认全部只读
- 🩺 **DNS 冲突审计** — 检测 SmartDNS/Dnsmasq/OpenClash 三者 DNS 冲突
- 📡 **订阅健康检查** — 验证机场 URL 可达性、过期时间、更新失败原因
- 🔒 **多订阅保护** — 绝不合并机场；保留 1:1 订阅→配置映射
- 🔗 **活跃配置绑定审计** — 检测 OpenClash 自动切换配置导致 `config_update_url` 不一致的问题
- 📋 **Aethersailor 模板应用** — 参考 [Aethersailor/Custom_OpenClash_Rules](https://github.com/Aethersailor/Custom_OpenClash_Rules) 生成单文件候选 YAML
- 🔐 **统一脱敏** — 8 种敏感字段脱敏模式（URL、密码、Token、API Key、Bearer、Secret、Dashboard 路径）；所有报告自动脱敏
- 📝 **脱敏报告生成** — 每次工作流结束时生成 `openclash_fix_report.md` + 时间戳快照
- 🏗️ **上游引用硬化** — 权威分级的参考源索引 + 安全翻译规则；禁止运行时抓取并执行外部内容
- 📚 **共享 Shell 函数库** — `lib_safeops.sh` 提供 POSIX sh 脱敏、备份、校验、守卫函数
- 🔄 **CI 流水线** — `.github/workflows/ci.yml` 含 pyc 回归检查、YAML frontmatter 校验、YAML lint、ShellCheck

### 📁 目录结构

```
openclash-safeops/
├── SKILL.md                    # 技能主指令
├── README.md                   # 本文件
├── LICENSE                     # MIT 许可证
├── .gitignore
├── .editorconfig / .prettierrc / .yamllint
├── scripts/                    # 32 个可执行脚本
│   ├── lib_safeops.sh          #    共享 Shell 函数库
│   ├── openclash_diagnose.sh   #    只读诊断
│   ├── openclash_redact.py     #    统一脱敏（8 种模式）
│   ├── openclash_report_writer.py  #  报告生成器
│   ├── openclash_active_binding_audit.sh  # 活跃配置一致性审计
│   └── ... (共 28 个其他脚本)
├── references/                 # 12 篇参考文档
│   ├── document-index.md       #    完整文档索引
│   ├── scripts-reference.md    #    脚本风险等级
│   ├── upstream-sources.md     #    权威分级参考源
│   ├── skill-authoring.md      #    Skill 打包规范
│   ├── reporting.md            #    报告生成工作流
│   ├── aethersailor-current-safe.md  # Aethersailor 模板指南
│   └── ...
├── templates/                  # YAML 模板片段
├── docs/kb/                    # 30+ 篇知识库文章
├── examples/                   # 11 个使用示例
├── tools/                      # CI/校验工具
│   └── check_skill_frontmatter.py
└── .github/workflows/
    └── ci.yml                  # CI 流水线
```

### 🚀 快速安装

**WorkBuddy 技能安装：**

1. 从 [Releases](https://github.com/yjw8448/openclash-safeops-skill/releases) 下载 `openclash-safeops-skill-v7.7.zip`
2. WorkBuddy → 技能 → 导入 → 选择 zip 文件
3. 或手动放置到 `~/.workbuddy/skills/openclash-safeops/`

**OpenClaw / 其他 AI Agent：**
将技能文件夹放入 agent 的 skills 目录，并将 SKILL.md 配置为系统指令。

### 🧪 典型使用场景

```
用户："OpenClash 挂了，帮我看看"
→ 诊断 → 订阅健康检查 → 报告

用户："DNS 解析有问题"
→ DNS 冲突审计 → 定位冲突源 → 建议修复

用户："按 Aethersailor 规则配置我的 config.yaml"
→ 模板模式 → 生成候选 → Lint → 用户确认 → 应用

用户："两个机场的配置混在一起了"
→ 多订阅审计 → 绑定审计 → 隔离无绑定配置

用户："LuCI 显示无订阅信息"
→ 无订阅审计 → 指纹识别 → 溯源 → 报告
```

### 🛡️ 安全保障

| 保障 | 实现方式 |
|------|---------|
| 🔴 绝不修改 `network/dhcp/firewall` | 绝对规则，脚本强制执行 |
| 🟡 写入脚本需显式 `--apply` + 环境变量 | `I_UNDERSTAND_SAFEOPS_WRITE=1` |
| 🟢 写入前自动备份 | `openclash_backup.sh` 先执行 |
| 🔐 全部报告脱敏 | 8 模式统一脱敏流水线 |

### 📚 参考资料

| 参考源 | 权威等级 | 链接 |
|--------|----------|------|
| 🏛️ OpenClash Wiki | 最高 | [vernesong/OpenClash/wiki](https://github.com/vernesong/OpenClash/wiki) |
| 🏛️ OpenWrt 官方文档 | 最高 | [openwrt.org/docs](https://openwrt.org/docs/start) |
| 🏛️ Mihomo/MetaCubeX | 最高 | [wiki.metacubex.one](https://wiki.metacubex.one/en/config/) |
| 📘 Agent Skills 规范 | 高 | [agentskills.io](https://agentskills.io/specification) |
| 📗 Aethersailor 规则 | 中 | [Aethersailor/Custom_OpenClash_Rules](https://github.com/Aethersailor/Custom_OpenClash_Rules/wiki/OpenClash-%E8%AE%BE%E7%BD%AE%E6%96%B9%E6%A1%88) |
| 📗 FFAni 配置指南 | 中 | [ffani.com](https://ffani.com/post/openwrt-openclash-recommended-config-guide/) |

> 完整权威分级索引与安全翻译规则：[`references/upstream-sources.md`](references/upstream-sources.md)

### 📄 许可证

MIT — 详见 [LICENSE](LICENSE)。
