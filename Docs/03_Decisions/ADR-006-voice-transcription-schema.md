# ADR-006 — Add Voice/Transcription Fields to CaptureEntity

## Meta
- Date: 2026-03-04
- Status: Accepted
- Decision owners: Codex
- Scope: DB / UI
- Related Skills:
  - Skills/speech-transcription/SKILL.md
- Related files/modules:
  - Life Narattor/Life Narattor/Data/CaptureEntity.swift
  - Life Narattor/Life Narattor/Data/PersistenceController.swift

## Context
- Speech transcription flow needs to persist input type, audio path, transcript, and status.

## Decision
- Add fields to CaptureEntity: inputType, audioPath, transcriptText, transcriptionStatus.

## Rationale
- Enables UI to show voice capture status and raw transcript playback area.
- Matches speech-transcription skill requirements.

## Consequences
- Positive:
  - Supports placeholder voice flow and future transcription engine.
- Negative:
  - CoreData schema change; dev store reset may occur.

## Validation
- Record voice placeholder and see capture status update to “正在转写…”, then “转写完成”.

## Links
- Session log: Docs/04_Sessions/2026-03-04_session-011.md
- Change log: Docs/05_Changes/Change-014-voice-transcription-placeholder.md
