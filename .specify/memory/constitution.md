<!--
Sync Impact Report
==================
Version change: 1.0.0 → 1.1.0
Modified principles: N/A
Added sections:
  - VI. 日本語対応 (new principle)
Removed sections: N/A
Templates requiring updates:
  ✅ .specify/memory/constitution.md — this file (updated)
  ✅ .specify/templates/plan-template.md — no update needed
  ✅ .specify/templates/spec-template.md — no update needed
  ✅ .specify/templates/tasks-template.md — no update needed
Follow-up TODOs: None
-->

# ClaudeBestGame Constitution

## Core Principles

### I. Swift & SwiftUI First
All UI MUST be built with SwiftUI; UIKit or AppKit MUST NOT be introduced without a documented
justification in plan.md. App logic MUST be written in Swift; no Objective-C code may be added.
SwiftData MUST be used as the persistence layer for all model objects requiring durability.

### II. MVVM Architecture
Views MUST be thin — they own only layout and user-interaction binding.
Business logic MUST live in Observable ViewModels or dedicated service types, never in View bodies.
Data flow MUST be unidirectional: model → ViewModel → View → action → ViewModel.
No cross-cutting state MUST be stored directly in SwiftUI environment unless it is truly global
(e.g., theme, locale).

### III. Test-First (NON-NEGOTIABLE)
Every new feature MUST have XCTest unit tests written before implementation begins.
Tests MUST be confirmed failing before any implementation code is written (Red-Green-Refactor).
Primary user journeys identified in spec.md MUST be covered by XCUITest UI tests.
Mocking SwiftData models is permitted for unit tests; integration tests MUST use an in-memory
ModelContainer.

### IV. Cross-Platform Compatibility
The app MUST build and run on both iOS 17+ and macOS 14+ without duplicating logic.
Platform differences MUST be handled with `#if os(iOS)` / `#if os(macOS)` compile conditions.
Each new screen or user flow MUST be manually verified on both platforms before the branch merges.

### V. Simplicity & YAGNI

No abstraction, pattern, or third-party dependency MUST be introduced without a concrete,
present need documented in plan.md.
The codebase MUST remain auditable by a single developer within one session.
Complexity that violates any principle MUST be justified in plan.md's Complexity Tracking table
before implementation begins.

### VI. 日本語対応
AIアシスタント（Claude）はこのプロジェクトに関するすべての返答を日本語で行わなければならない。
コードのコメントは英語でも可とするが、説明・提案・質問への回答はすべて日本語を使用すること。

## Development Standards

All code MUST build without Xcode warnings before merging.
All public model types MUST conform to relevant SwiftData / Codable protocols where persistence
or serialization is required.
Assets MUST be managed in the Xcode asset catalog (`Assets.xcassets`); no loose image files.
The Xcode project file (`project.pbxproj`) MUST be kept conflict-free; resolve conflicts before
pushing.
Commit messages MUST follow the pattern: `type: short description` (e.g., `feat: add score board`).

## Quality Gates

Before any feature branch merges to `main`, ALL of the following MUST pass:

1. All XCTest unit tests pass (`xcodebuild test -scheme ClaudeBestGame`).
2. All XCUITest UI tests pass on the primary target platform.
3. Build completes with zero warnings.
4. Constitution Check in plan.md is reviewed and signed off.
5. A peer review (or self-review with a 24-hour cooling-off period) approves the diff.

## Governance

This constitution MUST supersede all other practices and verbal agreements.
Amendments MUST be submitted as a pull request that:
  - Updates `.specify/memory/constitution.md` with a bumped version.
  - Includes a Sync Impact Report (as an HTML comment at the top of the file).
  - Provides a rationale for the change.
All PRs and code reviews MUST verify compliance with Core Principles before approval.
Complexity violations MUST be justified in plan.md's Complexity Tracking table before
implementation begins.
The runtime development guidance file is `CLAUDE.md`.

**Version**: 1.1.0 | **Ratified**: 2026-05-07 | **Last Amended**: 2026-05-07
