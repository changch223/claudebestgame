# Implementation Plan: 白い嘘 — One Minute Interrogation

**Branch**: `001-ios-best-game` | **Date**: 2026-05-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-ios-best-game/spec.md`

---

## Summary

プレイヤーが検事となり、Apple Foundation Models が演じる嘘つき容疑者を
**60秒以内**に矛盾を突いて自白させる1分尋問パズルゲーム。

各事件は AI が Structured Output で生成（事件・容疑者人格・真実・アリバイ）。
容疑者は LanguageModelSession でアリバイを維持しつつ応答し、
別の AI 処理（矛盾検出ツール）が各返答の整合性を判定して自白ゲージを動かす。
10事件クリアで180秒の黒幕戦が解禁される。

---

## Technical Context

**Language/Version**: Swift 6.0（Xcode 16.3+、strict concurrency）
**Primary Dependencies**:
- `FoundationModels`（LanguageModelSession + Tool + @Generable Structured Output）
- `SwiftUI`（全UI）
- `SwiftData`（プレイ記録・進捗永続化）
- `Combine`または`Observation`（タイマー・自白ゲージのリアクティブ更新）

**Storage**: SwiftData（ローカル）
**Testing**: XCTest（ユニット）+ XCUITest（UI）
**Target Platform**: iOS 18.1+ Apple Intelligence 対応 iPhone（iPhone 15 Pro / 16 シリーズ）
非対応端末はフォールバックモードで動作
**Project Type**: iOS Mobile App（単一Xcodeプロジェクト）
**Performance Goals**:
- 容疑者返答開始 < 1秒（オンデバイス低遅延が体験の核）
- 事件生成（Structured Output） < 5秒
- 矛盾検出 < 0.5秒
- UI レンダリング 60fps

**Constraints**:
- 完全オンデバイス処理（FR-011：ネットワーク通信禁止）
- 60秒のタイマー精度を保証（タイマーが遅延すると体験が崩れる）
- フォールバックモードでもコアループが完全動作

**Scale/Scope**:
- シングルプレイヤー、ローカルデータのみ
- 通常事件 10件 + 黒幕戦 1件 + +ボーナスモード（無制限）
- 容疑者人格 5タイプ × 事件タイプ 10種類 = 概念上50種類の組み合わせ

---

## Constitution Check

*GATE: Phase 0 開始前に確認。Phase 1 設計後に再確認。*

| 原則 | 判定 | 根拠 |
|------|------|------|
| I. Swift & SwiftUI First | ✅ PASS | SwiftUI全面採用、SwiftData採用、Objective-C不使用 |
| II. MVVM Architecture | ✅ PASS | View / ViewModel / Service の3層構造 |
| III. Test-First | ✅ PASS | 矛盾検出ロジック・タイマー・スコア計算は XCTest 必須 |
| IV. Cross-Platform | ⚠️ JUSTIFIED | 下記 Complexity Tracking 参照 |
| V. Simplicity & YAGNI | ✅ PASS | Apple純正フレームワークのみ・1画面構成・単機能 |
| VI. 日本語対応 | ✅ PASS | 全UI・尋問・事件説明が日本語 |

**Phase 1 再確認**: ✅ 設計後も全原則を満たす

---

## Project Structure

### Documentation (this feature)

```text
specs/001-ios-best-game/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── ai-tools.md         # 矛盾検出ツール仕様
│   ├── case-schema.md      # 事件 Structured Output スキーマ
│   └── suspect-protocol.md # 容疑者AIプロトコル
└── tasks.md
```

### Source Code (repository root)

```text
ClaudeBestGame/
├── ClaudeBestGameApp.swift
├── Models/                          # SwiftData @Model
│   ├── CaseRecord.swift             # 生成された事件のスナップショット
│   ├── SuspectRecord.swift          # 容疑者プロファイル
│   ├── InterrogationTurn.swift      # 1ターン記録
│   ├── PlaySession.swift            # 1プレイ全体
│   └── Progress.swift               # キャンペーン進捗（シングルトン）
├── ViewModels/
│   ├── GameRootViewModel.swift      # メニュー・解禁状態
│   ├── InterrogationViewModel.swift # 尋問中の全状態
│   └── ResultViewModel.swift        # 勝敗・スコア表示
├── Views/
│   ├── Root/RootView.swift
│   ├── Menu/MenuView.swift          # スタート・ハイスコア・黒幕戦ボタン
│   ├── Interrogation/
│   │   ├── InterrogationView.swift  # メイン1画面
│   │   ├── TimerBar.swift           # 60秒タイマー表示
│   │   ├── ConfessionGauge.swift    # 自白ゲージ
│   │   ├── SuspectAvatar.swift      # 容疑者アバター
│   │   ├── DialogueLog.swift        # 会話ログ
│   │   └── QuestionInputBar.swift   # 質問入力
│   ├── Result/
│   │   ├── VictoryView.swift        # 勝利演出
│   │   └── DefeatView.swift         # 敗北＋真実公開
│   └── Ending/EndingView.swift      # 黒幕戦エンディング
├── Services/
│   ├── AI/
│   │   ├── CaseGeneratorService.swift   # 事件＋容疑者を Structured Output で生成
│   │   ├── SuspectService.swift         # 容疑者 LanguageModelSession ラッパー
│   │   ├── ContradictionDetector.swift  # 矛盾検出ロジック
│   │   └── FallbackCaseProvider.swift   # 非対応端末用固定事件
│   ├── Game/
│   │   ├── InterrogationTimer.swift     # 高精度60秒タイマー
│   │   ├── ConfessionGaugeEngine.swift  # ゲージ計算
│   │   └── ScoreCalculator.swift        # スコア算出
│   └── Persistence/
│       └── ProgressRepository.swift     # 進捗・ハイスコアの読み書き
└── Resources/
    ├── Assets.xcassets
    ├── Personas/                    # 容疑者人格テンプレート（5タイプ）
    └── FallbackCases/               # 固定事件10件のJSON

ClaudeBestGameTests/
├── ContradictionDetectorTests.swift
├── ConfessionGaugeEngineTests.swift
├── ScoreCalculatorTests.swift
├── CaseGeneratorTests.swift
└── InterrogationTimerTests.swift

ClaudeBestGameUITests/
├── InterrogationFlowUITests.swift
└── EndingFlowUITests.swift
```

**Structure Decision**: 既存の `ClaudeBestGame.xcodeproj` を流用し、上記フォルダ構成を Xcode グループとして追加する。1画面中心の設計のため、ルートには NavigationStack ではなく状態駆動の View 切替（メニュー/尋問/結果）を採用する。

---

## Complexity Tracking

| 違反原則 | 理由 | より簡単な代替を採用しない理由 |
|---------|------|-------------------------------|
| IV. Cross-Platform（iOS専用） | Apple Foundation Models が現時点で iOS 18.1+ Apple Intelligence 対応端末のみサポート。macOS 版は対象端末が少なく v1 スコープ外 | macOS 対応には Apple Intelligence の Mac 版が広く普及するまで待つのが現実的。`#if os(macOS)` だけでは動作しない（モデル自体が無い） |
