import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const storePath = process.env.USAGE_STORE_PATH || path.join(os.tmpdir(), 'lifenarrator_usage_store.json');
const VALID_TIERS = new Set(['free', 'pro', 'reviewer']);

const TIER_LIMITS = {
  free: {
    chat: { daily: 12, kind: 'count' },
    assist_archive: { daily: 3, kind: 'count' },
    atomize: { daily: 40, kind: 'count' },
    tag_suggest: { daily: 40, kind: 'count' },
    review_overview: { daily: 4, kind: 'count' },
    review_focused: { daily: 4, kind: 'count' },
    review_followup: { daily: 6, kind: 'count' },
    transcription: { daily: 5 * 60, kind: 'seconds' },
    clean: { daily: 40, kind: 'count' },
    hidden_tag_cluster: { daily: 2, kind: 'count' },
    hidden_tag_normalize: { daily: 2, kind: 'count' },
    quick_ack: { daily: 60, kind: 'count' },
    tasks: { daily: 5, kind: 'count' }
  },
  pro: {
    chat: { daily: 120, kind: 'count' },
    assist_archive: { daily: 30, kind: 'count' },
    atomize: { daily: 120, kind: 'count' },
    tag_suggest: { daily: 160, kind: 'count' },
    review_overview: { daily: 40, kind: 'count' },
    review_focused: { daily: 40, kind: 'count' },
    review_followup: { daily: 60, kind: 'count' },
    transcription: { daily: 60 * 60, kind: 'seconds' },
    clean: { daily: 160, kind: 'count' },
    hidden_tag_cluster: { daily: 20, kind: 'count' },
    hidden_tag_normalize: { daily: 20, kind: 'count' },
    quick_ack: { daily: 240, kind: 'count' },
    tasks: { daily: 50, kind: 'count' }
  },
  reviewer: {
    chat: { daily: 200, kind: 'count' },
    assist_archive: { daily: 50, kind: 'count' },
    atomize: { daily: 180, kind: 'count' },
    tag_suggest: { daily: 220, kind: 'count' },
    review_overview: { daily: 60, kind: 'count' },
    review_focused: { daily: 60, kind: 'count' },
    review_followup: { daily: 80, kind: 'count' },
    transcription: { daily: 90 * 60, kind: 'seconds' },
    clean: { daily: 220, kind: 'count' },
    hidden_tag_cluster: { daily: 30, kind: 'count' },
    hidden_tag_normalize: { daily: 30, kind: 'count' },
    quick_ack: { daily: 300, kind: 'count' },
    tasks: { daily: 80, kind: 'count' }
  }
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
  fs.mkdirSync(path.dirname(storePath), { recursive: true });
  fs.writeFileSync(storePath, JSON.stringify(store, null, 2));
}

function todayKey() {
  return new Date().toISOString().slice(0, 10);
}

function splitList(raw) {
  if (!raw) return [];
  return raw.split(',').map((item) => item.trim()).filter(Boolean);
}

function normalizeTier(rawTier) {
  const tier = (rawTier || '').trim().toLowerCase();
  return VALID_TIERS.has(tier) ? tier : 'free';
}

function parseTierOverrides() {
  const raw = process.env.USAGE_TIER_OVERRIDES || '';
  if (!raw) return {};
  try {
    const parsed = JSON.parse(raw);
    return typeof parsed === 'object' && parsed ? parsed : {};
  } catch {
    return {};
  }
}

function parseLimitOverrides() {
  const raw = process.env.USAGE_LIMIT_OVERRIDES || '';
  if (!raw) return {};
  try {
    const parsed = JSON.parse(raw);
    return typeof parsed === 'object' && parsed ? parsed : {};
  } catch {
    return {};
  }
}

function dayBucket(store, userId, date = todayKey()) {
  store.usage ||= {};
  store.usage[userId] ||= {};
  store.usage[userId][date] ||= {};
  return store.usage[userId][date];
}

export function resolveUsageTier(userId) {
  const overrides = parseTierOverrides();
  if (userId && overrides[userId]) {
    return normalizeTier(overrides[userId]);
  }

  const proUsers = splitList(process.env.USAGE_PRO_USER_IDS);
  if (userId && proUsers.includes(userId)) return 'pro';

  const reviewerUsers = [
    ...splitList(process.env.USAGE_REVIEWER_USER_IDS),
    ...splitList(process.env.REVIEW_WHITELIST)
  ];
  if (userId && reviewerUsers.includes(userId)) return 'reviewer';

  return normalizeTier(process.env.USAGE_DEFAULT_TIER || 'free');
}

export function limitFor(requestType, tier = 'free') {
  const normalizedTier = normalizeTier(tier);
  const tierLimits = TIER_LIMITS[normalizedTier] || TIER_LIMITS.free;
  const baseLimit = tierLimits[requestType] || TIER_LIMITS.free[requestType] || { daily: 30, kind: 'count' };
  const overrides = parseLimitOverrides();
  const override = overrides?.[normalizedTier]?.[requestType] || overrides?.[requestType];
  if (typeof override === 'number') {
    return { ...baseLimit, daily: override };
  }
  if (override && typeof override === 'object') {
    return {
      daily: Number(override.daily ?? baseLimit.daily),
      kind: override.kind || baseLimit.kind
    };
  }
  return baseLimit;
}

export function checkQuota(userId, requestType, amount = 1, tier = resolveUsageTier(userId)) {
  const store = loadStore();
  const bucket = dayBucket(store, userId);
  const entry = bucket[requestType] || { used: 0 };
  const limit = limitFor(requestType, tier);
  return {
    allowed: entry.used + amount <= limit.daily,
    used: entry.used,
    nextUsed: entry.used + amount,
    limit: limit.daily,
    unit: limit.kind,
    tier,
    date: todayKey()
  };
}

export function consumeQuota(userId, requestType, amount = 1, tier = resolveUsageTier(userId)) {
  const store = loadStore();
  const bucket = dayBucket(store, userId);
  bucket[requestType] ||= { used: 0, tier };
  bucket[requestType].used += amount;
  bucket[requestType].tier = tier;
  saveStore(store);
  return bucket[requestType].used;
}

export function recordUsageEvent({
  userId,
  requestType,
  success,
  audioSeconds = 0,
  estimatedTokens = 0,
  model = null,
  provider = null,
  detail = null,
  tier = resolveUsageTier(userId)
}) {
  const store = loadStore();
  store.events ||= [];
  store.events.push({
    user_id: userId,
    tier,
    request_type: requestType,
    success,
    audio_seconds: audioSeconds,
    estimated_tokens: estimatedTokens,
    model,
    provider,
    detail,
    created_at: new Date().toISOString()
  });
  if (store.events.length > 5000) {
    store.events = store.events.slice(-5000);
  }
  saveStore(store);
}

export function quotaErrorPayload(userId, requestType, amount = 1, tier = resolveUsageTier(userId)) {
  const status = checkQuota(userId, requestType, amount, tier);
  return {
    error: 'quota_exceeded',
    request_type: requestType,
    tier: status.tier,
    unit: status.unit,
    used: status.used,
    attempted: amount,
    limit: status.limit,
    reset_date: status.date
  };
}

export function listRecentUsageEvents(limit = 200) {
  const store = loadStore();
  return (store.events || []).slice(-limit).reverse();
}

export function listRecentUsageEventsForUser(userId, limit = 100) {
  return listRecentUsageEvents(limit * 5).filter((entry) => entry.user_id === userId).slice(0, limit);
}

export function getDailyUsageForUser(userId, date = todayKey()) {
  const store = loadStore();
  const bucket = store.usage?.[userId]?.[date] || {};
  return {
    date,
    tier: resolveUsageTier(userId),
    entries: bucket
  };
}

export function getUsageDashboardSummary(date = todayKey()) {
  const store = loadStore();
  const requestTotals = {};
  const tierTotals = {};
  let totalRequests = 0;
  let totalTranscriptionSeconds = 0;

  for (const [userId, perUser] of Object.entries(store.usage || {})) {
    const day = perUser?.[date] || {};
    const tier = resolveUsageTier(userId);
    for (const [requestType, entry] of Object.entries(day)) {
      const used = Number(entry?.used || 0);
      requestTotals[requestType] = (requestTotals[requestType] || 0) + used;
      tierTotals[tier] = (tierTotals[tier] || 0) + used;
      totalRequests += used;
      if (requestType === 'transcription') {
        totalTranscriptionSeconds += used;
      }
    }
  }

  const todayEvents = (store.events || []).filter((entry) => (entry.created_at || '').slice(0, 10) === date);
  const quotaHits = todayEvents.filter((entry) => entry.detail === 'quota_exceeded').length;
  const activeUsers = new Set(todayEvents.map((entry) => entry.user_id).filter(Boolean)).size;
  const estimatedTokens = todayEvents.reduce((sum, entry) => sum + Number(entry.estimated_tokens || 0), 0);

  return {
    date,
    total_requests: totalRequests,
    total_transcription_seconds: totalTranscriptionSeconds,
    estimated_tokens: estimatedTokens,
    active_users: activeUsers,
    quota_hits: quotaHits,
    tier_totals: Object.entries(tierTotals)
      .sort((left, right) => right[1] - left[1])
      .map(([tier, used]) => ({ tier, used })),
    request_totals: Object.entries(requestTotals)
      .sort((left, right) => right[1] - left[1])
      .map(([request_type, used]) => ({ request_type, used }))
  };
}

export function getUserUsageSummary(userId, date = todayKey()) {
  const tier = resolveUsageTier(userId);
  const daily = getDailyUsageForUser(userId, date).entries;
  const entries = Object.entries(daily)
    .sort((left, right) => {
      const leftUsed = Number(left[1]?.used || 0);
      const rightUsed = Number(right[1]?.used || 0);
      return rightUsed - leftUsed;
    })
    .map(([request_type, value]) => ({
      request_type,
      used: Number(value?.used || 0),
      limit: limitFor(request_type, tier).daily,
      unit: limitFor(request_type, tier).kind,
      tier
    }));

  const recentEvents = listRecentUsageEventsForUser(userId, 50);
  const quotaHits = recentEvents.filter((entry) => entry.detail === 'quota_exceeded').length;
  const estimatedTokens = recentEvents.reduce((sum, entry) => sum + Number(entry.estimated_tokens || 0), 0);

  return {
    date,
    tier,
    entries,
    transcription_seconds: Number(daily?.transcription?.used || 0),
    estimated_tokens: estimatedTokens,
    quota_hits: quotaHits,
    recent_events: recentEvents
  };
}
