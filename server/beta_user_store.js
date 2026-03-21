import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';

const storePath = path.join(os.tmpdir(), 'lifenarrator_beta_users.json');

function loadStore() {
  try {
    const raw = fs.readFileSync(storePath, 'utf8');
    return JSON.parse(raw || '{}');
  } catch {
    return { users: {} };
  }
}

function saveStore(store) {
  fs.writeFileSync(storePath, JSON.stringify(store, null, 2));
}

export function noteSeenUser({ userId, appId, appVersion, authProvider = 'local_beta_id' }) {
  if (!userId) return;
  const store = loadStore();
  const now = new Date().toISOString();
  const existing = store.users[userId] || {
    user_id: userId,
    auth_provider: authProvider,
    created_at: now
  };

  existing.last_seen_at = now;
  if (appId) existing.last_app_id = appId;
  if (appVersion) existing.last_app_version = appVersion;
  store.users[userId] = existing;
  saveStore(store);
}

export function getBetaUser(userId) {
  const store = loadStore();
  return store.users[userId] || null;
}

export function listBetaUsers() {
  const store = loadStore();
  return Object.values(store.users || {}).sort((left, right) => {
    const leftSeen = left.last_seen_at || left.created_at || '';
    const rightSeen = right.last_seen_at || right.created_at || '';
    return rightSeen.localeCompare(leftSeen);
  });
}

export function findBetaUserByAppleSubject(appleSubject) {
  if (!appleSubject) return null;
  const store = loadStore();
  return Object.values(store.users || {}).find((entry) => entry.apple_subject === appleSubject) || null;
}

export function registerBetaUser({ inviteCode, email, displayName = null, appleSubject = null }) {
  const store = loadStore();
  const existingByApple = appleSubject ? findBetaUserByAppleSubject(appleSubject) : null;
  if (existingByApple) {
    const existing = store.users[existingByApple.user_id];
    existing.last_seen_at = new Date().toISOString();
    if (email) existing.email = email;
    if (displayName) existing.display_name = displayName;
    if (inviteCode) existing.invite_code = inviteCode;
    store.users[existing.user_id] = existing;
    saveStore(store);
    return existing;
  }

  const userId = `beta_user_${crypto.randomUUID().replace(/-/g, '').slice(0, 16)}`;
  const now = new Date().toISOString();
  const entry = {
    user_id: userId,
    auth_provider: appleSubject ? 'apple_id' : 'invite_code',
    invite_code: inviteCode || null,
    email: email || null,
    display_name: displayName || null,
    apple_subject: appleSubject || null,
    created_at: now,
    last_seen_at: now
  };

  store.users[userId] = entry;
  saveStore(store);
  return entry;
}
