# 🛡️ OpenClash SafeOps — AI Agent Skill for Safe OpenWrt Router Management

**OpenClash 安全运维技能 — 面向 AI Agent 的 OpenWrt 路由器安全管理**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-OpenWrt-blue.svg)](https://openwrt.org/)
[![Skills](https://img.shields.io/badge/Compatible-WorkBuddy%20%7C%20OpenClaw%20%7C%20Claude%20%7C%20ChatGPT%20%7C%20Cursor%20%7C%20Windsurf-green.svg)]()

> 🔌 Compatible with / 兼容：WorkBuddy · OpenClaw · Claude · ChatGPT · Cursor · Windsurf · MCP-compatible agents

**Quick Jump / 快速跳转：** [🇬🇧 English](#english-section) | [🇨🇳 中文](#chinese-section)

---

<a id="english-section"></a>
## 🇬🇧 English

<a id="english-what-is-this"></a>
### 📦 What is this?

A skill/plugin for AI agents (WorkBuddy, OpenClaw, Claude, ChatGPT, Cursor, etc.) that **safely** diagnoses, repairs, and configures OpenClash on OpenWrt routers via SSH. It prevents router lockout by enforcing read-only diagnosis first, always backing up before writes, and **never touching** network/dhcp/firewall system configs.

<a id="english-features"></a>
### ⭐ Core Features

1. 🚫 **Anti-Lockout Safety Boundaries** — Default prohibition on modifying `/etc/config/network`, `/etc/config/dhcp`, `/etc/config/firewall`. No `network restart`, `reboot`, `firstboot`, `sysupgrade`. All repairs follow: read-only diagnosis → backup → candidate generation → validation → user approval → write → verify.

2. 🔧 **SSH Safe Repair** — Read-only diagnosis and low-risk repair via SSH: OpenClash status, dnsmasq/uhttpd status, port conflicts, DNS resolution, subscription URLs, logs, YAML structure, strategy-group references.

3. 🔀 **Multi-Subscription Protection** — Detects multiple subscription sources and YAML files. Prevents AI agents from merging `Sub A → A.yaml` + `Sub B → B.yaml` into one `merged.yaml`. Stops repair when multiple subscriptions, unbound configs, or ambiguous mappings are detected.

4. 🔍 **No-Subscription-Info Recovery** — When LuCI shows `无订阅信息` (no subscription info), treats the config as unbound. Backs up, audits bindings, determines origin, checks for accidental merges, and generates recovery suggestions.

5. 🎯 **Single-Config Template Application** — Modifies exactly one target YAML. Never touches other YAML files or merges subscriptions. Full pipeline: audit → guard → candidate → validate → approve → write.

6. 🌊 **Aethersailor Current-Safe Config Generation** — Built-in template inspired by Aethersailor / Custom_OpenClash_Rules. Conservative: Fake-IP only, no Redir-Host, no auto system config edits, no deprecated ad-block, no blind remote dependency injection, preserves original proxies/proxy-groups/proxy-providers.

7. 📡 **FFAni Redir-Host + SmartDNS Template** — Built-in template for Redir-Host + SmartDNS style candidate generation. System-level config items are output as manual checklists only.

8. ✂️ **Redaction & Reporting** — Built-in sensitive info redaction (8 patterns: URLs, passwords, secrets, tokens, API keys, Bearer Auth, dashboard paths) and auto-generated diagnostic reports for safe sharing.

9. 🔗 **Active Config Binding Audit** — Read-only audit of subscription-to-YAML binding consistency, preventing silent misroutes caused by mismatched update URLs.

<a id="english-structure"></a>
### 📁 Directory Structure

```
openclash-skill/
├── 📄 SKILL.md                          # Main skill definition
├── 📂 scripts/                          # Executable scripts (32)
│   ├── openclash_diagnose.sh            # Read-only diagnosis
│   ├── openclash_backup.sh              # Config backup
│   ├── openclash_emergency_restore.sh   # Emergency restore
│   ├── openclash_watchdog.sh            # Watchdog rollback
│   ├── openclash_dns_audit.sh           # DNS audit
│   ├── openclash_subscription_health.sh # Subscription health check
│   ├── openclash_multisub_audit.sh      # Multi-subscription audit
│   ├── openclash_multisub_guard.sh      # Multi-subscription guard
│   ├── openclash_active_binding_audit.sh # Active config binding audit
│   ├── openclash_single_config_template_guard.sh # Single-config template guard
│   ├── openclash_template_apply.py      # Template engine
│   ├── openclash_lint_config.py         # YAML deep validation
│   ├── openclash_group_detect.py        # Strategy group detection
│   ├── openclash_report_writer.py       # Diagnostic report writer
│   ├── openclash_redact.py              # Sensitive info redaction
│   └── ...
├── 📂 templates/                        # Config templates (11)
│   ├── aethersailor-current-safe-overlay.yaml    # Aethersailor Current-Safe
│   ├── aethersailor-legacy-safe-overlay.yaml     # Aethersailor Legacy
│   ├── ffani-redirhost-smartdns-overlay.yaml     # FFAni Redir-Host
│   ├── overwrite-safe-basic.yaml                 # Safe basic
│   ├── overwrite-ai-dev.yaml                     # AI/Dev rules
│   └── ...
├── 📂 references/                       # Reference docs (14)
│   ├── document-index.md                # Doc routing index
│   ├── scripts-reference.md             # Script reference manual
│   ├── templates-reference.md           # Template reference manual
│   ├── template-apply.md                # Template apply guide
│   ├── reporting.md                     # Report generation & sync
│   ├── changelog.md                     # Version changelog
│   └── ...
├── 📂 docs/
│   └── 📂 kb/                           # Knowledge base (60+ docs)
│       ├── 00-kb-index.md               # KB index
│       ├── 10-symptom-router.md         # Symptom router
│       ├── 20-safety-boundaries.md      # Safety boundaries
│       ├── 60-dns-decision-tree.md      # DNS decision tree
│       ├── 70-subscription-decision-tree.md  # Sub decision tree
│       ├── 75-multi-subscription-decision-tree.md
│       ├── 76-unbound-config-decision-tree.md
│       ├── 81-report-generation-and-sync.md
│       ├── 82-active-config-update-url-binding.md
│       ├── 📂 playbooks/                # Repair playbooks
│       └── 📂 checklists/               # Checklists
└── 📂 examples/
    └── usage-examples.md                # Usage examples
```

<a id="english-install"></a>
### 💿 Installation

#### 🟣 WorkBuddy
1. Download the zip from [Releases](https://github.com/yjw8448/openclash-safeops-skill/releases)
2. In WorkBuddy, go to **Skills → Import** → select the zip file
3. Or copy the entire folder to `~/.workbuddy/skills/openclash-safeops/`

#### 🔵 OpenClaw
Place the skill folder in OpenClaw's skills directory and add to your configuration.

#### 🟢 Claude Desktop / MCP-compatible agents
Copy the `scripts/` directory to your agent's working directory. Reference `SKILL.md` as the system prompt. Ensure the agent has SSH access to your router.

#### 📋 Manual
```bash
git clone https://github.com/yjw8448/openclash-safeops-skill.git ~/.workbuddy/skills/openclash-safeops/
```

<a id="english-usage"></a>
### 🚀 Quick Usage

#### 🔍 Read-only diagnosis
```bash
sh scripts/openclash_diagnose.sh
```

#### 💾 Backup config
```bash
sh scripts/openclash_backup.sh
```

#### 🌐 DNS audit
```bash
sh scripts/openclash_dns_audit.sh
```

#### 📡 Subscription health check
```bash
sh scripts/openclash_subscription_health.sh
```

#### 🔀 Multi-subscription audit
```bash
sh scripts/openclash_multisub_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
```

#### 🔗 Active binding audit
```bash
sh scripts/openclash_active_binding_audit.sh
```

#### 🎯 Single-config template guard
```bash
TARGET_FILE="/etc/openclash/config/provider-a.yaml"
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_single_config_template_guard.sh
```

#### 🌊 Generate Aethersailor Current-Safe candidate
```bash
TARGET_FILE="/etc/openclash/config/provider-a.yaml"

python3 scripts/openclash_template_apply.py \
  --target "$TARGET_FILE" \
  --template aethersailor-current-safe \
  --candidate /tmp/provider-a.aethersailor-current-safe.candidate.yaml
```

#### ✅ Validate candidate
```bash
python3 scripts/openclash_lint_config.py /tmp/provider-a.aethersailor-current-safe.candidate.yaml
python3 scripts/openclash_group_detect.py /tmp/provider-a.aethersailor-current-safe.candidate.yaml --env
```

#### 📝 Generate diagnostic report
```bash
python3 scripts/openclash_report_writer.py \
  --diagnosis /tmp/diag.txt \
  --output /tmp/openclash-report.md
```

#### ✂️ Redact sensitive info
```bash
python3 scripts/openclash_redact.py --input /tmp/raw-output.txt --output /tmp/safe-output.txt
```

#### 💥 Apply after user approval
```bash
I_UNDERSTAND_TARGETED_WRITE=1 python3 scripts/openclash_template_apply.py \
  --target "/etc/openclash/config/provider-a.yaml" \
  --template aethersailor-current-safe \
  --candidate /tmp/provider-a.aethersailor-current-safe.candidate.yaml \
  --apply
```

<a id="english-safety"></a>
### 🛡️ Safety Principles

- 🔬 Diagnose before modify, always
- 💾 Backup before write, always
- 📋 Generate candidate before overwrite, always
- 🧱 Touch OpenClash, not OpenWrt network
- ✅ Wait for user approval before high-risk operations

AI agents are **prohibited** from doing the following without explicit user confirmation:

- 🚫 Modifying LAN IP, DHCP, or firewall zones
- 🚫 Restarting network
- 🚫 Resetting the system
- 🚫 Merging multiple subscriptions
- 🚫 Overwriting multiple YAML files
- 🚫 Deleting original configs
- 🚫 Printing complete subscription URLs

<a id="english-usecases"></a>
### ✅ Use Cases

- 🟢 OpenClash breaks internet after start
- 🟢 OpenClash DNS issues
- 🟢 Subscription update failures
- 🟢 Config shows "no subscription info"
- 🟢 Multiple subscriptions accidentally merged
- 🟢 Subscription binding confusion
- 🟢 Generate Aethersailor-style candidate YAML
- 🟢 Generate FFAni-style candidate YAML
- 🟢 Add AI / GitHub / BT/PT rules
- 🟢 Check strategy-group references in rules
- 🟢 Generate redacted diagnostic reports
- 🟢 Audit subscription-to-YAML binding

<a id="english-non-usecases"></a>
### ❌ Non-Use Cases

- 🔴 Resetting the OpenWrt system
- 🔴 Modifying LAN/WAN interfaces
- 🔴 Modifying firewall main config
- 🔴 Auto-configuring IPv6 system parameters
- 🔴 Auto-installing/configuring SmartDNS/MosDNS/AdGuardHome
- 🔴 Bypassing all manual confirmation steps

<a id="english-requirements"></a>
### ⚙️ Requirements

- 🤖 Any AI agent with skill/MCP plugin support
- 🔑 SSH access to OpenWrt router (root)
- 🐍 Python 3 (for lint and group detection scripts)
- 📦 PyYAML (for Python-based scripts)
- 📡 OpenClash installed on the router

<a id="english-disclaimer"></a>
### ⚠️ Disclaimer

This project is for OpenClash/OpenWrt safe diagnosis, candidate config generation, and operational assistance only.

Before use, ensure:
- Router is accessible via SSH
- Current config is backed up
- Subscription URLs are functional
- Target YAML is clearly identified
- You know how to enter LuCI or failsafe mode

Issues caused by misoperation, expired subscriptions, expired rules, OpenWrt system differences, or OpenClash version differences are the user's responsibility.

<a id="english-license"></a>
### 📜 License

MIT License

---

<a id="chinese-section"></a>
## 🇨🇳 中文

<a id="chinese-what-is-this"></a>
### 📦 这是什么？

一个面向 AI Agent 的技能/插件，通过 SSH **安全**诊断、修复和配置 OpenWrt 路由器上的 OpenClash。强制只读诊断优先、写入前必须备份、**绝不触碰** network/dhcp/firewall 系统配置，防止路由器锁死。

兼容 WorkBuddy、OpenClaw、Claude、ChatGPT、Cursor、Windsurf 及其他支持 skill/MCP 的 AI Agent。

<a id="chinese-features"></a>
### ⭐ 核心特性

#### 🚫 1. 防失联安全边界

默认禁止修改以下 OpenWrt 系统配置：

- `/etc/config/network`
- `/etc/config/dhcp`
- `/etc/config/firewall`

默认禁止执行：

- `/etc/init.d/network restart`
- `reboot`
- `firstboot`
- `sysupgrade`
- `wifi down`

所有修复必须遵循：

```
只读诊断 → 备份 → 生成候选配置 → 校验 → 用户确认 → 写入 → 验证
```

#### 🔧 2. SSH 安全修复

支持通过 SSH 对 OpenClash 进行只读诊断和低风险修复，包括：

- OpenClash 状态检查
- dnsmasq / uhttpd 状态检查
- 端口占用检查
- DNS 解析检查
- 订阅链接检查
- OpenClash 日志检查
- YAML 配置结构检查
- 策略组引用检查

#### 🔀 3. 多订阅保护

适用于多个机场订阅、多个 YAML 配置文件的场景。

防止 AI Agent 把：

```
订阅 A → A.yaml
订阅 B → B.yaml
```

错误合并成：

```
订阅 A + 订阅 B → merged.yaml
```

当检测到以下情况时，技能会停止普通修复流程：

- 存在多个订阅
- 存在多个 YAML
- 配置显示"无订阅信息"
- 目标 YAML 订阅绑定不明
- 多个 YAML 内容高度相似
- 疑似 WorkBuddy/AI 误合并配置

#### 🔍 4. 无订阅信息恢复

针对 OpenClash 页面出现类似情况：

```
配置文件：provider-a.yaml
更新时间：xxxx
无订阅信息
```

技能会将该配置视为"未绑定配置"，不会继续当作正常订阅配置更新，而是先进行：

1. 备份当前状态
2. 审计订阅绑定
3. 判断 YAML 来源
4. 检查是否误合并
5. 查找历史备份
6. 生成恢复建议

#### 🎯 5. 单配置模板应用

支持只针对一个目标 YAML 生成候选配置。不会修改其他 YAML，不会合并其他订阅。

标准流程：

```
指定目标 YAML → 审计订阅绑定 → 执行单配置保护 → 应用模板生成 candidate → 校验 candidate → 等待用户确认 → 确认后才写回目标文件
```

#### 🌊 6. Aethersailor Current-Safe 配置生成

内置 `aethersailor-current-safe` 模板，用于参考 Aethersailor / Custom_OpenClash_Rules 的思路生成候选 OpenClash 配置。

该模板采用保守策略：

- 使用 Fake-IP 思路
- 不使用 Redir-Host
- 不自动修改系统 network/dhcp/firewall
- 不自动启用已废弃广告过滤
- 不盲目依赖失效远程订阅转换服务
- 不强行写入不可验证 rule-provider
- 保留原有 proxies / proxy-groups / proxy-providers

适合用于：

- DNS 防泄漏
- 国内直连
- AI 服务分流
- GitHub 分流
- BT/PT tracker 直连
- Fake-IP 过滤
- 规则顺序修复

#### 📡 7. FFAni Redir-Host + SmartDNS 候选模板

内置 FFAni 风格模板，用于参考 Redir-Host + SmartDNS 方案生成候选配置。

注意：该模板不会自动修改 SmartDNS、WAN、LAN、IPv6、DHCP 等系统设置。涉及系统级配置的部分只会生成手动检查清单。

#### ✂️ 8. 脱敏与报告生成

内置敏感信息脱敏（8 种模式：URL、password、secret、token、api_key、Bearer Auth、dashboard 路径）和自动生成诊断报告，方便安全分享排查结果。

#### 🔗 9. 订阅绑定审计

只读审计当前活跃配置的订阅 URL 绑定一致性。防止 Update URL 与配置文件名不匹配导致的静默错路。

<a id="chinese-structure"></a>
### 📁 目录结构

```
openclash-skill/
├── 📄 SKILL.md                          # 主技能定义
├── 📂 scripts/                          # 可执行脚本（32 个）
│   ├── openclash_diagnose.sh            # 只读诊断
│   ├── openclash_backup.sh              # 配置备份
│   ├── openclash_emergency_restore.sh   # 紧急恢复
│   ├── openclash_watchdog.sh            # 看门狗回滚
│   ├── openclash_dns_audit.sh           # DNS 审计
│   ├── openclash_subscription_health.sh # 订阅健康检查
│   ├── openclash_multisub_audit.sh      # 多订阅审计
│   ├── openclash_multisub_guard.sh      # 多订阅保护
│   ├── openclash_active_binding_audit.sh # 活跃配置订阅绑定审计
│   ├── openclash_single_config_template_guard.sh # 单配置模板保护
│   ├── openclash_template_apply.py      # 模板引擎
│   ├── openclash_lint_config.py         # YAML 深度校验
│   ├── openclash_group_detect.py        # 策略组检测
│   ├── openclash_report_writer.py       # 诊断报告生成器
│   ├── openclash_redact.py              # 敏感信息脱敏
│   └── ...
├── 📂 templates/                        # 配置模板（11 个）
│   ├── aethersailor-current-safe-overlay.yaml    # Aethersailor Current-Safe
│   ├── aethersailor-legacy-safe-overlay.yaml     # Aethersailor Legacy
│   ├── ffani-redirhost-smartdns-overlay.yaml     # FFAni Redir-Host
│   ├── overwrite-safe-basic.yaml                 # 安全基础
│   ├── overwrite-ai-dev.yaml                     # AI/开发规则
│   └── ...
├── 📂 references/                       # 参考资料（14 个）
│   ├── document-index.md                # 文档路由索引
│   ├── scripts-reference.md             # 脚本参考手册
│   ├── templates-reference.md           # 模板参考手册
│   ├── template-apply.md                # 模板应用指南
│   ├── reporting.md                     # 报告生成与同步
│   ├── changelog.md                     # 版本更新日志
│   └── ...
├── 📂 docs/
│   └── 📂 kb/                           # 知识库（60+ 文档）
│       ├── 00-kb-index.md               # 知识库索引
│       ├── 10-symptom-router.md          # 症状路由
│       ├── 20-safety-boundaries.md       # 安全边界
│       ├── 60-dns-decision-tree.md       # DNS 决策树
│       ├── 70-subscription-decision-tree.md  # 订阅决策树
│       ├── 75-multi-subscription-decision-tree.md
│       ├── 76-unbound-config-decision-tree.md
│       ├── 81-report-generation-and-sync.md
│       ├── 82-active-config-update-url-binding.md
│       ├── 📂 playbooks/                # 修复剧本
│       └── 📂 checklists/               # 检查清单
└── 📂 examples/
    └── usage-examples.md                # 使用示例
```

<a id="chinese-install"></a>
### 💿 安装

#### 🟣 WorkBuddy
1. 从 [Releases](https://github.com/yjw8448/openclash-safeops-skill/releases) 下载 zip
2. 在 WorkBuddy 中：**Skills → 导入** → 选择 zip 文件
3. 或手动复制整个文件夹到 `~/.workbuddy/skills/openclash-safeops/`

#### 🔵 OpenClaw
将技能文件夹放入 OpenClaw 的 skills 目录，并添加到配置中。

#### 🟢 Claude Desktop / 其他支持 MCP 的 Agent
将 `scripts/` 目录复制到 Agent 的工作目录，将 `SKILL.md` 作为系统提示词引用。确保 Agent 有 SSH 访问路由器的权限。

#### 📋 手动安装
```bash
git clone https://github.com/yjw8448/openclash-safeops-skill.git ~/.workbuddy/skills/openclash-safeops/
```

<a id="chinese-usage"></a>
### 🚀 推荐使用方式

#### 🔍 只读诊断
```bash
sh scripts/openclash_diagnose.sh
```

#### 💾 备份配置
```bash
sh scripts/openclash_backup.sh
```

#### 🌐 DNS 审计
```bash
sh scripts/openclash_dns_audit.sh
```

#### 📡 订阅健康检查
```bash
sh scripts/openclash_subscription_health.sh
```

#### 🔀 多订阅审计
```bash
sh scripts/openclash_multisub_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
```

#### 🔗 活跃绑定审计
```bash
sh scripts/openclash_active_binding_audit.sh
```

#### 🎯 单配置模板保护
```bash
TARGET_FILE="/etc/openclash/config/provider-a.yaml"
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_single_config_template_guard.sh
```

#### 🌊 生成 Aethersailor Current-Safe 候选配置
```bash
TARGET_FILE="/etc/openclash/config/provider-a.yaml"

python3 scripts/openclash_template_apply.py \
  --target "$TARGET_FILE" \
  --template aethersailor-current-safe \
  --candidate /tmp/provider-a.aethersailor-current-safe.candidate.yaml
```

#### ✅ 校验候选配置
```bash
python3 scripts/openclash_lint_config.py /tmp/provider-a.aethersailor-current-safe.candidate.yaml
python3 scripts/openclash_group_detect.py /tmp/provider-a.aethersailor-current-safe.candidate.yaml --env
```

#### 📝 生成诊断报告
```bash
python3 scripts/openclash_report_writer.py \
  --diagnosis /tmp/diag.txt \
  --output /tmp/openclash-report.md
```

#### ✂️ 脱敏敏感信息
```bash
python3 scripts/openclash_redact.py --input /tmp/raw-output.txt --output /tmp/safe-output.txt
```

#### 💥 用户确认后写回目标配置
```bash
I_UNDERSTAND_TARGETED_WRITE=1 python3 scripts/openclash_template_apply.py \
  --target "/etc/openclash/config/provider-a.yaml" \
  --template aethersailor-current-safe \
  --candidate /tmp/provider-a.aethersailor-current-safe.candidate.yaml \
  --apply
```

<a id="chinese-workbuddy-example"></a>
### 💬 WorkBuddy 调用示例

可以在 WorkBuddy 中这样说：

> 调用 OpenClash SafeOps Skill。
>
> 目标文件：
> `/etc/openclash/config/provider-a.yaml`
>
> 请按照 `aethersailor-current-safe` 模板生成候选配置。
>
> 要求：
> 1. 只处理这个 YAML。
> 2. 不修改其他 YAML。
> 3. 不合并多个订阅。
> 4. 不修改 network/dhcp/firewall。
> 5. 不重启 network。
> 6. 不直接覆盖原文件。
> 7. 先生成 candidate，校验后等待我确认。

<a id="chinese-safety"></a>
### 🛡️ 安全原则

本项目始终遵守以下原则：

- 🔬 能诊断就不修改
- 💾 能备份就先备份
- 📋 能生成候选就不直接覆盖
- 🧱 能改 OpenClash 就不改 OpenWrt network
- ✅ 能手动确认就不自动执行高风险操作

**禁止 AI Agent 在未确认的情况下执行：**

- 🚫 修改 LAN IP
- 🚫 修改 DHCP
- 🚫 修改 firewall zone
- 🚫 重启 network
- 🚫 重置系统
- 🚫 合并多个订阅
- 🚫 覆盖多个 YAML
- 🚫 删除原配置
- 🚫 打印完整订阅链接

<a id="chinese-usecases"></a>
### ✅ 适用场景

- 🟢 OpenClash 开启后断网
- 🟢 OpenClash DNS 异常
- 🟢 订阅无法更新
- 🟢 配置文件显示无订阅信息
- 🟢 多个订阅被误合并
- 🟢 订阅绑定混乱
- 🟢 需要按照 Aethersailor 思路生成候选 YAML
- 🟢 需要按照 FFAni 思路生成候选 YAML
- 🟢 需要为 AI / GitHub / BT/PT 添加规则
- 🟢 需要检查规则中的策略组是否存在
- 🟢 需要生成脱敏诊断报告
- 🟢 需要审计订阅绑定一致性

<a id="chinese-non-usecases"></a>
### ❌ 不适用场景

- 🔴 需要重置 OpenWrt 系统
- 🔴 需要修改 LAN/WAN 接口
- 🔴 需要修改防火墙主配置
- 🔴 需要自动配置 IPv6 系统参数
- 🔴 需要自动安装或重配 SmartDNS/MosDNS/AdGuardHome
- 🔴 需要绕过所有人工确认步骤

<a id="chinese-requirements"></a>
### ⚙️ 环境要求

- 🤖 支持 skill/MCP 插件的 AI Agent
- 🔑 可通过 SSH 登录 OpenWrt 路由器（root）
- 🐍 Python 3（用于 lint 和策略组检测脚本）
- 📦 PyYAML（用于 Python 脚本）
- 📡 路由器上已安装 OpenClash

<a id="chinese-disclaimer"></a>
### ⚠️ 免责声明

本项目仅用于 OpenClash / OpenWrt 的安全诊断、配置候选生成和运维辅助。

使用前请自行确认：

- 路由器可 SSH 登录
- 当前配置已备份
- 订阅链接可用
- 目标 YAML 明确
- 知道如何进入 LuCI 或 failsafe

因误操作、订阅失效、规则失效、OpenWrt 系统差异、OpenClash 版本差异导致的问题，需要用户自行承担风险。

<a id="chinese-license"></a>
### 📜 License

MIT License
