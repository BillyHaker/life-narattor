# App Review Privacy Response

Submission response draft for Guidelines 5.1.1(i) and 5.1.2(i).

## Ready-to-paste reply

Thank you for the review. We revised the app to clearly disclose the third-party AI data processing before the user can use the app.

On first launch, and also after upgrading from an older build without this consent flag, Life Narattor now shows a required “Privacy and AI Processing” screen. This screen explains:

- what data may be sent: record text, user questions, related record snippets, draft text, and audio needed for transcription;
- when data is sent: only when the user actively uses AI Review, assistant conversation, assistant-to-record drafting, transcription, re-cleaning, splitting, or tagging features;
- who receives the data: requests are sent through the Life Narrator backend proxy to third-party AI service providers, currently OpenAI and Volcano Engine/Doubao for speech transcription;
- why it is sent: only to complete the user-requested transcription, organization, assistant reply, review, or record-structure result;
- what we do not do: no advertising tracking, no sale of user content, and no upstream provider API keys are exposed in the app.

The user must tap “Agree and Continue” before entering the app. Therefore, user data is not sent to third-party AI services before this disclosure and permission step.

We also updated the public privacy policy to identify the AI providers, the data categories, how the data is used, and the local-first storage boundary.

Privacy Policy URL: https://billyha.github.io/life-narattor/privacy/
Support URL: https://billyha.github.io/life-narattor/support/

## Chinese reference

我们已经在 App 首次启动和旧版本升级后加入必经的“隐私与 AI 处理说明”页面。用户必须点击“同意并继续”才会进入 App。该页面说明了会发送哪些数据、在什么功能下发送、发送给哪些第三方 AI 服务提供方，以及数据用途。隐私政策页面也同步更新。
