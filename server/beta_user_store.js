import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

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
