import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const storePath = path.join(os.tmpdir(), 'lifenarrator_invites.json');

function loadStore() {
  try {
    const raw = fs.readFileSync(storePath, 'utf8');
    return JSON.parse(raw || '{}');
  } catch {
    return { invites: {} };
  }
}

function saveStore(store) {
  fs.writeFileSync(storePath, JSON.stringify(store, null, 2));
}

function nowISO() {
  return new Date().toISOString();
}

function newInviteCode() {
  return crypto.randomBytes(4).toString('hex').toUpperCase();
}

export function listInvites() {
  const store = loadStore();
  return Object.values(store.invites || {}).sort((left, right) => {
    const leftCreated = left.created_at || '';
    const rightCreated = right.created_at || '';
    return rightCreated.localeCompare(leftCreated);
  });
}

export function getInviteByCode(inviteCode) {
  if (!inviteCode) return null;
  const store = loadStore();
  return store.invites[inviteCode] || null;
}

export function createInvite({ email, createdBy = 'admin', notes = null }) {
  const store = loadStore();
  let inviteCode = newInviteCode();
  while (store.invites[inviteCode]) {
    inviteCode = newInviteCode();
  }

  const entry = {
    invite_code: inviteCode,
    email,
    status: 'created',
    created_at: nowISO(),
    sent_at: null,
    used_at: null,
    created_by: createdBy,
    user_id: null,
    notes: notes || null,
    send_error: null,
    send_attempts: 0
  };

  store.invites[inviteCode] = entry;
  saveStore(store);
  return entry;
}

export function markInviteSent(inviteCode) {
  const store = loadStore();
  const entry = store.invites[inviteCode];
  if (!entry) return null;
  entry.status = 'sent';
  entry.sent_at = nowISO();
  entry.send_error = null;
  entry.send_attempts = Number(entry.send_attempts || 0) + 1;
  store.invites[inviteCode] = entry;
  saveStore(store);
  return entry;
}

export function markInviteSendFailed(inviteCode, message) {
  const store = loadStore();
  const entry = store.invites[inviteCode];
  if (!entry) return null;
  entry.status = 'send_failed';
  entry.send_error = message || 'unknown_send_error';
  entry.send_attempts = Number(entry.send_attempts || 0) + 1;
  store.invites[inviteCode] = entry;
  saveStore(store);
  return entry;
}

export function markInviteUsed(inviteCode, userId) {
  const store = loadStore();
  const entry = store.invites[inviteCode];
  if (!entry) return null;
  entry.status = 'used';
  entry.used_at = nowISO();
  entry.user_id = userId || null;
  store.invites[inviteCode] = entry;
  saveStore(store);
  return entry;
}

export function revokeInvite(inviteCode) {
  const store = loadStore();
  const entry = store.invites[inviteCode];
  if (!entry) return null;
  entry.status = 'revoked';
  store.invites[inviteCode] = entry;
  saveStore(store);
  return entry;
}
