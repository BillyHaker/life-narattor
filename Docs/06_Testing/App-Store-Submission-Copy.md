# App Store Submission Copy

Last updated: 2026-04-27
Status: Ready for submission drafting

## 简体中文 - 描述
Life Narattor 是一款以本地优先为基础的记录与 AI 回顾应用，适合用来整理日常想法、语音片段、对话内容和阶段性观察。

你可以用文字或语音快速记录，再通过助手对话继续梳理内容，并在写入前先看到一份可编辑的记录草稿。对于已经保存的内容，AI 回顾会帮助你从记录里整理出事实、联系和后续可以继续追问的方向。

当前测试版本支持：
- 文本记录
- 语音记录与转写
- 助手对话
- 对话整理为记录草稿并确认写入
- AI 回顾
- 时间线 7 天 / 30 天回顾

默认情况下，记录内容只保存在你的本地设备上。只有在语音转写、助手对话、记录整理、AI 回顾等需要联网处理的功能中，才会把必要内容通过产品后台代理发送给模型服务处理。应用不会把上游模型服务密钥放进客户端或暴露给测试用户。

## 简体中文 - 关键词
记录,日记,笔记,语音记录,语音转写,AI回顾,助手,时间线,整理,草稿

## App Review 审核备注（中文）
本应用当前为测试阶段版本，核心能力包括文本记录、语音记录与转写、助手对话、对话整理为记录草稿、AI 回顾、以及时间线 7 天 / 30 天回顾。

隐私边界如下：
1. 记录内容默认保存在本地设备。
2. 只有在语音转写、助手对话、记录整理和 AI 回顾等需要联网处理的功能中，应用才会通过产品后台代理调用 AI 能力。
3. 应用不会向终端用户暴露上游 AI 服务提供方密钥，也不会在客户端内置测试用模型密钥。

本版本的主要用户可见入口为：记录、助手、时间线、AI 回顾。长期线索会作为 AI 回顾中的灵感入口出现，不再作为独立底部标签。
Debug/Dev 工具入口只在调试构建中出现，不会出现在 TestFlight / Release 构建中。

隐私政策 URL：
https://billyhaker.github.io/life-narattor/privacy/

技术支持 URL：
https://billyhaker.github.io/life-narattor/support/

## App Review Notes (English)
This build is a beta-stage version focused on text records, voice capture and transcription, assistant conversation, assistant conversation to editable draft record, AI Review, and timeline review for the last 7/30 days.

Privacy boundary:
1. Record content is stored locally on device by default.
2. Only features that explicitly require network processing, such as transcription, assistant conversation, record organization, and AI Review, go through the product backend proxy.
3. The app does not expose upstream AI provider keys to end users and does not embed beta model provider keys in the client.

Primary user-visible entry points in this beta are Record, Assistant, Timeline, Projects, and AI Review.
Debug/Dev tools are only available in debug builds and are not available in TestFlight / Release builds.

Privacy Policy URL:
https://billyhaker.github.io/life-narattor/privacy/

Support URL:
https://billyhaker.github.io/life-narattor/support/
