import http from "node:http";
import { URL } from "node:url";
import { noteSeenUser } from "./beta_user_store.js";
import { checkQuota, consumeQuota, quotaErrorPayload, recordUsageEvent } from "./usage_limits.js";

const config = {
    port: Number(process.env.PORT || 8787),
    openaiKey: process.env.OPENAI_API_KEY,
    openaiBase: process.env.OPENAI_BASE || "https://api.openai.com/v1/responses",
    openaiAudioBase: process.env.OPENAI_AUDIO_BASE || "https://api.openai.com/v1/audio/transcriptions",
    transcribeProvider: normalizeTranscribeProvider(process.env.TRANSCRIBE_PROVIDER),
    doubaoASRURL: process.env.DOUBAO_ASR_URL,
    doubaoAppID: process.env.DOUBAO_APP_ID,
    doubaoAccessToken: process.env.DOUBAO_ACCESS_TOKEN,
    doubaoResourceID: process.env.DOUBAO_RESOURCE_ID || "volc.bigasr.auc_turbo",
    doubaoModelName: process.env.DOUBAO_MODEL_NAME || "bigmodel",
    modelQuick: process.env.MODEL_QUICK || "gpt-4o-mini",
    modelAssist: process.env.MODEL_ASSIST || "gpt-4o-mini",
    modelDeep: process.env.MODEL_DEEP || "gpt-4o-mini",
    allowedTokens: splitList(process.env.ALLOWED_TOKENS),
    reviewWhitelist: splitList(process.env.REVIEW_WHITELIST),
    ratePerMinute: Number(process.env.RATE_LIMIT_RPM || 30)
};

const rateMap = new Map();

const server = http.createServer(async (req, res) => {
    const url = new URL(req.url || "/", `http://${req.headers.host}`);

    if (req.method === "GET" && url.pathname === "/healthz") {
        return json(res, 200, { status: "ok" });
    }

    if (req.method !== "POST") {
        return json(res, 405, { error: "method_not_allowed" });
    }

    const auth = parseAuth(req.headers.authorization);
    if (!isAuthorized(auth)) {
        return json(res, 401, { error: "unauthorized" });
    }

    const userId = req.headers["x-user-id"]?.toString();
    if (!userId) {
        return json(res, 400, { error: "missing_user_id" });
    }

    noteSeenUser({
        userId,
        appId: req.headers["x-app-id"]?.toString() || null,
        appVersion: req.headers["x-app-version"]?.toString() || null
    });

    if (!isRateAllowed(userId)) {
        return json(res, 429, { error: "rate_limited" });
    }

    const requestType = requestTypeForPath(url.pathname);
    const audioSeconds = Number(req.headers["x-audio-seconds"]?.toString() || "0") || 0;
    const quotaAmount = quotaAmountFor(requestType, audioSeconds);
    const quota = checkQuota(userId, requestType, quotaAmount);
    if (!quota.allowed) {
        return json(res, 429, quotaErrorPayload(userId, requestType, quotaAmount));
    }
    consumeQuota(userId, requestType, quotaAmount);

    try {
        if (url.pathname === "/v1/transcribe") {
            const payload = await handleTranscribe(req);
            recordUsageEvent({ userId, requestType, success: true, audioSeconds, detail: null });
            return json(res, 200, payload);
        }

        const body = await readJSON(req);
        if (url.pathname === "/v1/quick/ack") {
            const payload = await handleQuickAck(body);
            recordUsageEvent({ userId, requestType, success: true, audioSeconds, detail: null });
            return json(res, 200, payload);
        }

        if (url.pathname === "/v1/assist") {
            const payload = await handleAssist(body);
            recordUsageEvent({ userId, requestType, success: true, audioSeconds, detail: null });
            return json(res, 200, payload);
        }

        if (url.pathname === "/v1/chat") {
            const payload = await handleChat(body);
            recordUsageEvent({ userId, requestType, success: true, audioSeconds, detail: null });
            return json(res, 200, payload);
        }

        if (url.pathname === "/v1/focused-analysis") {
            const payload = await handleFocusedAnalysis(body);
            recordUsageEvent({ userId, requestType, success: true, audioSeconds, detail: null });
            return json(res, 200, payload);
        }

        if (url.pathname === "/v1/review-analysis") {
            const payload = await handleReviewAnalysis(body);
            recordUsageEvent({ userId, requestType, success: true, audioSeconds, detail: null });
            return json(res, 200, payload);
        }

        if (url.pathname === "/v1/clean") {
            const payload = await handleClean(body);
            recordUsageEvent({ userId, requestType, success: true, audioSeconds, detail: null });
            return json(res, 200, payload);
        }

        if (url.pathname === "/v1/atomize") {
            const payload = await handleAtomize(body);
            recordUsageEvent({ userId, requestType, success: true, audioSeconds, detail: null });
            return json(res, 200, payload);
        }

        if (url.pathname === "/v1/tags") {
            const payload = await handleTags(body);
            recordUsageEvent({ userId, requestType, success: true, audioSeconds, detail: null });
            return json(res, 200, payload);
        }

        if (url.pathname === "/v1/hidden-tags/cluster") {
            const payload = await handleHiddenTagCluster(body);
            recordUsageEvent({ userId, requestType, success: true, audioSeconds, detail: null });
            return json(res, 200, payload);
        }

        if (url.pathname === "/v1/hidden-tags/normalize") {
            const payload = await handleHiddenTagNormalize(body);
            recordUsageEvent({ userId, requestType, success: true, audioSeconds, detail: null });
            return json(res, 200, payload);
        }

        if (url.pathname === "/v1/tasks") {
            const payload = await handleTask(body);
            recordUsageEvent({ userId, requestType, success: true, audioSeconds, detail: null });
            return json(res, 200, payload);
        }

        return json(res, 404, { error: "not_found" });
    } catch (error) {
        recordUsageEvent({ userId, requestType, success: false, audioSeconds, detail: error?.message || null });
        return json(res, 500, { error: "server_error", message: error?.message });
    }
});

server.listen(config.port, () => {
    console.log(`AI proxy listening on :${config.port}`);
});

function splitList(raw) {
    if (!raw) return [];
    return raw.split(",").map((item) => item.trim()).filter(Boolean);
}

function normalizeTranscribeProvider(rawProvider) {
    const provider = (rawProvider || "openai").trim().toLowerCase();
    if (provider === "openai" || provider === "doubao") {
        return provider;
    }
    return "openai";
}

function parseAuth(value) {
    if (!value) return null;
    const [type, token] = value.split(" ");
    if (type !== "Bearer") return null;
    return token;
}

function isAuthorized(token) {
    if (config.allowedTokens.length === 0) return true;
    return token && config.allowedTokens.includes(token);
}

function isRateAllowed(key) {
    const now = Date.now();
    const windowMs = 60_000;
    const entry = rateMap.get(key) || { start: now, count: 0 };
    if (now - entry.start > windowMs) {
        entry.start = now;
        entry.count = 0;
    }
    entry.count += 1;
    rateMap.set(key, entry);
    return entry.count <= config.ratePerMinute;
}

function requestTypeForPath(pathname) {
    switch (pathname) {
        case "/v1/transcribe":
            return "transcription";
        case "/v1/quick/ack":
            return "quick_ack";
        case "/v1/assist":
            return "assist_archive";
        case "/v1/chat":
            return "chat";
        case "/v1/focused-analysis":
            return "review_focused";
        case "/v1/review-analysis":
            return "review_overview";
        case "/v1/clean":
            return "clean";
        case "/v1/atomize":
            return "atomize";
        case "/v1/tags":
            return "tag_suggest";
        case "/v1/hidden-tags/cluster":
            return "hidden_tag_cluster";
        case "/v1/hidden-tags/normalize":
            return "hidden_tag_normalize";
        case "/v1/tasks":
            return "tasks";
        default:
            return "chat";
    }
}

function quotaAmountFor(requestType, audioSeconds) {
    if (requestType === "transcription") {
        return Math.max(1, Math.ceil(audioSeconds));
    }
    return 1;
}

async function readJSON(req) {
    const chunks = [];
    let size = 0;
    for await (const chunk of req) {
        size += chunk.length;
        if (size > 1_000_000) {
            throw new Error("payload_too_large");
        }
        chunks.push(chunk);
    }
    const data = Buffer.concat(chunks).toString("utf8");
    return JSON.parse(data || "{}");
}

async function readRaw(req, maxBytes = 25_000_000) {
    const chunks = [];
    let size = 0;
    for await (const chunk of req) {
        size += chunk.length;
        if (size > maxBytes) {
            throw new Error("payload_too_large");
        }
        chunks.push(chunk);
    }
    return Buffer.concat(chunks);
}

function json(res, status, payload) {
    res.statusCode = status;
    res.setHeader("Content-Type", "application/json; charset=utf-8");
    res.end(JSON.stringify(payload));
}

async function handleQuickAck(body) {
    const cleanText = body.clean_text || body.raw_text || "";
    const schema = {
        type: "object",
        properties: {
            ack_title: { type: "string" },
            ack_detail: { type: "string" }
        },
        required: ["ack_title", "ack_detail"],
        additionalProperties: false
    };

    const output = await callOpenAI({
        instructions: "Return JSON only. Role: high-trust personal assistant. Calm, direct, restrained. ack_title should be very short, neutral, and non-cheerleading. ack_detail should mirror the user's point cleanly without praise, coaching, or extra expansion. Avoid emoji, exclamation marks, and therapeutic tone.",
        userInput: `Generate ack_title and ack_detail for: ${cleanText}`,
        schemaName: "quick_ack",
        schema,
        model: config.modelQuick
    });

    return JSON.parse(output);
}

async function handleAssist(body) {
    const question = body?.payload?.question_text || "";
    const contextText = body?.payload?.context_text || body?.payload?.imported_transcript_text || "";
    const schema = {
        type: "object",
        properties: {
            reply: { type: "string" },
            title: { type: "string" },
            context: { type: "string" },
            key_points: { type: "array", items: { type: "string" } },
            next_steps: { type: "array", items: { type: "string" } },
            record_units: {
                type: "array",
                items: {
                    type: "object",
                    properties: {
                        title: { type: "string" },
                        summary: { type: "string" },
                        key_points: { type: "array", items: { type: "string" } },
                        next_steps: { type: "array", items: { type: "string" } }
                    },
                    required: ["title", "summary", "key_points", "next_steps"],
                    additionalProperties: false
                }
            }
        },
        required: ["reply", "title", "context", "key_points", "next_steps", "record_units"],
        additionalProperties: false
    };

    const output = await callOpenAI({
        instructions: "Return JSON only. Answer concisely and precisely.",
        userInput: `User asked: ${question}\nConversation context: ${contextText}\nBuild one concise archive card and split the conversation into 1-4 meaningful record units by topic. Each record unit should stand on its own and should not be a sentence fragment.`,
        schemaName: "assist_archive",
        schema,
        model: config.modelAssist
    });

    const parsed = JSON.parse(output);
    return {
        reply: parsed.reply,
        archive_card: {
            title: parsed.title,
            context: parsed.context,
            keyPoints: Array.isArray(parsed.key_points) ? parsed.key_points : [],
            nextSteps: Array.isArray(parsed.next_steps) ? parsed.next_steps : [],
            recordUnits: Array.isArray(parsed.record_units) ? parsed.record_units : [],
            tagSuggestions: [],
            confidence: "medium"
        },
        turn_policy: {
            usedClarification: false,
            turnsRemaining: 1
        }
    };
}

async function handleChat(body) {
    const question = body?.payload?.question_text || "";
    const contextText = body?.payload?.context_text || body?.payload?.imported_transcript_text || "";
    const schema = {
        type: "object",
        properties: {
            reply: { type: "string" }
        },
        required: ["reply"],
        additionalProperties: false
    };

    const output = await callOpenAI({
        instructions: "Return JSON only. Answer concisely and precisely.",
        userInput: `User asked: ${question}\nConversation context: ${contextText}`,
        schemaName: "chat_reply",
        schema,
        model: config.modelAssist
    });

    return JSON.parse(output);
}

async function handleFocusedAnalysis(body) {
    const schema = {
        type: "object",
        properties: {
            reply: { type: "string" }
        },
        required: ["reply"],
        additionalProperties: false
    };

    const output = await callOpenAI({
        instructions: "Return JSON only. Reply in concise natural Chinese using record/review language, not English. If followup_question is empty, write a short evidence note: first facts directly supported by the evidence, then weaker links or signals, then 1-2 short follow-up questions. If followup_question is present, answer only that follow-up from the current evidence bundle and keep the answer short. Stay evidence-bound. Do not claim strong causality unless the evidence explicitly supports it. If evidence is limited, say it is only a tentative signal. Prefer the labels: 事实： / 联系： / 可继续问：",
        userInput: JSON.stringify({
            leading_question: body?.leading_question || "",
            top_signals: Array.isArray(body?.top_signals) ? body.top_signals : [],
            comparison_windows: Array.isArray(body?.comparison_windows) ? body.comparison_windows : [],
            evidence_groups: Array.isArray(body?.evidence_groups) ? body.evidence_groups : [],
            followup_question: body?.followup_question || ""
        }),
        schemaName: "focused_evidence_analysis",
        schema,
        model: config.modelAssist
    });

    return JSON.parse(output);
}

async function handleReviewAnalysis(body) {
    const schema = {
        type: "object",
        properties: {
            reply: { type: "string" }
        },
        required: ["reply"],
        additionalProperties: false
    };

    const output = await callOpenAI({
        instructions: "Return JSON only. Reply in concise natural Chinese using record/review language, not English. You are reviewing structured life material for a time period. If followup_question is empty, write a short review note: first facts directly visible in the records, then weaker links or insights that are not obvious from linear diary reading, then 1-2 short follow-up questions. If followup_question is present, answer only that follow-up from the current material and keep the answer short. Stay evidence-bound. Do not invent motives or facts. Do not use coaching tone. Do not claim strong causality. Keep the reply short enough to fit on the first screen. Prefer the labels: 事实： / 联系： / 可继续问：",
        userInput: JSON.stringify({
            period_name: body?.period_name || "",
            followup_question: body?.followup_question || "",
            primary_themes: Array.isArray(body?.primary_themes) ? body.primary_themes : [],
            change_signals: Array.isArray(body?.change_signals) ? body.change_signals : [],
            repeated_patterns: Array.isArray(body?.repeated_patterns) ? body.repeated_patterns : [],
            turning_points: Array.isArray(body?.turning_points) ? body.turning_points : [],
            representative_units: Array.isArray(body?.representative_units) ? body.representative_units : [],
            sections: Array.isArray(body?.sections) ? body.sections : []
        }),
        schemaName: "review_narrative_analysis",
        schema,
        model: config.modelAssist
    });

    return JSON.parse(output);
}

async function handleClean(body) {
    const rawText = body?.raw_text || "";
    const ruleCleanText = body?.rule_clean_text || rawText;
    const schema = {
        type: "object",
        properties: {
            clean_text: { type: "string" },
            change_level: { type: "string", enum: ["light", "medium"] },
            removed_fillers: { type: "array", items: { type: "string" } }
        },
        required: ["clean_text", "change_level", "removed_fillers"],
        additionalProperties: false
    };

    const output = await callOpenAI({
        instructions: "Return JSON only. You are cleaning spoken-language transcription, not summarizing it. Keep the user's original meaning, sequence, and speaking style. Preserve the original grammatical person and narrative viewpoint. If the user speaks in first person, keep first person. Only remove filler words, merge obvious repetition, repair broken clauses, and add minimal punctuation. Do not add facts, do not summarize, do not rewrite into formal prose. If the text is already clear, make the smallest possible edits. Answer concisely and precisely.",
        userInput: `Raw transcript: ${rawText}\nRule-cleaned baseline: ${ruleCleanText}\nforce_ai: ${body?.force_ai ? "true" : "false"}`,
        schemaName: "clean_transcript",
        schema,
        model: config.modelAssist
    });

    return JSON.parse(output);
}

async function handleAtomize(body) {
    const cleanText = body?.clean_text || body?.raw_text || "";
    const existingVisibleTags = body?.existing_visible_tags || {};
    const schema = {
        type: "object",
        properties: {
            semantic_chunks: {
                type: "array",
                items: {
                    type: "object",
                    properties: {
                        text: { type: "string" },
                        kind: { type: "string" },
                        sequence_index: { type: ["integer", "null"] }
                    },
                    required: ["text", "kind", "sequence_index"],
                    additionalProperties: false
                }
            },
            record_units: {
                type: "array",
                items: {
                    type: "object",
                    properties: {
                        summary: { type: "string" },
                        context_attributes: {
                            type: "array",
                            items: {
                                type: "object",
                                properties: {
                                    name: { type: "string" },
                                    value: { type: "string" }
                                },
                                required: ["name", "value"],
                                additionalProperties: false
                            }
                        },
                        behavioral_chain: {
                            type: "array",
                            items: { type: "string" }
                        },
                        result_or_state: {
                            type: "array",
                            items: { type: "string" }
                        },
                        tag_hints: {
                            type: "array",
                            items: { type: "string" }
                        },
                        confidence: { type: ["number", "null"] },
                        start_char: { type: ["integer", "null"] },
                        end_char: { type: ["integer", "null"] }
                    },
                    required: ["summary", "context_attributes", "behavioral_chain", "result_or_state", "tag_hints", "confidence", "start_char", "end_char"],
                    additionalProperties: false
                }
            },
            atomize_version: { type: ["string", "null"] }
        },
        required: ["semantic_chunks", "record_units", "atomize_version"],
        additionalProperties: false
    };

    const output = await callOpenAI({
        instructions: "Return JSON only. You are helping the user accumulate life material they can revisit later to understand themselves, compare patterns, and improve their life. Preserve the user's original phrasing, perspective, intent, and narrative structure. Do not formalize. First extract semantic chunks that keep all meaningful information, including actions, states, judgments, results, time anchors, and causal or turning relations. Then assemble 1-4 record units, defaulting to as few units as possible. A record unit is a complete thing the user may later revisit, expand, search, or compare. It is not a clause or phrase fragment. Split only when the text clearly contains different retainable matters, different stages in time, or different outcomes. Each unit summary must contain exactly one main matter. Do not pack two parallel matters into one summary. If a detail is only time, degree, condition, emotional color, or background, keep it in context_attributes instead of creating another unit. If the text contains a sequence of related actions, preserve that sequence in behavioral_chain instead of flattening it into a generic summary. If the text explicitly states a result, outcome, feeling, or state change caused by the matter, preserve it in result_or_state instead of dropping it. Do not lose explicit feelings, results, or consequences from the original text. Feelings or state phrases should normally stay attached to the nearest main matter in result_or_state. Do not make them their own unit unless the text is mainly about that state itself. result_or_state must contain only consequences, outcomes, feelings, or state changes caused by the main matter. Do not restate the main matter itself there. Each unit summary must stand on its own when read without the original text. If the original text clearly shares a time anchor, subject, or sequence relation across clauses, carry that context into the relevant unit when needed for clarity. tag_hints must be noun or noun-phrase style retrieval clues, not full sentences. Do not add new facts, motives, or interpretations.",
        userInput: JSON.stringify({
            capture_id: body?.capture_id || "",
            clean_text: cleanText,
            language: body?.language || "zh",
            policy: body?.policy || {
                no_formalization: true,
                max_units: 4,
                prefer_retainable_units: true
            },
            existing_visible_tags: existingVisibleTags
        }),
        schemaName: "atomize",
        schema,
        model: config.modelAssist
    });

    return JSON.parse(output);
}

async function handleTags(body) {
    const existingVisibleTags = body?.existing_visible_tags || {};
    const semanticChunks = Array.isArray(body?.semantic_chunks) ? body.semantic_chunks : [];
    const recordUnits = Array.isArray(body?.record_units) ? body.record_units : [];
    const allowedTagTypes = ["project", "habit", "theme", "person", "goal", "context"];
    const schema = {
        type: "object",
        properties: {
            suggestions: {
                type: "array",
                items: {
                    type: "object",
                    properties: {
                        tag_type: { type: "string", enum: allowedTagTypes },
                        name: { type: "string" },
                        score: { type: ["number", "null"] }
                    },
                    required: ["tag_type", "name", "score"],
                    additionalProperties: false
                }
            },
            hidden_suggestions: {
                type: "array",
                items: {
                    type: "object",
                    properties: {
                        tag_type: { type: "string", enum: allowedTagTypes },
                        name: { type: "string" },
                        score: { type: ["number", "null"] }
                    },
                    required: ["tag_type", "name", "score"],
                    additionalProperties: false
                }
            }
        },
        required: ["suggestions", "hidden_suggestions"],
        additionalProperties: false
    };

    const output = await callOpenAI({
        instructions: "Return JSON only. Suggest at most one visible tag. Also return 2-5 hidden suggestions by default unless the material is truly too weak. Work from record units first, then use semantic chunks as supporting detail. Treat tag_hints inside each record unit as the strongest retrieval cues. Prefer reusing an existing visible tag from the provided tag library whenever there is a close semantic match. Only suggest a new visible tag when no existing visible tag is close enough. hidden_suggestions should be richer than visible suggestions and should usually include concrete themes, states, contexts, habits, or retrieval clues that help later recall. hidden_suggestions must still be short noun or noun-phrase tags. Do not output sentence-like labels.",
        userInput: JSON.stringify({
            semantic_chunks: semanticChunks,
            record_units: recordUnits,
            existing_visible_tags: existingVisibleTags,
            policy: body?.policy || {
                max_visible_suggestions: 1,
                target_hidden_suggestions: 4,
                prefer_existing_visible_tags: true,
                only_create_new_visible_tag_if_no_close_match: true
            }
        }),
        schemaName: "tag_suggest",
        schema,
        model: config.modelAssist
    });

    return JSON.parse(output);
}

async function handleHiddenTagCluster(body) {
    const hiddenTags = Array.isArray(body?.hidden_tags) ? body.hidden_tags : [];
    const bucketNames = [
        "work_project",
        "habit_rhythm",
        "state_emotion",
        "body_health",
        "context_scene",
        "person_relation",
        "interest_topic",
        "misc"
    ];
    const schema = {
        type: "object",
        properties: {
            groups: {
                type: "array",
                items: {
                    type: "object",
                    properties: {
                        bucket: { type: "string", enum: bucketNames },
                        title: { type: "string" },
                        member_ids: { type: "array", items: { type: "string" } }
                    },
                    required: ["bucket", "title", "member_ids"],
                    additionalProperties: false
                }
            }
        },
        required: ["groups"],
        additionalProperties: false
    };

    const output = await callOpenAI({
        instructions: "Return JSON only. You are organizing hidden retrieval tags into broad semantic buckets before later synonym normalization. Do not merge, rename, or simplify tags here. Only assign them to broad groups. Put every tag into exactly one bucket. Use only these buckets: work_project, habit_rhythm, state_emotion, body_health, context_scene, person_relation, interest_topic, misc. Keep grouping broad and stable. When unsure, use misc.",
        userInput: JSON.stringify({ hidden_tags: hiddenTags }),
        schemaName: "hidden_tag_cluster",
        schema,
        model: config.modelAssist
    });

    return JSON.parse(output);
}

async function handleHiddenTagNormalize(body) {
    const hiddenTags = Array.isArray(body?.hidden_tags) ? body.hidden_tags : [];
    const bucket = body?.bucket || "misc";
    const bucketNames = [
        "work_project",
        "habit_rhythm",
        "state_emotion",
        "body_health",
        "context_scene",
        "person_relation",
        "interest_topic",
        "misc"
    ];
    const schema = {
        type: "object",
        properties: {
            updated_at: { type: ["string", "null"] },
            mappings: {
                type: "array",
                items: {
                    type: "object",
                    properties: {
                        raw_tag_id: { type: "string" },
                        raw_name: { type: "string" },
                        raw_type: { type: "string" },
                        bucket: { type: "string", enum: bucketNames },
                        canonical_name: { type: "string" },
                        confidence: { type: ["number", "null"] },
                        reason: { type: ["string", "null"] }
                    },
                    required: ["raw_tag_id", "raw_name", "raw_type", "bucket", "canonical_name", "confidence", "reason"],
                    additionalProperties: false
                }
            }
        },
        required: ["updated_at", "mappings"],
        additionalProperties: false
    };

    const output = await callOpenAI({
        instructions: "Return JSON only. You are standardizing hidden retrieval tags inside one already-grouped semantic bucket. Only merge tags when their meaning is fully or nearly identical. Do not merge broader/narrower tags, cause/effect tags, adjacent-but-different tags, or tags that simply co-occur. Every raw tag must receive one canonical_name. If a tag has no true synonym in the group, keep a canonical_name very close to the raw name. canonical_name must be a short noun or noun phrase, not a sentence.",
        userInput: JSON.stringify({ bucket, hidden_tags: hiddenTags }),
        schemaName: "hidden_tag_normalize",
        schema,
        model: config.modelAssist
    });

    return JSON.parse(output);
}

async function handleTask() {
    return { id: `task_${crypto.randomUUID()}` };
}

async function handleTranscribe(req) {
    const contentType = req.headers["content-type"]?.toString() || "";
    if (!contentType.toLowerCase().startsWith("multipart/form-data")) {
        throw new Error("invalid_content_type");
    }

    const body = await readRaw(req, 25_000_000);
    if (config.transcribeProvider === "doubao") {
        return transcribeWithDoubao(contentType, body);
    }
    return transcribeWithOpenAI(contentType, body);
}

async function transcribeWithOpenAI(contentType, body) {
    if (!config.openaiKey) {
        throw new Error("missing_openai_key");
    }

    const response = await fetch(config.openaiAudioBase, {
        method: "POST",
        headers: {
            "Authorization": `Bearer ${config.openaiKey}`,
            "Content-Type": contentType
        },
        body
    });

    if (!response.ok) {
        const text = await response.text();
        throw new Error(`openai_audio_error_${response.status}: ${text}`);
    }

    const payload = await response.json();
    if (!payload || typeof payload.text !== "string") {
        throw new Error("invalid_transcription_response");
    }

    return { text: payload.text };
}

async function transcribeWithDoubao(contentType, body) {
    if (!config.doubaoASRURL || !config.doubaoAppID || !config.doubaoAccessToken) {
        throw new Error("missing_doubao_config");
    }

    const parsed = parseMultipartFormData(body, contentType);
    const filePart = parsed.files.find((item) => item.name === "file") || parsed.files[0];
    if (!filePart || !filePart.data || filePart.data.length === 0) {
        throw new Error("missing_audio_file");
    }

    const payload = {
        user: {
            uid: String(config.doubaoAppID)
        },
        audio: {
            data: filePart.data.toString("base64")
        },
        request: {
            model_name: config.doubaoModelName
        }
    };

    const response = await fetch(config.doubaoASRURL, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "X-Api-App-Key": String(config.doubaoAppID),
            "X-Api-Access-Key": String(config.doubaoAccessToken),
            "X-Api-Resource-Id": config.doubaoResourceID,
            "X-Api-Request-Id": crypto.randomUUID(),
            "X-Api-Sequence": "-1"
        },
        body: JSON.stringify(payload)
    });

    const rawText = await response.text();
    if (!response.ok) {
        throw new Error(`doubao_http_error_${response.status}: ${rawText}`);
    }

    const statusCode = response.headers.get("X-Api-Status-Code");
    if (statusCode && statusCode !== "20000000") {
        throw new Error(`doubao_api_error_${statusCode}: ${rawText}`);
    }

    let data;
    try {
        data = JSON.parse(rawText);
    } catch {
        throw new Error("doubao_invalid_json_response");
    }

    const text = extractTranscriptText(data);
    if (!text) {
        throw new Error("invalid_doubao_transcription_response");
    }
    return { text };
}

function extractTranscriptText(payload) {
    if (!payload || typeof payload !== "object") {
        return null;
    }

    if (typeof payload.text === "string" && payload.text.trim().length > 0) {
        return payload.text.trim();
    }

    if (typeof payload.result?.text === "string" && payload.result.text.trim().length > 0) {
        return payload.result.text.trim();
    }

    if (Array.isArray(payload.result?.utterances)) {
        const merged = payload.result.utterances
            .map((item) => (typeof item?.text === "string" ? item.text.trim() : ""))
            .filter(Boolean)
            .join(" ");
        if (merged.length > 0) {
            return merged;
        }
    }

    return null;
}

function parseMultipartFormData(body, contentType) {
    const boundary = parseMultipartBoundary(contentType);
    if (!boundary) {
        throw new Error("multipart_boundary_missing");
    }

    const boundaryBuffer = Buffer.from(`--${boundary}`);
    const headerSeparator = Buffer.from("\r\n\r\n");
    const files = [];
    const fields = {};
    let cursor = body.indexOf(boundaryBuffer);

    if (cursor < 0) {
        throw new Error("multipart_boundary_not_found");
    }

    while (cursor >= 0) {
        cursor += boundaryBuffer.length;
        if (body[cursor] === 45 && body[cursor + 1] === 45) {
            break;
        }

        if (body[cursor] === 13 && body[cursor + 1] === 10) {
            cursor += 2;
        }

        const headerEnd = body.indexOf(headerSeparator, cursor);
        if (headerEnd < 0) {
            throw new Error("multipart_header_parse_failed");
        }

        const headerText = body.slice(cursor, headerEnd).toString("utf8");
        const nextBoundary = body.indexOf(boundaryBuffer, headerEnd + headerSeparator.length);
        if (nextBoundary < 0) {
            throw new Error("multipart_next_boundary_missing");
        }

        let contentEnd = nextBoundary - 2;
        if (contentEnd < headerEnd + headerSeparator.length) {
            contentEnd = headerEnd + headerSeparator.length;
        }
        const content = body.slice(headerEnd + headerSeparator.length, contentEnd);
        const disposition = parseContentDisposition(headerText);

        if (disposition?.name) {
            if (disposition.filename) {
                files.push({
                    name: disposition.name,
                    filename: disposition.filename,
                    data: content
                });
            } else {
                fields[disposition.name] = content.toString("utf8");
            }
        }

        cursor = nextBoundary;
    }

    return { fields, files };
}

function parseMultipartBoundary(contentType) {
    const match = contentType.match(/boundary="?([^";]+)"?/i);
    return match?.[1] || null;
}

function parseContentDisposition(headerText) {
    const line = headerText
        .split("\r\n")
        .find((item) => item.toLowerCase().startsWith("content-disposition:"));
    if (!line) {
        return null;
    }

    const nameMatch = line.match(/name="([^"]+)"/i);
    const filenameMatch = line.match(/filename="([^"]*)"/i);
    return {
        name: nameMatch?.[1] || null,
        filename: filenameMatch?.[1] || null
    };
}

async function callOpenAI({ instructions, userInput, schemaName, schema, model }) {
    if (!config.openaiKey) {
        throw new Error("missing_openai_key");
    }

    const body = {
        model: model || config.modelQuick,
        instructions,
        input: [{ role: "user", content: userInput }],
        text: {
            format: {
                type: "json_schema",
                name: schemaName,
                schema,
                strict: true
            }
        }
    };

    const response = await fetch(config.openaiBase, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${config.openaiKey}`
        },
        body: JSON.stringify(body)
    });

    if (!response.ok) {
        const text = await response.text();
        throw new Error(`openai_error_${response.status}: ${text}`);
    }

    const data = await response.json();
    if (data.output_text) return data.output_text;

    if (Array.isArray(data.output)) {
        for (const item of data.output) {
            if (Array.isArray(item.content)) {
                for (const content of item.content) {
                    if (content.text) return content.text;
                }
            }
        }
    }

    throw new Error("empty_openai_response");
}
