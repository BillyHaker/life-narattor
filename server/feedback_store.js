import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import crypto from "node:crypto";

const storePath = process.env.FEEDBACK_STORE_PATH || path.join(os.tmpdir(), "lifenarrator_feedback_store.jsonl");

function ensureStoreDirectory() {
    fs.mkdirSync(path.dirname(storePath), { recursive: true });
}

function readRows() {
    if (!fs.existsSync(storePath)) return [];
    return fs.readFileSync(storePath, "utf8")
        .split(/\r?\n/)
        .filter(Boolean)
        .map((line) => {
            try {
                return JSON.parse(line);
            } catch {
                return null;
            }
        })
        .filter(Boolean);
}

export function createFeedback(input) {
    ensureStoreDirectory();
    const row = {
        feedback_id: `fb_${crypto.randomUUID()}`,
        created_at: new Date().toISOString(),
        user_id: safeString(input.userId, 160),
        app_id: safeString(input.appId, 160),
        app_version: safeString(input.appVersion, 80),
        os_version: safeString(input.osVersion, 120),
        device_model: safeString(input.deviceModel, 120),
        contact: safeString(input.contact, 240),
        message: safeString(input.message, 2400),
        screenshot: sanitizeScreenshot(input.screenshot)
    };
    fs.appendFileSync(storePath, `${JSON.stringify(row)}\n`, "utf8");
    return row;
}

export function listFeedback(limit = 50) {
    return readRows()
        .sort((a, b) => String(b.created_at).localeCompare(String(a.created_at)))
        .slice(0, limit);
}

function safeString(value, maxLength) {
    const text = String(value ?? "").trim();
    return text.length > maxLength ? text.slice(0, maxLength) : text;
}

function sanitizeScreenshot(screenshot) {
    if (!screenshot || typeof screenshot !== "object") return null;
    const mimeType = safeString(screenshot.mime_type, 80);
    const data = safeString(screenshot.data, 4_000_000);
    if (!mimeType.startsWith("image/") || !data) return null;
    return {
        mime_type: mimeType,
        data,
        byte_count: Number(screenshot.byte_count || 0) || 0
    };
}
