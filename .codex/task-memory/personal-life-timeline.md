<!-- remember-task-context:v1 -->
# Task: 个人生平时间线

- Task ID: `personal-life-timeline`
- Workspace: `E:\gooxi21`
- Created: 2026-09-18T16:11:38+08:00

## Initial Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

## Checkpoint 2026-09-18T16:11:38+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
Task memory initialized.

### Latest User Request
None recorded.

### Active Requirements
- None recorded.

### Decisions And Rationale
- None recorded.

### Stable Facts
- None recorded.

### Files And Artifacts
- None recorded.

### Commands
- None recorded.

### Verification
- None recorded.

### Open Issues And Risks
- None recorded.

### Next Steps
- None recorded.

### Notes
- None recorded.

## Checkpoint 2026-09-20T12:00:00+08:00
- Status: `active`

### Objective
将个人生平站点改为登录后访问，并实现站长独享编辑权限、其他账号只读。

### Current State
首页、登录页和账户页已统一接入持久 Supabase 会话；首页未登录跳转登录，登录后统一回到站点根目录。固定站长邮箱可编辑共享生平，其他账号只读且各自保留个人资料卡。

### Latest User Request
gooxi21.cn 未登录先显示登录页；所有账号登录后回首页；仅 1223157269@qq.com 能浏览并修改生平，其他账号只能阅读；登录状态要长期保持。

### Active Requirements
- 未登录不得看到首页内容；登录后统一进入 gooxi21.cn 根目录。
- 站长邮箱拥有新增和删除生平记忆权限；其他已登录用户只有阅读权限。
- 每个账号在 account 页面拥有自己的资料卡。
- Supabase 会话持久化并自动刷新。

### Decisions And Rationale
- 权限同时在前端界面与 Supabase RLS 落实；前端隐藏按钮只改善体验，RLS 才是安全边界。
- 共享生平增量内容迁移到 life_memories 表，不再使用每台设备独立的 localStorage 记忆。
- 登录页忽略 next 参数并始终返回站点根目录，满足所有账号进入同一生平页面的产品定位。

### Stable Facts
- 站长邮箱为 1223157269@qq.com。
- Supabase 项目 URL 为 https://zckpkhktthgwzcnumadb.supabase.co。

### Files And Artifacts
- index.html: 首页鉴权遮罩、角色判断、只读/管理模式、life_memories 云端读写。
- login/index.html: 持久会话，登录、注册确认或已有会话均返回根目录。
- account/index.html: 持久会话守卫与当前用户自己的资料卡。
- supabase-setup.sql: profiles 与 life_memories 表、授权、RLS 和 updated_at 触发器。

### Commands
- None recorded.

### Verification
- 三个模块脚本解析无 SyntaxError；静态验收覆盖未登录首页跳转、登录页已有会话回首页、账户页未登录跳转、站长按钮显示、访客增删保存拦截、三页 persistSession/autoRefreshToken 配置。
- 首页模拟鉴权覆盖未登录、站长和访客三种角色；共享记忆加载通过。
- 内置浏览器当前不可用，未完成真实点击与 Supabase 线上 RLS 端到端测试。

### Open Issues And Risks
- 必须在 Supabase SQL Editor 执行 supabase-setup.sql，并检查没有旧的宽松策略与新策略并存。
- Supabase Auth URL、邮箱确认和 Session timeout 设置需要在控制台完成。
- 首页仍有静态示例经历；若内容必须对未登录者连页面源代码也不可见，应将全部正文迁移到受 RLS 保护的数据表。
- 底部访客人数目前仍是当前浏览器 localStorage 计数，不是全站总访问量。

### Next Steps
- 执行 SQL 并完成 Supabase 控制台设置后，在 gooxi21.cn 用站长与普通账号各做一次真机登录、刷新、编辑权限验证。

### Notes
- None recorded.

## Checkpoint 2026-09-18T16:20:52+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
将原乱码静态首页重做为可交互的个人生平时间线，并加入浏览器本地记忆录入。

### Latest User Request
先完成从小到大的人生阶段时间线设想，点击阶段展开内容，后续可以逐步添加。

### Active Requirements
- 保持静态单页可直接运行；阶段可点击；内容便于以后继续添加。

### Decisions And Rationale
- 采用五阶段纵向时间线与右侧章节面板；新增记忆通过 localStorage 保存并可删除；示例经历明确作为可替换占位内容。

### Stable Facts
- None recorded.

### Files And Artifacts
- index.html: 完整响应式页面、五阶段数据、阶段切换、记忆新增删除、本地持久化。

### Commands
- None recorded.

### Verification
- Node 成功解析页面脚本；git diff --check 无错误（仅提示 Windows 行尾转换）；内置浏览器当前不可用，未完成视觉截图验证。

### Open Issues And Risks
- None recorded.

### Next Steps
- 用户提供真实出生年份、关键节点、照片后，替换示例文案并增加照片/事件编辑能力。

### Notes
- None recorded.

## Checkpoint 2026-09-18T17:00:15+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
精修个人生平时间线，修复丢失符号，增强时间线/弹窗/表单交互，并新增底部本地到访计数。

### Latest User Request
仔细检查细节，增加每次进入加一的访客人数，并补充更多细节和交互。

### Active Requirements
- 访客计数放在页面最底部；每次页面 pageshow 加一；继续保持纯静态单页。

### Decisions And Rationale
- 访客计数使用 localStorage，仅代表当前设备/浏览器累计到访次数，页面中明确标注；真实全站访客总数需未来接后端原子计数。
- 保留访客可用的本地记忆录入；增加阶段切换动画、方向键 tabs、移动端横向滚动、表单空白校验、存储异常提示和删除二次确认。

### Stable Facts
- None recorded.

### Files And Artifacts
- index.html: 修复年龄区间和缺失图标；新增底部 visitor card、pageshow 计数、可访问性和响应式细节。

### Commands
- None recorded.

### Verification
- JavaScript 语法、HTML/CSS 括号与引号、git diff --check 均通过；模拟测试验证两次进入递增、阶段点击/键盘切换、tab DOM 稳定、新增记忆、空白拦截和二次确认删除。内置浏览器当前不可用，未做截图级视觉回归。

### Open Issues And Risks
- None recorded.

### Next Steps
- 如需所有访客共享总计数或站长新增内容公开给其他人，接入后端/CMS；之后可用真实年份、节点和照片替换占位内容。

### Notes
- None recorded.

## Checkpoint 2026-09-20T10:45:43+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
新增 Supabase 登录守卫：account 未登录跳转 login，登录成功或已有会话按安全 next 参数返回账户页。

### Latest User Request
修改 account 和 login 文件，实现未登录访问账户页时跳到登录页面。

### Active Requirements
- 直接访问 account 时必须验证 Supabase session；未登录跳登录页；登录后返回原目标页面。

### Decisions And Rationale
- account 页面负责资料展示、昵称保存和退出；login 页面负责注册登录，并只接受同源 next 地址，避免开放重定向。

### Stable Facts
- None recorded.

### Files And Artifacts
- account/index.html: 新建受保护账户页、加载状态、会话守卫、资料读写与退出。
- login/index.html: 增加安全 next 回跳、已登录自动返回、注册邮件回调和回车登录。

### Commands
- None recorded.

### Verification
- 模块语法和 CSS 检查通过；模拟验证未登录 account 跳 login、登录会话显示 account、已登录 login 返回 account、同源 next 保留查询与锚点、外部 next 被拒绝；git diff --check 通过。内置浏览器当前不可用。

### Open Issues And Risks
- Supabase 控制台需将部署域名的 /login/ 加入允许的 Redirect URLs；profiles 表仍需启用正确的 RLS 策略，前端跳转本身不是数据安全边界。

### Next Steps
- 在真实部署域名完成一次注册确认、登录、刷新 account、退出登录的端到端验证。

### Notes
- None recorded.

## Checkpoint 2026-09-20T11:31:10+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
首页新增当前账号菜单和本地账号切换，账户页同步改为切换账号；切换后回登录页。

### Latest User Request
已登录后缺少账号切换入口，需要能够换其他账号查看。

### Active Requirements
- 未登录访问首页跳登录，登录后统一回根目录。
- 站长邮箱可编辑共享生平，其他账号只读；每个账号保留自己的资料卡。
- 首页和账户页都要能明确切换账号，且不退出其他设备。

### Decisions And Rationale
- 首页右上角使用可展开账号菜单显示当前邮箱、权限模式、个人资料与切换账号。
- 切换账号调用 Supabase signOut scope local，仅清除当前浏览器会话，然后跳转登录页。

### Stable Facts
- 现有 profiles 表继续用于每个账号自己的资料卡；共享生平使用 life_memories。

### Files And Artifacts
- index.html: 新增账号菜单、当前邮箱、权限标识、移动端适配与切换账号逻辑。
- account/index.html: 退出登录改为切换账号，并使用 local scope。

### Commands
- None recorded.

### Verification
- 两个模块脚本无 SyntaxError；验证邮箱显示、切换按钮、local signOut、登录页回跳、移动端菜单及无重复 ID；git diff --check 通过。

### Open Issues And Risks
- 内置浏览器当前不可用，未完成真实点击与线上 Supabase 会话切换测试。

### Next Steps
- 部署后分别登录站长和普通账号，使用首页账号菜单来回切换一次。

### Notes
- None recorded.

## Checkpoint 2026-09-20T13:52:52+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
重构登录页为登录主视图与折叠注册辅助卡，并完成 Supabase 忘记密码、恢复回调和更新密码流程。

### Latest User Request
重新设计登录页面，突出登录、缩小注册，并增加 Supabase 忘记密码功能。

### Active Requirements
- 未登录访问首页跳登录，登录后统一回根目录。
- 登录是页面主操作，注册为较小的辅助操作，桌面和手机均清晰。
- 忘记密码必须支持发送邮件、识别恢复链接、设置新密码并重新登录。
- 站长邮箱可编辑共享生平，其他账号只读；每个账号保留自己的资料卡。

### Decisions And Rationale
- 注册使用默认折叠 details 卡片，减少对登录主流程的干扰。
- 密码找回调用 resetPasswordForEmail，监听 PASSWORD_RECOVERY，并用 updateUser 保存新密码；成功后仅退出当前浏览器会话。
- 密码恢复与邮箱确认共用已允许的 /login/ 回调路径，不新增数据库表。

### Stable Facts
- Supabase Redirect URLs 需要包含 https://gooxi21.cn/login/；生产邮件建议配置自定义 SMTP。

### Files And Artifacts
- login/index.html: 全面重做响应式视觉、登录表单、折叠注册、忘记密码弹窗和新密码恢复视图。

### Commands
- None recorded.

### Verification
- 模块脚本无 SyntaxError；所有脚本引用 ID 存在且无重复；表单闭合；静态验证覆盖 resetPasswordForEmail、PASSWORD_RECOVERY、updateUser、普通会话回首页、折叠注册和手机端登录优先；git diff --check 通过。

### Open Issues And Risks
- 内置浏览器当前不可用，未完成截图级视觉验收和真实邮件端到端测试。

### Next Steps
- 部署后用测试邮箱执行忘记密码，点击邮件链接设置新密码，再用新密码登录。

### Notes
- None recorded.

## Checkpoint 2026-09-20T13:57:58+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
按参考图将登录页改为居中单一邮箱登录，注册和找回密码改为底部入口与弹窗，增加生平时间线氛围背景和完整中文提示。

### Latest User Request
参考 QQ 登录页，只保留邮箱登录，不要快捷登录和意见反馈；增强背景，统一中文提示，并明确提示登录错误与重复邮箱。

### Active Requirements
- 未登录访问首页跳登录，登录后统一回根目录。
- 登录页只支持邮箱和密码，不显示快捷登录、第三方登录或意见反馈。
- 主页面突出登录，底部只保留找回密码和注册账号，注册作为次要弹窗。
- 账号密码错误、邮箱未验证、重复注册、频率限制和密码问题使用中文提示。
- 忘记密码支持邮件、恢复回调、更新密码与重新登录。

### Decisions And Rationale
- 采用参考图的顶部品牌加居中登录卡布局，背景使用过去、此刻、未来时间线与柔和光晕。
- 注册与找回密码均使用 dialog 弹窗，保持登录主页面简洁。
- 重复邮箱同时处理 Supabase 明确错误和 identities 为空的可识别返回；邮箱确认开启时其余情况使用安全兜底提示。

### Stable Facts
- Supabase 为防止账号枚举，在开启邮箱确认时可能对已注册邮箱返回模糊用户对象，因此前端无法保证所有重复邮箱都被精确公开。

### Files And Artifacts
- login/index.html: 单邮箱登录视觉、时间线背景、注册/找回弹窗、中文错误映射、密码恢复流程。

### Commands
- None recorded.

### Verification
- 模块语法通过；脚本引用 ID 完整且唯一；确认仅邮箱登录、无快捷登录/意见反馈、中文账号密码错误、重复邮箱提示、注册与找回弹窗及密码恢复链路；git diff --check 通过。

### Open Issues And Risks
- 内置浏览器当前不可用，未完成截图级视觉验收；重复邮箱的精确反馈受 Supabase 防枚举策略限制。

### Next Steps
- 部署后用错误密码、已注册邮箱和新邮箱分别验证三种中文提示，并测试密码重置邮件。

### Notes
- None recorded.

## Checkpoint 2026-09-20T14:16:56+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
进一步精简邮箱登录页：移除顶部栏、品牌网址、圆形图标、登录说明和浏览器保存提示；所有密码框改为按住眼睛临时显示。

### Latest User Request
移除顶部白框、品牌网址、阅圆圈、登录说明和保存浏览器提示；密码查看改成眼睛并且只在按住时显示。

### Active Requirements
- 登录页从顶部到底使用统一背景，不显示顶部品牌栏。
- 主登录卡只显示邮箱登录标题、邮箱、密码、登录、找回密码和注册账号。
- 所有密码字段使用眼睛图标，按住显示，松开、移出、失焦或切换页面立即隐藏，不允许常开。
- 登录与注册错误继续使用明确中文提示，忘记密码流程保留。

### Decisions And Rationale
- 眼睛交互使用 pointerdown/keyup 临时显示，并在 pointerup、pointerleave、pointercancel、blur、visibilitychange 和窗口失焦时统一隐藏。

### Stable Facts
- None recorded.

### Files And Artifacts
- login/index.html: 删除顶部与多余提示，增加 5 个 SVG 眼睛按钮及按住查看密码交互。

### Commands
- None recorded.

### Verification
- 模块语法、ID 完整唯一、顶部/品牌/圆圈/说明/保存提示移除、5 个密码框眼睛覆盖、按住显示与多路径自动隐藏均通过；git diff --check 通过。

### Open Issues And Risks
- 内置浏览器当前不可用，未完成真实按压与截图级视觉验收。

### Next Steps
- 部署后在电脑和手机上分别按住眼睛图标，确认按住显示、松开立即隐藏。

### Notes
- None recorded.

## Checkpoint 2026-09-20T14:28:05+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
修复密码找回回调：新增独立 /reset-password/ 页面，登录页发出的新重置邮件改为指向专用页面，保存密码后退出临时会话并回登录页。

### Latest User Request
重置邮件能收到但点击后没有修改密码页面，需要检查并修复完整重置流程。

### Active Requirements
- 密码重置邮件必须进入专用页面，明确显示新密码和确认密码。
- 专用页面验证 Supabase 恢复会话，使用 updateUser 保存密码，成功后退出临时会话并回登录。
- 无效或过期链接显示中文原因和返回登录入口；密码眼睛保持按住显示、松开隐藏。

### Decisions And Rationale
- 将恢复流程从登录页主逻辑中分离到 /reset-password/，同时保留登录页旧恢复逻辑兼容已发送链接。
- resetPasswordForEmail 的 redirectTo 改为 https://gooxi21.cn/reset-password/；登录页通过 reset=success 显示成功提示。

### Stable Facts
- Supabase URL Configuration 必须允许 https://gooxi21.cn/reset-password/，Recovery 邮件模板按钮应使用 {{ .ConfirmationURL }}。

### Files And Artifacts
- login/index.html: 重置邮件回调改到专用页面，并处理密码更新成功提示。
- reset-password/index.html: 新增链接验证、新密码表单、updateUser、临时会话退出、无效链接状态和按住眼睛查看密码。

### Commands
- None recorded.

### Verification
- 两个模块语法、ID 完整唯一、专用回调解析、会话验证、PASSWORD_RECOVERY、updateUser、本地退出、成功回登录、无效链接及眼睛交互均通过；git diff --check 通过。

### Open Issues And Risks
- 必须在 Supabase 后台新增专用 Redirect URL 并检查 Recovery 邮件模板，否则服务端会回退到 Site URL；内置浏览器不可用，未完成真实邮件端到端测试。

### Next Steps
- 部署两页并完成 Supabase Redirect URL/Recovery 模板设置后，重新发送一封新邮件测试；旧邮件不要复用。

### Notes
- None recorded.

## Checkpoint 2026-09-20T16:18:08+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
已确认线上与本地 reset-password 页面一致；截图中的 otp_expired 是 Supabase 验证端在页面加载前返回，前端未触发发送邮件。最可能原因是邮箱安全扫描预取并消耗 ConfirmationURL，另有旧邮件被新请求替换的可能。

### Latest User Request
仔细排查首次点击重置邮件即显示链接无效的问题，不要触发重置邮件额度。

### Active Requirements
- 排查和验证期间不得调用 resetPasswordForEmail 或发送任何重置邮件。

### Decisions And Rationale
- 采用防预取两步恢复：Recovery 模板链接携带 TokenHash 先进入本站确认页，只有用户主动点击后才调用 verifyOtp(type=recovery)，然后显示新密码表单。

### Stable Facts
- 线上 reset-password/index.html 与本地 SHA-256 完全一致；错误 URL 含 #error=access_denied&error_code=otp_expired，证明失败发生在 Supabase /verify 阶段、早于本站表单逻辑。

### Files And Artifacts
- reset-password/index.html: 当前支持 token_hash，但会自动 verifyOtp；计划改为显式确认后验证，并拒绝把普通登录会话误当恢复会话。

### Commands
- None recorded.

### Verification
- 只读获取线上页面返回 200，线上与本地文件哈希相同；官方 Supabase 文档确认 ConfirmationURL 可能被邮件预取扫描提前消耗。未发送邮件。

### Open Issues And Risks
- 工作区 Windows 沙箱初始化 helper_unknown_error，apply_patch 无法读取文件，修复补丁尚未落盘。Supabase Recovery 邮件模板内容和 Auth Logs 需要用户后台权限确认。

### Next Steps
- 沙箱恢复后修改 reset-password 两步确认；用户在 Supabase Recovery 模板将 ConfirmationURL 改为 RedirectTo + token_hash + type=recovery；再仅用一封最新邮件做端到端验证。

### Notes
- None recorded.

## Checkpoint 2026-09-20T16:22:04+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
确认 2026-06-03 后新建的 Supabase Free 项目使用默认邮件服务时不能修改 Auth 邮件模板，用户后台表现正常。

### Latest User Request
无法修改 Supabase Recovery 邮件模板，询问不配置 SMTP 是否有其他解决办法。

### Active Requirements
- 不得为排查触发重置邮件；优先给出适合个人网站且安全的恢复方案。

### Decisions And Rationale
- 纯前端无法安全绕过不可编辑的 ConfirmationURL；首选免费自定义 SMTP。若坚持无 SMTP，可使用 Free/Pro 可用的 Send Email Auth Hook 配合邮件 API；完全不用外部邮件服务时只能提供登录态修改密码和人工恢复，无法实现安全的忘记密码自助流程。

### Stable Facts
- Supabase 2026-06-03 起限制新 Free 项目通过默认 SMTP 自定义认证邮件模板；Auth Send Email Hook 在 Free/Pro 可用并会替代 SMTP 发送。

### Files And Artifacts
- None recorded.

### Commands
- None recorded.

### Verification
- None recorded.

### Open Issues And Risks
- 需要用户在免费 SMTP、Send Email Hook、或仅登录态改密/人工恢复之间选择；当前默认 ConfirmationURL 对 QQ 邮箱预取仍可能立即失效。

### Next Steps
- 建议配置 Resend 免费 SMTP并使用安全 token_hash 模板；若用户拒绝 SMTP，再实现 account 登录态修改密码并决定是否部署 Send Email Hook。

### Notes
- None recorded.

## Checkpoint 2026-09-20T16:28:44+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
确定采用 Resend 自定义 SMTP，并在 Recovery 模板使用 RedirectTo + TokenHash + recovery 类型，绕开默认 ConfirmationURL 的邮件预取问题。

### Latest User Request
询问 Resend 免费 SMTP 与安全 token_hash 模板的具体实现步骤。

### Active Requirements
- 不得触发测试邮件；Resend API Key 只能保存在 Supabase SMTP 密码字段或密钥管理中，不得写入前端或仓库。

### Decisions And Rationale
- 推荐验证 auth.gooxi21.cn 子域；Resend SMTP 使用 smtp.resend.com、465、用户名 resend、密码为 Resend API Key；关闭邮件点击跟踪。

### Stable Facts
- login/index.html 已将 resetPasswordForEmail redirectTo 指向 /reset-password/；reset-password/index.html 已支持 query token_hash 并以 recovery 类型调用 verifyOtp。

### Files And Artifacts
- None recorded.

### Commands
- None recorded.

### Verification
- 官方 Resend 文档确认 SMTP 主机 smtp.resend.com、用户名 resend、465/587 等端口及 API Key 作为密码；Supabase 官方 Resend 集成可自动填充 SMTP。

### Open Issues And Risks
- apply_patch 仍受 Windows sandbox helper_unknown_error 阻挡，两步人工确认加固尚未写入；当前 token_hash 流程仍可用。

### Next Steps
- 用户先在 Resend 验证 auth.gooxi21.cn、配置 Supabase SMTP、URL Configuration 与 Recovery 模板；最后只发送一封邮件验证链接形态和改密流程。

### Notes
- None recorded.

## Checkpoint 2026-09-20T16:33:24+08:00
- Status: `active`

### Objective
将现有网页改造成可点击浏览、可逐步扩充内容的个人生平时间线。

### Current State
用户已启用 Supabase Custom SMTP，改用个人 QQ 邮箱发送 Auth 邮件；截图显示 sender 1223157269@qq.com、smtp.qq.com、465、每用户 60 秒。

### Latest User Request
检查 QQ SMTP 配置是否正确并说明下一步。

### Active Requirements
- 不得主动发送测试或重置邮件；不得索取或记录 QQ SMTP 授权码。

### Decisions And Rationale
- QQ SMTP 可替代 Resend用于小型个人站；必须使用完整 QQ 邮箱作为 SMTP 用户名、QQ 生成的 SMTP 授权码作为密码，不能使用 QQ 登录密码。Recovery 模板必须从 ConfirmationURL 改为 RedirectTo + TokenHash + type=recovery。

### Stable Facts
- 当前截图中的 Reset Password 模板仍使用 {{ .ConfirmationURL }}，尚未解决邮件扫描提前消耗链接的问题。

### Files And Artifacts
- None recorded.

### Commands
- None recorded.

### Verification
- None recorded.

### Open Issues And Risks
- 截图未显示 SMTP Username、Password/authorization code 和页面底部保存状态，无法确认连接凭据完整；需核对 URL Configuration。

### Next Steps
- 保存 QQ SMTP；修改并保存 Recovery 模板；确认 Site URL 和两个 Redirect URLs；最后只发一封最新重置邮件并检查链接以 gooxi21.cn/reset-password/?token_hash= 开头。

### Notes
- None recorded.
