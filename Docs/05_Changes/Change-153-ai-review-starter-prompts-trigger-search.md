# Change 153 - AI Review starter prompts trigger search

## Summary
Fixed AI Review example prompt taps so they reliably start retrieval immediately instead of only updating the input field.

## What changed
- Added a suppression flag for `query` change handling when the query is being set programmatically for an immediate search.
- Routed starter prompt taps through a dedicated submit helper that fills the query and launches retrieval in one step.

## Files
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/Screens/SearchScreen.swift`
