# OpenClash SafeOps Skill

[English](#english) | [中文](#中文)

---

<a name="english"></a>

## English

### What is this?

A WorkBuddy / AI-agent skill for safely diagnosing, repairing, and configuring **OpenClash** on **OpenWrt** routers via SSH.

The skill's top priority is **preventing router lockout** — it never touches `network`, `dhcp`, `firewall`, or reboots without explicit approval.

### Features

| Capability | Description |
|---|---|
| **Read-only diagnosis** | System, OpenClash, DNS, ports, logs — all checked before any write |
| **Emergency restore** | Stop OpenClash, restart dnsmasq/uhttpd, restore connectivity when SSH still works |
| **Multi-subscription guard** | Detect and protect multiple subscription → config mappings; block accidental merges |
| **No-subscription-info recovery** | Handle LuCI `无订阅信息` / unbound YAML configs safely |
| **DNS conflict audit** | Identify dnsmasq / SmartDNS / AdGuardHome port conflicts |
| **Subscription health check** | Verify subscription URL reachability and format |
| **YAML lint & group detection** | Deep-lint OpenClash/Mihomo configs; detect real strategy-group names |
| **One-click profile templates** | FakeIP / Redir-Host + SmartDNS / minimal-safe profiles (dry-run by default) |
| **Watchdog rollback** | Automatic rollback guard for medium-risk writes |
| **Structured knowledge base** | 45+ docs with symptom routing, decision trees, and playbooks |

### Requirements

- **OpenWrt** router with **OpenClash** installed
- **SSH** access to the router
- **WorkBuddy** (or compatible AI agent that supports WorkBuddy skills)
- Python 3 + PyYAML on the router (for lint/group-detect scripts)

### Installation

#### Option A: WorkBuddy Skill Install

1. Download the latest release `.zip` from [Releases](../../releases)
2. In WorkBuddy, go to **Skills → Install from file** and select the zip
3. The skill `openclash-safeops` will appear in your skill list

#### Option B: Manual Install

```bash
# Clone into your WorkBuddy skills directory
git clone https://github.com/yjw8448/openclash-safeops-skill.git ~/.workbuddy/skills/openclash-safeops
```

### Usage

Once installed, the skill activates automatically when you ask WorkBuddy about OpenClash issues. Example prompts:

| Scenario | What to say |
|---|---|
| OpenClash won't start | "我的 OpenClash 启动失败了，SSH 能进路由器" |
| Internet breaks when enabling OpenClash | "OpenClash 一开就断网，但 SSH 还能进" |
| Subscription update fails | "OpenClash 更新订阅失败了" |
| Config shows no subscription info | "配置文件显示无订阅信息" |
| Two subscriptions merged into one | "两个订阅被合并成一个配置了" |
| Generate a safe profile | "帮我生成一个安全的一键配置模板" |

### Safety Model

```
User request
    │
    ▼
Read-only diagnosis (always first)
    │
    ├─ Multiple subscriptions? ──► Multi-subscription guard ──► STOP, audit first
    ├─ No subscription info?   ──► Unbound config guard    ──► STOP, quarantine
    ├─ Emergency?              ──► Emergency restore        ──► Stop OpenClash, verify
    └─ Normal repair?          ──► Backup → Watchdog → Fix → Verify → Disarm
```

**Hard rules:**
1. Never modify `/etc/config/network`, `dhcp`, `firewall`
2. Never `reboot`, `firstboot`, `sysupgrade` without explicit approval
3. Always back up before writes
4. Always mask subscription URLs and passwords in output

### Project Structure

```
├── SKILL.md                  # Main skill definition (loaded by agent)
├── scripts/                  # 24 executable scripts for diagnosis/repair
├── templates/                # One-click profile templates and rule examples
├── docs/                     # Detailed documentation
│   └── kb/                   # Knowledge base with symptom routing
│       ├── playbooks/        # Step-by-step repair playbooks
│       └── checklists/       # Pre/post-change checklists
├── references/               # Agent-loaded reference material
│   ├── document-index.md     # Symptom → document routing table
│   ├── scripts-reference.md  # Script parameters and risk levels
│   └── templates-reference.md # Template usage guide
└── examples/                 # Usage examples
```

### Changelog

See [references/changelog.md](references/changelog.md) for version history.

### License

MIT

---

<a name="中文"></a>

## 中文

### 这是什么？

一个用于通过 SSH 安全诊断、修复和配置 OpenWrt 路由器上 **OpenClash** 的 WorkBuddy / AI Agent 技能。

技能的首要目标是**防止路由器锁死** —— 未经明确批准，绝不触碰 `network`、`dhcp`、`firewall` 配置，也不会重启路由器。

### 功能特性

| 功能 | 说明 |
|---|---|
| **只读诊断** | 系统、OpenClash、DNS、端口、日志 —— 写入前先全面检查 |
| **紧急恢复** | SSH 可用时，停止 OpenClash、重启 dnsmasq/uhttpd，恢复网络连通性 |
| **多订阅守卫** | 检测并保护多个订阅→配置文件的映射关系，阻止意外合并 |
| **无订阅信息恢复** | 安全处理 LuCI 显示「无订阅信息」的未绑定 YAML 配置 |
| **DNS 冲突审计** | 识别 dnsmasq / SmartDNS / AdGuardHome 端口冲突 |
| **订阅健康检查** | 验证订阅 URL 可达性和格式 |
| **YAML 检查 & 策略组检测** | 深度检查 OpenClash/Mihomo 配置，检测真实策略组名称 |
| **一键配置模板** | FakeIP / Redir-Host + SmartDNS / 最小安全配置（默认 dry-run） |
| **看门狗回滚** | 中等风险写入的自动回滚保护 |
| **结构化知识库** | 45+ 篇文档，含症状路由、决策树和操作手册 |

### 环境要求

- 安装了 **OpenClash** 的 **OpenWrt** 路由器
- 路由器的 **SSH** 访问权限
- **WorkBuddy**（或支持 WorkBuddy 技能的兼容 AI Agent）
- 路由器上需要 Python 3 + PyYAML（用于 lint/策略组检测脚本）

### 安装方式

#### 方式一：WorkBuddy 技能安装

1. 从 [Releases](../../releases) 下载最新 `.zip` 文件
2. 在 WorkBuddy 中进入 **技能 → 从文件安装**，选择 zip 文件
3. 技能 `openclash-safeops` 将出现在技能列表中

#### 方式二：手动安装

```bash
git clone https://github.com/yjw8448/openclash-safeops-skill.git ~/.workbuddy/skills/openclash-safeops
```

### 使用方法

安装后，当你向 WorkBuddy 询问 OpenClash 相关问题时，技能会自动激活。示例：

| 场景 | 怎么说 |
|---|---|
| OpenClash 启动失败 | "我的 OpenClash 启动失败了，SSH 能进路由器" |
| 开启 OpenClash 后断网 | "OpenClash 一开就断网，但 SSH 还能进" |
| 订阅更新失败 | "OpenClash 更新订阅失败了" |
| 配置显示无订阅信息 | "配置文件显示无订阅信息" |
| 两个订阅被合并 | "两个订阅被合并成一个配置了" |
| 生成安全配置模板 | "帮我生成一个安全的一键配置模板" |

### 安全模型

```
用户请求
    │
    ▼
只读诊断（始终先执行）
    │
    ├─ 多订阅？ ──► 多订阅守卫 ──► 停止，先审计
    ├─ 无订阅信息？──► 未绑定守卫 ──► 停止，先隔离
    ├─ 紧急情况？ ──► 紧急恢复  ──► 停止 OpenClash，验证
    └─ 正常修复？ ──► 备份 → 看门狗 → 修复 → 验证 → 解除
```

**硬性规则：**
1. 绝不修改 `/etc/config/network`、`dhcp`、`firewall`
2. 未经明确批准绝不执行 `reboot`、`firstboot`、`sysupgrade`
3. 写入前始终备份
4. 输出中始终脱敏订阅 URL 和密码

### 项目结构

```
├── SKILL.md                  # 主技能定义（由 Agent 加载）
├── scripts/                  # 24 个诊断/修复脚本
├── templates/                # 一键配置模板和规则示例
├── docs/                     # 详细文档
│   └── kb/                   # 知识库（含症状路由）
│       ├── playbooks/        # 分步修复手册
│       └── checklists/       # 变更前/后检查清单
├── references/               # Agent 加载的参考资料
│   ├── document-index.md     # 症状→文档路由表
│   ├── scripts-reference.md  # 脚本参数和风险级别
│   └── templates-reference.md # 模板使用指南
└── examples/                 # 使用示例
```

### 更新日志

版本历史见 [references/changelog.md](references/changelog.md)。

### 许可证

MIT
