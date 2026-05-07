# Research: 白い嘘 — One Minute Interrogation

**Date**: 2026-05-07
**Feature**: specs/001-ios-best-game

---

## 1. Apple Foundation Models の活用方針

### Decision
- 事件＋容疑者プロファイル生成 → `LanguageModelSession.respond(generating: CaseGeneration.self)`（Structured Output）
- 容疑者対話 → `LanguageModelSession`（人格プロンプト埋込）でストリーミング応答
- 矛盾検出 → 別の `LanguageModelSession`（軽量プロンプト + Structured Output）

### Pattern

```swift
// 1) 事件生成（Structured Output）
@Generable
struct CaseGeneration {
    @Guide("事件タイプ。murder/theft/fraud/kidnap/betrayal のいずれか") var caseType: String
    @Guide("被害者名（日本語）") var victimName: String
    @Guide("凶器または手段（日本語）") var weapon: String
    @Guide("真の動機（日本語1文）") var trueMotive: String
    @Guide("容疑者名（日本語）") var suspectName: String
    @Guide("容疑者年齢") var suspectAge: Int
    @Guide("容疑者職業（日本語）") var suspectJob: String
    @Guide("人格タイプ。stoic/anxious/aggressive/pitiful/intellectual のいずれか") var persona: String
    @Guide("容疑者が主張するアリバイ（日本語2〜3文、嘘）") var alibiStory: String
    @Guide("アリバイの中の弱点（プレイヤーが突けば矛盾になる箇所、日本語1文）") var weakPoint: String
    @Guide("難易度1〜5") var difficulty: Int
}

// 2) 容疑者対話セッション
let suspect = LanguageModelSession(
    instructions: """
    あなたは\(case.suspectName)、\(case.persona)タイプの容疑者です。
    真実: \(case.trueMotive)
    あなたが主張するアリバイ: \(case.alibiStory)
    あなたは絶対に真実を認めず、アリバイを維持してください。
    人格に応じた口調で、簡潔に（30文字以内）答えてください。
    """
)

// 3) 矛盾検出セッション
@Generable
struct ContradictionResult {
    @Guide("矛盾の重大度。none/small/medium/large のいずれか") var severity: String
    @Guide("矛盾の理由（日本語1文、UIには表示しない）") var reason: String
}

let detector = LanguageModelSession(instructions: """
あなたは尋問アシスタントです。
容疑者の最新発言が、それまでの発言ログまたはアリバイと矛盾するか判定してください。
""")
```

### Rationale
- 1セッション内で人格と真実が一貫することが核心
- Structured Output により事件生成が型安全
- 別セッションで矛盾検出を行うことで容疑者AIに矛盾検出能力が「漏れない」（容疑者は自分の矛盾に気づいていない演技を維持する）

### Alternatives Considered
- 単一セッションで対話と矛盾検出を兼用 → 容疑者が自分のセリフを自己評価してしまい演技が崩れる → 棄却
- ローカルなSwift辞書での矛盾検出 → 自然言語の矛盾は単純照合では検出不可 → 棄却

---

## 2. 高精度タイマー実装

### Decision
`Timer.publish(every: 0.05)` ベースのリアクティブタイマーを使い、
内部状態は `Date` 差分で計算する（iOS の Timer は ±10ms 程度の精度）。

```swift
@Observable
final class InterrogationTimer {
    private(set) var remainingSeconds: Double = 60.0
    private var startedAt: Date?
    private var totalSeconds: Double = 60.0
    private var task: Task<Void, Never>?

    func start(seconds: Double) {
        totalSeconds = seconds
        startedAt = Date()
        task = Task { @MainActor in
            while let start = startedAt {
                remainingSeconds = max(0, totalSeconds - Date().timeIntervalSince(start))
                if remainingSeconds <= 0 { break }
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }
    func pause() { task?.cancel(); /* 経過分を totalSeconds から差し引いて再開時に使う */ }
    func stop() { task?.cancel(); startedAt = nil }
}
```

### Rationale
- 60fps 描画とは独立して 50ms 解像度で残り時間を更新
- バックグラウンド復帰時に `pause()` → 再開可能
- `Task.sleep` ベースなので Swift Concurrency と統合できる

---

## 3. 矛盾検出のプロンプト戦略

### Decision
矛盾検出セッションには「容疑者の真実」を渡さない。
渡すのは「アリバイ」と「これまでの容疑者発言ログ」のみ。
これにより、検出器は「アリバイと過去発言間の論理矛盾」だけを判定する。

### 入力フォーマット

```
アリバイ: 「事件当夜、私は妻と自宅にいた」
過去発言:
  Q: いつ帰宅したか? A: 午後10時頃
  Q: 妻は何時に帰った? A: 午後9時
最新発言: A: 私は午後8時から自宅にいて、妻と一緒に夕食を食べた
判定対象: 最新発言が過去発言と矛盾するか
```

### Rationale
- 真実を渡すと検出器が「真実との不一致」を矛盾と誤認する（プレイヤーが真実を当てる前に矛盾扱いされる）
- アリバイ + 過去発言だけならプレイヤーの推論と同じ情報量

---

## 4. 自白ゲージのアニメーション

### Decision
`withAnimation(.easeOut(duration: 0.4))` で自白ゲージのスケールを更新。
重大度が `large` の場合は赤いフラッシュ（`.flash` カスタムModifier）と Haptics（`.heavy`）。

### Rationale
- 矛盾を突いた瞬間のフィードバックが体験の核
- 視覚 + 触覚 + 聴覚（システム効果音）で多重に強化

---

## 5. フォールバックモード（Apple Intelligence非対応端末）

### Decision
バンドルに10件の固定事件JSONを格納。フォールバックモードでは：
- 事件はランダム選択
- 容疑者対話は事件JSONに含まれる「想定質問→回答」マップ + デフォルト回答
- 矛盾検出は事件JSONに含まれる「矛盾トリガーキーワード」リストとの単純照合

### Rationale
- 非対応端末でも純粋なゲームメカニクスは体験できる
- iOS 17 でもアプリが動く保証
- 開発初期はフォールバックモードでメカニクス検証が可能

---

## 6. SwiftData スキーマ設計

### Decision
`PlaySession` を中心に、`CaseRecord` `SuspectRecord` `InterrogationTurn` を関連付ける。
`Progress` はシングルトンレコード（id固定値）として扱う。

```
Progress (1) ─── PlaySession (N)
                       │
                       ├── CaseRecord (1)
                       ├── SuspectRecord (1)
                       └── InterrogationTurn (N)
```

### Rationale
- 過去のプレイをすべてアーカイブとして残せる（v2でリプレイ機能拡張可）
- ハイスコア計算は `PlaySession` の集計で実現可

---

## 7. Swift 6 Concurrency

### Decision
- `LanguageModelSession` の呼び出しは `@MainActor` 外の `Task` で行う
- UI更新は `MainActor.run` または `@MainActor` プロパティ更新で同期
- `InterrogationTimer` は `@MainActor` `@Observable` クラスとして UI から直接バインド可能

### Rationale
Swift 6 strict concurrency 通過必須。LanguageModelSession は Sendable なので追加の actor 包装不要。
