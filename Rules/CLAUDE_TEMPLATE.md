# CLAUDE.md — Project Rules (iOS SwiftUI)

## Project Focus
- Single-developer iOS SwiftUI project
- Architecture: MVVM + protocol-based DI + actor concurrency safety
- Goals: rapid iteration, stability, testability
- Supplemental rules: Rules/AI_RULES.md (copy from RulesSkills/AI_RULES.md)

## Structure (Typical)
- Models/ — data models
- Services/ — business services and data access
- ViewModels/ — state and flow orchestration
- Views/ — UI only
- Utilities/ — cross-cutting helpers

## Methodology Core
- Plan before implement
- Test before code
- Correctness first, then elegance
- Minimal change, no forced refactor

## Workflow (Must Follow)
1. Clarify requirements and success criteria
2. Plan (required for complex work)
3. TDD: Red -> Green -> Refactor
4. Minimal implementation
5. Self code review
6. Run tests / build validation

## Coding Order (Enforced)
1. Model/Protocol
2. Service layer + actor constraints
3. ViewModel state and flows
4. View rendering
5. Edge cases and error handling
6. Tests

## Concurrency & Safety
- Use actor to protect shared state
- Prefer async/await over manual locks
- Avoid shared mutable state
- Validate all external input

## Swift Best Practices
- 4-space indentation; PascalCase for types, camelCase for methods/properties
- Use @State private var for view state
- Prefer pure SwiftUI composition
- Avoid force unwrapping; use guard / if let

## TDD / Testing
- Unit tests: Testing framework
- UI tests: XCUIAutomation
- Coverage target: 80% (critical paths first)
- Must cover: nil/empty, boundaries, error paths, race conditions

## Code Review Checklist (Required)
- Logic correctness
- Error handling completeness
- Concurrency safety (actor boundaries)
- DI boundaries and testability
- UI and business logic separation
- Tests for new paths

## Context Management
- Read only necessary files
- Keep changes minimal
- Ask before changing unclear architecture
