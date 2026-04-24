# TDD_GUIDE (Universal)

Test‑driven development (TDD) helps ensure correctness and reduces regression by guiding the design through tests.  Use this guide to set minimum expectations for testing in any project.

## TDD cycle
1. **Red** – Write a failing test that defines the desired behaviour.
2. **Green** – Implement the smallest amount of code necessary to make the test pass.
3. **Refactor** – Clean up the implementation while keeping all tests passing.

## Coverage targets
- Aim for at least **70–80% test coverage** on critical paths.  Coverage can be lower on boilerplate or auto‑generated code, but business logic should be exercised thoroughly.
- Focus on paths that are hard to manually verify, such as asynchronous flows, edge cases and error handling.

## Must‑test cases
- **Nil/empty input** – Verify the system behaves sensibly when given empty or nil values.
- **Boundary values** – Test the lower and upper bounds of ranges and collections.
- **Error and exception paths** – Ensure the system gracefully handles invalid input, network failures, and other exceptional conditions.
- **Concurrency and race conditions** – When using asynchronous code or shared state, test for race conditions and ensure thread safety.

## Tools
- Use the unit testing framework provided by your chosen language (e.g. Jest, XCTest, JUnit).
- Automate UI or end‑to‑end tests where practical to verify interaction flows.

## Minimum bar
- Critical path has at least one automated test **or** clear manual verification steps.
- For contracts (AI/API/DB), include golden fixtures or examples to validate inputs and outputs.
- Prefer small, testable units.  Avoid intertwining UI rendering with business logic.
