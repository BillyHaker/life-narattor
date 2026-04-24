---
name: ci-and-quality-assurance
description: Universal guidelines for continuous integration pipelines and code quality; ensures automated testing and governance across projects.
version: 1.0
tags:
  - ci
  - quality
  - testing
  - automation
---
# Continuous Integration and Quality Assurance

## Purpose
Establish a baseline for automated build, test and code quality processes that any project derived from this seed pack should adopt.

## Required components

- **Build pipeline**: Automated building of all targets on each commit. Fail fast on build errors.
- **Static analysis**: Linting and code format checks using language‑appropriate tools. Fail the build on violations.
- **Unit and integration tests**: Run all tests and ensure a minimum coverage threshold is met. Use the `acceptance-testing-min-bar` skill as a reference for acceptance criteria.
- **Security scanning**: Automated scans for vulnerabilities and licence compliance.
- **Artefact storage**: Store build artefacts and test reports for traceability.
- **Notifications**: Notify the team of build status and test failures.

## Guidelines

- Pipelines should run on every merge request and on the main branch.
- Tests must run in a representative environment (e.g., emulated devices, browsers).
- Coverage thresholds must be set and gradually increased.
- All results (build logs, test reports, coverage metrics) must be archived and linked to the Docs/05_Changes or a CI dashboard.

## Acceptance
A project meets this skill when:

- A CI pipeline is configured and runs automatically.
- Static analysis and tests gate merges.
- Failures and issues are visible to the team.
- Documentation records the pipeline configuration and links to the latest run results.