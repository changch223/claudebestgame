---

description: "白い嘘 — Loops of Truth タスクリスト"
---

# Tasks: 白い嘘 — Loops of Truth

**Input**: specs/001-ios-best-game/ 以下の設計ドキュメント
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Note**: 旧「One Minute Interrogation」(自由テキスト入力 / 60 秒) のタスクは Phase 1〜4 で完了済み。
本タスク表は 2026-05-08 のコンセプト転換（選択肢 + ハイブリッドループ + 6 ターン制）後の状態を記録。
Phase 9 として新コンセプトの実装タスクを追加した。

**テスト方針**: Constitution III「Test-First (NON-NEGOTIABLE)」に従い、コアロジックは XCTest でカバー。

---

## Phase 1: Setup（プロジェクト基盤）

- [X] T001 ClaudeBestGame/ 以下に Models/ ViewModels/ Views/Root/ Views/Menu/ Views/Interrogation/ Views/Result/ Views/Ending/ Services/AI/ Services/Game/ Services/Persistence/ Resources/Personas/ Resources/FallbackCases/ のフォルダとXcodeグループを作成する
- [X] T002 [P] ClaudeBestGame/Resources/FallbackCases/cases.json を作成し、フォールバック用固定事件10件（caseType / victimName / suspectName / alibiStory / weakPoint / contradictionKeywords / scriptedAnswers を含む）をJSON配列で記述する
- [X] T003 [P] ClaudeBestGame/Resources/Personas/stoic.txt anxious.txt aggressive.txt pitiful.txt intellectual.txt を作成し、各人格タイプの口調・態度の追加システムプロンプト（30〜100文字日本語）を記述する
- [X] T004 [P] ClaudeBestGame/Resources/Personas/boss.txt を作成し、黒幕戦専用の最高難度システムプロンプト（200文字程度、人格は intellectual + stoic のハイブリッド）を記述する

---

## Phase 2: Foundational（共通基盤）

**⚠️ CRITICAL**: ここが終わるまで Phase 3 以降を開始しない。

- [X] T005 ClaudeBestGame/Models/CaseRecord.swift を作成し、data-model.md の CaseRecord @Model クラスを実装する
- [X] T006 [P] ClaudeBestGame/Models/SuspectRecord.swift を作成し、SuspectRecord @Model を実装する
- [X] T007 [P] ClaudeBestGame/Models/InterrogationTurn.swift を作成し、InterrogationTurn @Model を実装する
- [X] T008 [P] ClaudeBestGame/Models/PlaySession.swift を作成し、PlaySession @Model を実装する（result/finalGauge/remainingSeconds のバリデーション含む）
- [X] T009 [P] ClaudeBestGame/Models/Progress.swift を作成し、Progress @Model（id固定値）と highScoreByType の Codable エンコード/デコードヘルパを実装する
- [X] T010 ClaudeBestGameApp.swift を更新し、5モデルを含む ModelContainer を生成して App レベルで提供する
- [X] T011 ClaudeBestGame/Services/Persistence/ProgressRepository.swift を作成し、Progress シングルトン取得・更新・ハイスコア更新のヘルパを実装する
- [X] T012 ClaudeBestGame/Views/Root/RootView.swift を作成し、状態駆動の View 切替（メニュー/尋問/結果/エンディング）の骨格を実装する

**Checkpoint**: アプリが起動して空のメニュー画面が表示されることを確認する。

---

## Phase 3: User Story 1 — 1分尋問のコアループ（Priority: P1）🎯 MVP

**Goal**: 事件生成→60秒尋問→勝敗判定→結果表示の1ループが完走できる。
**Independent Test**: フォールバック事件1件を使い、誘導質問スクリプトでゲージ100%到達と勝利演出が表示されることを XCUITest で確認できる。

### US1 テスト（先に書いてRedを確認）

- [X] T013 [P] [US1] ClaudeBestGameTests/InterrogationTimerTests.swift を作成し、start(seconds: 60) が60秒後に remainingSeconds=0 に到達すること、pause()/resume() で経過時間が保持されることをテストする
- [X] T014 [P] [US1] ClaudeBestGameTests/ConfessionGaugeEngineTests.swift を作成し、severity=large + difficulty=1 で +30%、severity=medium + difficulty=5 で +9% になることをテストする
- [X] T015 [P] [US1] ClaudeBestGameTests/ScoreCalculatorTests.swift を作成し、敗北時0点・勝利時 base+bonus 計算・黒幕戦×3倍をテストする

### US1 実装

- [X] T016 [US1] ClaudeBestGame/Services/Game/InterrogationTimer.swift を作成し、research.md の高精度タイマー設計（50ms 解像度、@Observable、pause/resume対応）を実装する
- [X] T017 [US1] ClaudeBestGame/Services/Game/ConfessionGaugeEngine.swift を作成し、contracts/ai-tools.md の ConfessionGaugeEngine アルゴリズムを純粋関数として実装する
- [X] T018 [US1] ClaudeBestGame/Services/Game/ScoreCalculator.swift を作成し、contracts/ai-tools.md の ScoreCalculator アルゴリズムを実装する
- [X] T019 [US1] ClaudeBestGame/Services/AI/FallbackCaseProvider.swift を作成し、Resources/FallbackCases/cases.json をデコードしてランダム事件を返す処理を実装する
- [X] T020 [US1] ClaudeBestGame/ViewModels/InterrogationViewModel.swift を作成し、@Observable で事件・容疑者・タイマー・ゲージ・対話ログ・送信状態を管理する（実装初期はフォールバック容疑者を使用：事件JSONのscriptedAnswersから返答）
- [X] T021 [P] [US1] ClaudeBestGame/Views/Interrogation/TimerBar.swift を作成し、残り秒数を視覚化する横バー（残り10秒で赤化）を実装する
- [X] T022 [P] [US1] ClaudeBestGame/Views/Interrogation/ConfessionGauge.swift を作成し、ゲージ値を視覚化（上昇時に赤フラッシュ + Haptics）するViewを実装する
- [X] T023 [P] [US1] ClaudeBestGame/Views/Interrogation/SuspectAvatar.swift を作成し、SFSymbols + 人格タイプ別カラーで容疑者アバターを表示する
- [X] T024 [P] [US1] ClaudeBestGame/Views/Interrogation/DialogueLog.swift を作成し、ScrollView + 自動スクロール + 発話バブル表示を実装する
- [X] T025 [P] [US1] ClaudeBestGame/Views/Interrogation/QuestionInputBar.swift を作成し、TextField + 送信ボタン + キーボード追従を実装する
- [X] T026 [US1] ClaudeBestGame/Views/Interrogation/InterrogationView.swift を作成し、上記コンポーネントを統合した1画面レイアウトを構築する
- [X] T027 [P] [US1] ClaudeBestGame/Views/Result/VictoryView.swift を作成し、勝利演出（自白セリフアニメーション + スコア表示）を実装する
- [X] T028 [P] [US1] ClaudeBestGame/Views/Result/DefeatView.swift を作成し、敗北演出（真の動機公開 + リトライボタン）を実装する
- [X] T029 [US1] ClaudeBestGame/ViewModels/GameRootViewModel.swift を作成し、メニュー→尋問→結果→メニューの画面遷移ロジックを実装する
- [X] T030 [US1] ClaudeBestGame/Views/Menu/MenuView.swift を作成し、「事件開始」「ハイスコア」「黒幕戦（ロック表示）」ボタンを配置する
- [X] T031 [US1] InterrogationViewModel に PlaySession の SwiftData 保存ロジック（開始時新規作成、終了時更新）を追加する

**Checkpoint**: フォールバック事件1件で 開始→質問→返答→ゲージ上昇→勝利or敗北→メニュー戻り を実機で完走できる。

---

## Phase 4: User Story 2 — 矛盾検出と自白ゲージ計算（Priority: P1）

**Goal**: 容疑者の応答に対して矛盾検出が走り、重大度に応じてゲージが動く。
**Independent Test**: モック発言ログ（既知の矛盾入り）で ContradictionDetector が期待通りの severity を返すことをアサーションする。

### US2 テスト（先に書いてRedを確認）

- [X] T032 [P] [US2] ClaudeBestGameTests/ContradictionDetectorTests.swift を作成し、矛盾なしログで severity=none、明確な時刻矛盾で medium 以上、根幹矛盾で large が返ることをテストする（フォールバックモード：キーワードマッチング判定）
- [X] T033 [P] [US2] ClaudeBestGameTests/FallbackContradictionTests.swift を作成し、cases.json の contradictionKeywords を使った単純照合判定をテストする

### US2 実装

- [X] T034 [US2] ClaudeBestGame/Services/AI/ContradictionDetector.swift を作成し、Apple Foundation Models 利用可能時は別 LanguageModelSession + Structured Output（ContradictionResult @Generable）で判定、不可時はキーワード照合フォールバックする実装を行う
- [X] T035 [US2] InterrogationViewModel に ContradictionDetector を統合し、容疑者応答完了直後に矛盾判定 → ConfessionGaugeEngine でゲージ更新 → InterrogationTurn に severity と gaugeDelta を保存する処理を追加する
- [X] T036 [US2] ConfessionGauge.swift にゲージ上昇アニメーション（withAnimation easeOut 0.4s）+ severity=large 時の赤フラッシュエフェクトを実装する
- [X] T037 [US2] InterrogationViewModel に「ゲージ100%到達」検知ロジックを追加し、自白演出トリガーで VictoryView に遷移する処理を実装する

**Checkpoint**: フォールバックモードで矛盾を含む質問→ゲージが目視で上がる→100%で勝利できる。

---

## Phase 5: User Story 3 — 事件と容疑者のAI生成（Priority: P1）

**Goal**: Apple Foundation Models が事件と容疑者をリアルタイム生成し、毎回違うプレイ体験を生む。
**Independent Test**: 10連続で CaseGeneratorService.generate() を呼び出し、caseType・suspectName・trueMotive がすべて重複しないことを確認できる。

### US3 テスト（先に書いてRedを確認）

- [ ] T038 [P] [US3] ClaudeBestGameTests/CaseGeneratorTests.swift を作成し、Apple Intelligence対応端末で generate() が CaseGeneration を返し、caseType と persona がスキーマ許容値内であること、3秒以内のタイムアウトでフォールバックに切り替わることをテストする

### US3 実装

- [ ] T039 [US3] ClaudeBestGame/Services/AI/CaseGeneratorService.swift を作成し、CaseGeneration @Generable struct（contracts/case-schema.md 準拠）と LanguageModelSession.respond(generating:) による事件生成を実装する。バリデーション失敗時は最大2回再生成、3回目はフォールバック
- [ ] T040 [US3] ClaudeBestGame/Services/AI/SuspectService.swift を作成し、生成された CaseGeneration をシステムプロンプト（contracts/suspect-protocol.md の雛形 + Resources/Personas/{persona}.txt）に埋め込み、LanguageModelSession を生成してストリーミング応答する処理を実装する
- [ ] T041 [US3] InterrogationViewModel から FallbackCaseProvider 直呼び出しを CaseGeneratorService 経由に切り替え、対応端末では AI 生成・非対応端末では自動フォールバックする分岐を実装する
- [ ] T042 [US3] InterrogationViewModel に容疑者ストリーミング応答の段階的UI更新（テキストが1文字ずつ表示）を実装する
- [ ] T043 [US3] InterrogationViewModel の応答完了検知後に ContradictionDetector を呼び出すフローを再確認し、AI生成と矛盾検出の連携を完成させる

**Checkpoint**: 対応端末で10連続プレイし、毎回違う事件・容疑者が登場することを目視確認する。

---

## Phase 6: User Story 4 — スコア・進捗・10事件キャンペーン（Priority: P2）

**Goal**: スコアとハイスコアが記録され、10事件クリアで黒幕戦が解禁される。
**Independent Test**: ProgressRepository.markCleared() を10回呼び、bossUnlocked が true になることを確認する。

### US4 テスト

- [ ] T044 [P] [US4] ClaudeBestGameTests/ProgressRepositoryTests.swift を作成し、ハイスコア更新・累計カウント・10事件で bossUnlocked=true 化をテストする

### US4 実装

- [ ] T045 [US4] ProgressRepository に markCleared / updateHighScore / unlockBoss メソッドを追加実装する
- [ ] T046 [US4] InterrogationViewModel の終了処理で ProgressRepository.markCleared() を呼び、ハイスコアを更新する
- [ ] T047 [P] [US4] VictoryView に NEW RECORD 演出（ハイスコア更新時のみ表示）を追加する
- [ ] T048 [P] [US4] MenuView に累計クリア数表示と「黒幕戦」ボタンの解禁/ロック切替・解禁時の点滅エフェクトを実装する
- [ ] T049 [P] [US4] MenuView にハイスコア表示画面（事件タイプ別 + 総合）を追加する

**Checkpoint**: 10事件クリアで黒幕戦が解禁・点滅することを実機で確認する。

---

## Phase 7: User Story 5 — 黒幕戦エンディング（Priority: P2）

**Goal**: 180秒の黒幕戦をクリアすると真エンディングが表示される。
**Independent Test**: bossUnlocked=true の状態で「黒幕戦」をタップ → 180秒タイマー起動 → クリア時 EndingView 表示を確認する。

### US5 実装

- [ ] T050 [US5] CaseGeneratorService に generateBossCase() メソッドを追加し、難易度5固定・boss persona で最高難度の事件を生成する
- [ ] T051 [US5] InterrogationViewModel に isBossBattle フラグを追加し、true 時にタイマー180秒・スコア×3倍・黒幕専用イントロ演出を有効化する
- [ ] T052 [P] [US5] ClaudeBestGame/Views/Ending/EndingView.swift を作成し、黒幕の正体公開 + プレイ統計（総質問数・最高自白速度・最も得意な事件タイプ）を表示する
- [ ] T053 [US5] EndingView の表示完了後に ProgressRepository.bonusModeUnlocked=true をセットし、メニューにボーナスモードを表示する
- [ ] T054 [US5] MenuView にボーナスモード（事件無制限・スコアアタック専用）ボタンを追加し、選択時はスコアのみ加算・キャンペーン進捗には影響しない動作にする

**Checkpoint**: 黒幕戦をクリアし真エンディングと統計が表示される。再度メニューに戻るとボーナスモードが選べる。

---

## Phase 8: Polish & Cross-Cutting Concerns

- [ ] T055 [P] ClaudeBestGameUITests/InterrogationFlowUITests.swift を作成し、メニュー→事件開始→質問送信→ゲージ変化→勝利の通しフローを XCUITest で検証する
- [ ] T056 [P] ClaudeBestGameUITests/EndingFlowUITests.swift を作成し、黒幕戦解禁状態からクリア→エンディングまでの通しフローを検証する
- [ ] T057 [P] 全画面のダークモード対応を確認し、カラーセットを Assets.xcassets に整理する
- [ ] T058 [P] Haptics（UIImpactFeedbackGenerator）を 質問送信・矛盾検出・勝利・敗北 の各イベントに追加する
- [ ] T059 [P] アプリアイコンとローンチスクリーンを Assets.xcassets に追加する
- [ ] T060 [P] サウンドエフェクト（AVAudioEngine + システム音 + Haptics組み合わせ）を 自白カウントダウン最後10秒・ゲージ大上昇・勝利時 に追加する
- [ ] T061 quickstart.md のゴールデンパスに従い実機で全フローを手動確認し、不具合を修正する
- [ ] T062 Xcode の Build Settings で Swift 6 strict concurrency 警告をゼロにする

---

## Dependencies & Execution Order

### Phase 依存関係

- Phase 1（Setup） — 依存なし
- Phase 2（Foundational） — Phase 1 完了が必要、Phase 3 以降をブロック
- Phase 3（US1） — Phase 2 完了が必要、MVP 完成
- Phase 4（US2） — Phase 3 完了が必要（容疑者応答後に矛盾検出が走るため）
- Phase 5（US3） — Phase 4 完了が必要（AI 生成へ切り替え、矛盾検出は既に動いている前提）
- Phase 6（US4） — Phase 5 完了後に開始（実プレイデータでスコア検証）
- Phase 7（US5） — Phase 6 の bossUnlocked が必要
- Phase 8（Polish） — Phase 7 完了後

### ストーリー依存関係

- US1（P1） — Foundational 完了後 → MVP デモ可能
- US2（P1） — US1 完了後（矛盾検出を US1 のループに統合）
- US3（P1） — US2 完了後（フォールバックから AI 生成に置換）
- US4（P2） — US3 完了後
- US5（P2） — US4 完了後

### 並行実行の機会

- Phase 2: T006〜T009 は別ファイル・依存なしで並行可
- Phase 3: T013〜T015 のテストは並行で書ける、T021〜T025 の小Viewも並行可
- Phase 4: T032/T033 のテストは並行
- Phase 8: ほとんどのタスクが並行可

---

## Parallel Example: Phase 3（US1）

```
# テストを並行で書く（先にRed確認）：
Task: T013 InterrogationTimerTests.swift
Task: T014 ConfessionGaugeEngineTests.swift
Task: T015 ScoreCalculatorTests.swift

# 小Viewを並行で実装：
Task: T021 TimerBar.swift
Task: T022 ConfessionGauge.swift
Task: T023 SuspectAvatar.swift
Task: T024 DialogueLog.swift
Task: T025 QuestionInputBar.swift
```

---

## Implementation Strategy

### MVP First（US1 + US2）

1. Phase 1: Setup
2. Phase 2: Foundational
3. Phase 3: US1 — フォールバック事件で1ループ完走
4. Phase 4: US2 — 矛盾検出を統合（フォールバックでも体験成立）
5. **STOP & VALIDATE**: フォールバック1分尋問が面白いか手動検証
   - 面白くなければここで設計を見直す（コアメカニクスの肝）

### Incremental Delivery

1. MVP（US1+US2）→ フォールバックで1分尋問が動く
2. US3 → 対応端末で毎回違う事件、リプレイ性向上
3. US4 → スコア・進捗で続ける動機
4. US5 → 黒幕戦エンディングで完結
5. Polish → リリース可能品質

---

## Notes

- `[P]` = 別ファイル・依存なし、並行可
- `[USn]` = ユーザーストーリー追跡
- テストは**実装前**に書いてRedを確認する（Constitution III）
- フォールバックモードは常に動作可能な状態を維持する（FR-010）
- 60秒タイマーの精度が体験の核 → タイマーテストは絶対に手抜きしない
- 矛盾検出が誤検出（false positive）を出すとゲームが破綻する → プロンプト調整は十分に検証する

---

## Phase 9: 選択肢ループへのコンセプト転換（2026-05-08 完了）

### 設計変更
旧「60 秒・自由テキスト入力」→ 新「6 ターン・動的選択肢・ハイブリッドループ」。

### 完了タスク

- [X] T100 新規モデル: `Models/QuestionChoice.swift`（カテゴリ enum 含む）
- [X] T101 新規モデル: `Models/EvidenceItem.swift`（@Model、ループ跨ぎ永続化）
- [X] T102 新規モデル: `Models/InvestigationNotebook.swift`（@Model、捜査メモ）
- [X] T103 拡張モデル: `PlaySession.swift`（turnCount / loopIndex / vigilance）
- [X] T104 拡張モデル: `CaseRecord.swift`（caseKey / stageNumber）
- [X] T105 拡張モデル: `InterrogationTurn.swift`（chosenChoiceCategory / vigilanceAfter）
- [X] T106 拡張モデル: `Progress.swift`（totalLoops / perfectClears / currentStage）
- [X] T107 Schema 更新: `ClaudeBestGameApp.swift` に EvidenceItem / InvestigationNotebook 追加
- [X] T108 純粋ロジック: `Services/Game/VigilanceEngine.swift`（警戒度更新）
- [X] T109 純粋ロジック: `Services/Game/EvidenceTracker.swift`（証拠検出）
- [X] T110 拡張ロジック: `ConfessionGaugeEngine.swift` にカテゴリ × 警戒度を統合
- [X] T111 拡張ロジック: `ScoreCalculator.swift` にループ係数を追加
- [X] T112 拡張ロジック: `ContradictionDetector.swift` にカテゴリ別判定追加
- [X] T113 リソース: `cases.json` に choicePool / evidenceTriggers 追加（10 事件）
- [X] T114 サービス: `FallbackCaseProvider.swift` を新スキーマに対応
- [X] T115 サービス: `FallbackGuardian.swift` をカテゴリ別応答に拡張
- [X] T116 サービス: `Services/AI/ChoiceGeneratorService.swift` 新規（フォールバック実装）
- [X] T117 サービス: `ProgressRepository.swift` に notebook / evidence ヘルパ追加
- [X] T118 ViewModel: `InterrogationViewModel.swift` ターン制 + ループに全面改修
- [X] T119 ViewModel: `NotebookViewModel.swift` 新規
- [X] T120 ViewModel: `GameRootViewModel.swift` に retrySameCase 追加
- [X] T121 View 削除: `Views/Interrogation/QuestionInputBar.swift`
- [X] T122 View 削除: `Views/Interrogation/TimerBar.swift`
- [X] T123 View 新規: `Views/Interrogation/TurnIndicator.swift`
- [X] T124 View 新規: `Views/Interrogation/VigilanceMeter.swift`
- [X] T125 View 新規: `Views/Interrogation/QuestionChoicesView.swift`
- [X] T126 View 新規: `Views/Notebook/NotebookView.swift`
- [X] T127 View 新規: `Views/Notebook/EvidenceCard.swift`
- [X] T128 View 改修: `Views/Interrogation/InterrogationView.swift`
- [X] T129 View 改修: `Views/Interrogation/DialogueLog.swift`（カテゴリ表示）
- [X] T130 View 改修: `Views/Result/VictoryView.swift`（パーフェクト表示）
- [X] T131 View 改修: `Views/Result/DefeatView.swift`（再挑戦ボタン）
- [X] T132 View 改修: `Views/Menu/MenuView.swift`（ステージ番号・ループ統計）
- [X] T133 View 改修: `Views/Root/RootView.swift`（Schema 追加）
- [X] T134 テスト更新: `ConfessionGaugeEngineTests.swift`（新シグネチャ・新値）
- [X] T135 テスト新規: `VigilanceEngineTests.swift`（7 case）
- [X] T136 テスト新規: `EvidenceTrackerTests.swift`（5 case）
- [X] T137 テスト新規: `ChoiceGeneratorTests.swift`（5 case）
- [X] T138 ビルド検証: BUILD SUCCEEDED on iPhone 17 Pro Simulator
- [X] T139 テスト検証: 43 テスト全成功

**結果**: 「結構難しい・選択肢・いい具合でループ」のユーザー要望を満たす実装が完成。
オフライン・フォールバックモードでフルプレイ可能。次は Phase 5 (Apple Foundation Models 統合)。
