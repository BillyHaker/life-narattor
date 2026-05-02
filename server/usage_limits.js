import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const storePath = process.env.USAGE_STORE_PATH || path.join(os.tmpdir(), 'lifenarrator_usage_store.json');
const VALID_TIERS = new Set(['trial', 'free', 'daily', 'deep', 'reviewer']);
const TRIAL_DAYS = Number(process.env.USAGE_TRIAL_DAYS || 7);

const TIER_CREDITS = {
  trial: 700,
  free: 300,
  daily: 1500,
  deep: 4500,
  reviewer: 30000
};

const REQUEST_CREDIT_COSTS = {
  quick_ack: { credits: 0 },
  clean: { credits: 1 },
  atomize: { credits: 1 },
  tag_suggest: { credits: 1 },
  chat: { credits: 3 },
  assist_archive: { credits: 8 },
  review_overview: { credits: 5 },
  review_focused: { credits: 5 },
  review_followup: { credits: 3 },
  transcription: { creditsPerMinute: 10, minimumCredits: 1 },
  hidden_tag_cluster: { credits: 20 },
  hidden_tag_normalize: { credits: 20 },
  tasks: { credits: 0 }
};

function loadStore() {
  try {
    const raw = fs.readFileSync(storePath, 'utf8');
    return JSON.parse(raw || '{}');
  } catch {
    return { usage: {}, events: [], users: {} };
  }
}

function saveStore(store) {
  fs.mkdirSync(path.dirname(storePath), { recursive: true });
  fs.writeFileSync(storePath, JSON.stringify(store, null, 2));
}

function nowDate() {
  return new Date();
}

function todayKey() {
  return nowDate().toISOString().slice(0, 10);
}

function monthKey(date = nowDate()) {
  return date.toISOString().slice(0, 7);
}

function cycleKeyForTier(tier, profile) {
  if (tier === 'trial') {
    return `trial:${(profile?.first_seen_at || todayKey()).slice(0, 10)}`;
  }
  return monthKey();
}

function splitList(raw) {
  if (!raw) return [];
  return raw.split(',').map((item) => item.trim()).filter(Boolean);
}

function normalizeTier(rawTier) {
  const tier = (rawTier || '').trim().toLowerCase();
  if (tier === 'pro') return 'deep';
  return VALID_TIERS.has(tier) ? tier : 'free';
}

function parseJSONEnv(name) {
  const raw = process.env[name] || '';
  if (!raw) return {};
  try {
    const parsed = JSON.parse(raw);
    return typeof parsed === 'object' && parsed ? parsed : {};
  } catch {
    return {};
  }
}

function ensureStoreShape(store) {
  store.usage ||= {};
  store.events ||= [];
  store.users ||= {};
  store.credit_usage ||= {};
  return store;
}

function ensureUserProfile(store, userId) {
  ensureStoreShape(store);
  const now = nowDate().toISOString();
  store.users[userId] ||= {
    user_id: userId,
    first_seen_at: now,
    created_at: now
  };
  if (!store.users[userId].first_seen_at) {
    store.users[userId].first_seen_at = store.users[userId].created_at || now;
  }
  return store.users[userId];
}

function addDays(date, days) {
  const copy = new Date(date.getTime());
  copy.setUTCDate(copy.getUTCDate() + days);
  return copy;
}

function trialStatusFor(profile) {
  const firstSeen = new Date(profile?.first_seen_at || nowDate().toISOString());
  const endsAt = addDays(firstSeen, TRIAL_DAYS);
  const active = nowDate().getTime() < endsAt.getTime();
  return {
    active,
    started_at: firstSeen.toISOString(),
    ends_at: endsAt.toISOString(),
    days_remaining: active ? Math.max(0, Math.ceil((endsAt.getTime() - nowDate().getTime()) / 86_400_000)) : 0
  };
}

function effectiveTrialStatusFor(tier, profile) {
  if (tier !== 'trial') {
    return { active: false, started_at: profile?.first_seen_at || null, ends_at: null, days_remaining: 0 };
  }
  return trialStatusFor(profile);
}

function resetDateForTier(tier, profile) {
  if (tier === 'trial') {
    return trialStatusFor(profile).ends_at.slice(0, 10);
  }
  return nextMonthResetDate();
}

export function resolveUsageTier(userId, store = loadStore()) {
  const normalizedStore = ensureStoreShape(store);
  const profile = userId ? ensureUserProfile(normalizedStore, userId) : null;
  const overrides = parseJSONEnv('USAGE_TIER_OVERRIDES');

  if (userId && overrides[userId]) {
    const tier = normalizeTier(overrides[userId]);
    if (tier === 'trial') {
      return trialStatusFor(profile).active ? 'trial' : 'free';
    }
    return tier;
  }

  const dailyUsers = splitList(process.env.USAGE_DAILY_USER_IDS);
  if (userId && dailyUsers.includes(userId)) return 'daily';

  const deepUsers = [
    ...splitList(process.env.USAGE_DEEP_USER_IDS),
    ...splitList(process.env.USAGE_PRO_USER_IDS)
  ];
  if (userId && deepUsers.includes(userId)) return 'deep';

  const reviewerUsers = [
    ...splitList(process.env.USAGE_REVIEWER_USER_IDS),
    ...splitList(process.env.REVIEW_WHITELIST)
  ];
  if (userId && reviewerUsers.includes(userId)) return 'reviewer';

  const defaultTier = normalizeTier(process.env.USAGE_DEFAULT_TIER || 'trial');
  if (defaultTier === 'trial') {
    return trialStatusFor(profile).active ? 'trial' : 'free';
  }
  return defaultTier;
}

function creditLimitFor(tier = 'free') {
  const normalizedTier = normalizeTier(tier);
  const overrides = parseJSONEnv('USAGE_CREDIT_LIMIT_OVERRIDES');
  const value = Number(overrides?.[normalizedTier] ?? TIER_CREDITS[normalizedTier] ?? TIER_CREDITS.free);
  return Number.isFinite(value) && value >= 0 ? value : TIER_CREDITS.free;
}

export function creditCostFor(requestType, amount = 1) {
  const overrides = parseJSONEnv('USAGE_CREDIT_COST_OVERRIDES');
  const override = overrides?.[requestType];
  if (typeof override === 'number') {
    return Math.max(0, Math.ceil(override));
  }
  if (override && typeof override === 'object') {
    if (typeof override.credits === 'number') return Math.max(0, Math.ceil(override.credits));
    if (typeof override.creditsPerMinute === 'number') {
      const minutes = Math.max(0, Number(amount || 0)) / 60;
      return Math.max(Number(override.minimumCredits ?? 1), Math.ceil(minutes * override.creditsPerMinute));
    }
  }

  const cost = REQUEST_CREDIT_COSTS[requestType] || { credits: 3 };
  if (typeof cost.credits === 'number') return Math.max(0, Math.ceil(cost.credits));
  const minutes = Math.max(0, Number(amount || 0)) / 60;
  return Math.max(cost.minimumCredits ?? 1, Math.ceil(minutes * cost.creditsPerMinute));
}

function cycleBucket(store, userId, cycle = monthKey()) {
  ensureStoreShape(store);
  store.credit_usage[userId] ||= {};
  store.credit_usage[userId][cycle] ||= {
    credits_used: 0,
    requests: {},
    cycle
  };
  return store.credit_usage[userId][cycle];
}

export function checkQuota(userId, requestType, amount = 1) {
  const store = loadStore();
  ensureUserProfile(store, userId);
  const tier = resolveUsageTier(userId, store);
  const cycle = cycleKeyForTier(tier, store.users[userId]);
  const bucket = cycleBucket(store, userId, cycle);
  const attemptedCredits = creditCostFor(requestType, amount);
  const limit = creditLimitFor(tier);
  const trial = effectiveTrialStatusFor(tier, store.users[userId]);
  saveStore(store);
  return {
    allowed: bucket.credits_used + attemptedCredits <= limit,
    used: bucket.credits_used,
    nextUsed: bucket.credits_used + attemptedCredits,
    attemptedCredits,
    limit,
    unit: 'credits',
    tier,
    cycle,
    trial,
    reset_date: resetDateForTier(tier, store.users[userId]),
    date: todayKey()
  };
}

export function consumeQuota(userId, requestType, amount = 1) {
  const store = loadStore();
  ensureUserProfile(store, userId);
  const tier = resolveUsageTier(userId, store);
  const cycle = cycleKeyForTier(tier, store.users[userId]);
  const bucket = cycleBucket(store, userId, cycle);
  const credits = creditCostFor(requestType, amount);
  bucket.credits_used += credits;
  bucket.tier = tier;
  bucket.updated_at = nowDate().toISOString();
  bucket.requests[requestType] ||= { count: 0, credits_used: 0 };
  bucket.requests[requestType].count += 1;
  bucket.requests[requestType].credits_used += credits;
  bucket.requests[requestType].last_amount = amount;
  saveStore(store);
  return bucket.credits_used;
}

export function recordUsageEvent({
  userId,
  requestType,
  success,
  audioSeconds = 0,
  estimatedTokens = 0,
  model = null,
  provider = null,
  credits = null,
  detail = null,
  tier = null
}) {
  const store = loadStore();
  ensureUserProfile(store, userId);
  const resolvedTier = tier || resolveUsageTier(userId, store);
  store.events ||= [];
  store.events.push({
    user_id: userId,
    tier: resolvedTier,
    cycle: cycleKeyForTier(resolvedTier, store.users[userId]),
    request_type: requestType,
    success,
    credits: credits ?? creditCostFor(requestType, requestType === 'transcription' ? audioSeconds : 1),
    audio_seconds: audioSeconds,
    estimated_tokens: estimatedTokens,
    model,
    provider,
    detail,
    created_at: nowDate().toISOString()
  });
  if (store.events.length > 5000) {
    store.events = store.events.slice(-5000);
  }
  saveStore(store);
}

export function quotaErrorPayload(userId, requestType, amount = 1) {
  const status = checkQuota(userId, requestType, amount);
  return {
    error: 'ai_credit_exhausted',
    request_type: requestType,
    tier: status.tier,
    unit: status.unit,
    used: status.used,
    attempted: status.attemptedCredits,
    limit: status.limit,
    cycle: status.cycle,
    reset_date: status.reset_date,
    trial: status.trial
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
  ensureUserProfile(store, userId);
  const tier = resolveUsageTier(userId, store);
  const events = (store.events || []).filter((entry) => entry.user_id === userId && (entry.created_at || '').slice(0, 10) === date);
  const entries = {};
  for (const event of events) {
    entries[event.request_type] ||= { used: 0, credits_used: 0, tier };
    entries[event.request_type].used += 1;
    entries[event.request_type].credits_used += Number(event.credits || 0);
  }
  return {
    date,
    tier,
    entries
  };
}

export function getUsageDashboardSummary(date = todayKey()) {
  const store = loadStore();
  ensureStoreShape(store);
  const requestTotals = {};
  const tierTotals = {};
  let totalRequests = 0;
  let totalCredits = 0;
  let totalTranscriptionSeconds = 0;

  const todayEvents = (store.events || []).filter((entry) => (entry.created_at || '').slice(0, 10) === date);
  for (const entry of todayEvents) {
    const requestType = entry.request_type || 'unknown';
    const tier = entry.tier || resolveUsageTier(entry.user_id, store);
    const credits = Number(entry.credits || 0);
    requestTotals[requestType] = (requestTotals[requestType] || 0) + credits;
    tierTotals[tier] = (tierTotals[tier] || 0) + credits;
    totalRequests += 1;
    totalCredits += credits;
    if (requestType === 'transcription') {
      totalTranscriptionSeconds += Number(entry.audio_seconds || 0);
    }
  }

  const quotaHits = todayEvents.filter((entry) => entry.detail === 'quota_exceeded' || entry.detail === 'ai_credit_exhausted').length;
  const activeUsers = new Set(todayEvents.map((entry) => entry.user_id).filter(Boolean)).size;
  const estimatedTokens = todayEvents.reduce((sum, entry) => sum + Number(entry.estimated_tokens || 0), 0);

  return {
    date,
    total_requests: totalRequests,
    total_credits: totalCredits,
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
  const store = loadStore();
  ensureUserProfile(store, userId);
  const tier = resolveUsageTier(userId, store);
  const cycle = cycleKeyForTier(tier, store.users[userId]);
  const bucket = cycleBucket(store, userId, cycle);
  const trial = effectiveTrialStatusFor(tier, store.users[userId]);
  const daily = getDailyUsageForUser(userId, date).entries;
  const entries = Object.entries(bucket.requests || {})
    .sort((left, right) => Number(right[1]?.credits_used || 0) - Number(left[1]?.credits_used || 0))
    .map(([request_type, value]) => ({
      request_type,
      used: Number(value?.credits_used || 0),
      request_count: Number(value?.count || 0),
      limit: creditLimitFor(tier),
      unit: 'credits',
      tier
    }));

  const recentEvents = listRecentUsageEventsForUser(userId, 50);
  const quotaHits = recentEvents.filter((entry) => entry.detail === 'quota_exceeded' || entry.detail === 'ai_credit_exhausted').length;
  const estimatedTokens = recentEvents.reduce((sum, entry) => sum + Number(entry.estimated_tokens || 0), 0);

  return {
    date,
    cycle,
    tier,
    trial,
    credit_limit: creditLimitFor(tier),
    credits_used: Number(bucket.credits_used || 0),
    credits_remaining: Math.max(0, creditLimitFor(tier) - Number(bucket.credits_used || 0)),
    entries,
    daily_entries: daily,
    transcription_seconds: recentEvents.reduce((sum, entry) => sum + Number(entry.audio_seconds || 0), 0),
    estimated_tokens: estimatedTokens,
    quota_hits: quotaHits,
    recent_events: recentEvents
  };
}

function nextMonthResetDate() {
  const now = nowDate();
  const nextMonth = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 1, 1));
  return nextMonth.toISOString().slice(0, 10);
}
