import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const storePath = path.join(os.tmpdir(), 'lifenarrator_usage_store.json');

const DEFAULT_LIMITS = {
  chat: { daily: 80, kind: 'count' },
  assist_archive: { daily: 20, kind: 'count' },
  atomize: { daily: 30, kind: 'count' },
  tag_suggest: { daily: 50, kind: 'count' },
  review_overview: { daily: 15, kind: 'count' },
  review_focused: { daily: 15, kind: 'count' },
  review_followup: { daily: 20, kind: 'count' },
  transcription: { daily: 20 * 60, kind: 'seconds' },
  clean: { daily: 80, kind: 'count' },
  hidden_tag_cluster: { daily: 10, kind: 'count' },
  hidden_tag_normalize: { daily: 10, kind: 'count' },
  quick_ack: { daily: 100, kind: 'count' },
  tasks: { daily: 20, kind: 'count' }
};

function loadStore() {
  try {
    const raw = fs.readFileSync(storePath, 'utf8');
    return JSON.parse(raw || '{}');
  } catch {
    return { usage: {}, events: [] };
  }
}

function saveStore(store) {
  fs.writeFileSync(storePath, JSON.stringify(store, null, 2));
}

function todayKey() {
  return new Date().toISOString().slice(0, 10);
}

function dayBucket(store, userId, date = todayKey()) {
  store.usage[userId] ||= {};
  store.usage[userId][date] ||= {};
  return store.usage[userId][date];
}

function limitFor(requestType) {
  return DEFAULT_LIMITS[requestType] || { daily: 50, kind: 'count' };
}

export function checkQuota(userId, requestType, amount = 1) {
  const store = loadStore();
  const bucket = dayBucket(store, userId);
  const entry = bucket[requestType] || { used: 0 };
  const limit = limitFor(requestType);
  return {
    allowed: entry.used + amount <= limit.daily,
    used: entry.used,
    nextUsed: entry.used + amount,
    limit: limit.daily,
    unit: limit.kind,
    date: todayKey()
  };
}

export function consumeQuota(userId, requestType, amount = 1) {
  const store = loadStore();
  const bucket = dayBucket(store, userId);
  bucket[requestType] ||= { used: 0 };
  bucket[requestType].used += amount;
  saveStore(store);
  return bucket[requestType].used;
}

export function recordUsageEvent({ userId, requestType, success, audioSeconds = 0, estimatedTokens = 0, detail = null }) {
  const store = loadStore();
  store.events ||= [];
  store.events.push({
    user_id: userId,
    request_type: requestType,
    success,
    audio_seconds: audioSeconds,
    estimated_tokens: estimatedTokens,
    detail,
    created_at: new Date().toISOString()
  });
  if (store.events.length > 2000) {
    store.events = store.events.slice(-2000);
  }
  saveStore(store);
}

export function quotaErrorPayload(userId, requestType, amount = 1) {
  const status = checkQuota(userId, requestType, amount);
  return {
    error: 'quota_exceeded',
    request_type: requestType,
    unit: status.unit,
    used: status.used,
    attempted: amount,
    limit: status.limit,
    reset_date: status.date
  };
}
