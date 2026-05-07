# Contract: 矛盾検出 + ゲージ計算プロトコル

**Date**: 2026-05-07

容疑者の応答を評価する `ContradictionDetector` の入出力仕様。

---

## ContradictionDetector

```
Inputs:
  alibiStory: String       — 容疑者が主張するアリバイ（事件生成時の値）
  pastTurns: [Turn]        — それまでの容疑者発言のみ
    Turn:
      questionText: String — そのときのプレイヤー質問
      answerText: String   — そのときの容疑者回答
  latestAnswer: String     — 最新の容疑者回答

Output (Structured @Generable):
  severity: String         — "none" | "small" | "medium" | "large"
  reason: String           — 判定理由（日本語1文、UIには表示しないがログ保存）
```

---

## 重大度の定義

| severity | 意味 | ゲージ上昇 |
|----------|------|-----------|
| `none` | 矛盾なし。アリバイ・過去発言と整合 | +0% |
| `small` | 些細な不一致（言葉の揺れ程度） | +5% |
| `medium` | 明確な事実の食い違い（時刻・人物・場所など） | +15% |
| `large` | 致命的な矛盾（アリバイの根幹を崩すレベル） | +30% |

---

## 判定システムプロンプト

```
あなたは尋問アシスタントです。
容疑者の最新発言が、アリバイまたは過去の発言と矛盾するかを判定してください。

【アリバイ】
{alibiStory}

【容疑者の過去発言】
{pastTurns を列挙}

【最新発言】
{latestAnswer}

判定基準:
- none: 矛盾は見られない、または直接的に検証できない
- small: 言葉遣いや細部に揺れがあるが致命的ではない
- medium: 時刻・人物・場所など事実関係の明確な食い違い
- large: アリバイの根幹を崩す、または複数の重大な矛盾

中立的に判定し、決して容疑者を擁護しないこと。
ただし矛盾が無いものを矛盾と誤判定しないこと（false positive回避）。
```

---

## ConfessionGaugeEngine

矛盾検出結果からゲージを更新する純粋ロジック（Foundation Models 不使用）。

```
Inputs:
  currentGauge: Double      — 0.0〜1.0
  severity: String          — "none" | "small" | "medium" | "large"
  difficulty: Int           — 事件難易度 1〜5

Output:
  newGauge: Double          — 0.0〜1.0
  delta: Double             — 上昇量（0.0 / 0.05 / 0.15 / 0.30）

Algorithm:
  base = severity に応じた基本上昇量（0.0 / 0.05 / 0.15 / 0.30）
  // 難易度が高いほど矛盾を突いてもゲージが上がりにくい
  multiplier = 1.0 - (difficulty - 1) * 0.10  // d1=1.00, d5=0.60
  delta = base * multiplier
  newGauge = min(1.0, currentGauge + delta)
```

---

## ScoreCalculator

```
Inputs:
  remainingSeconds: Double  — タイマー残り（0.0〜180.0）
  difficulty: Int           — 事件難易度 1〜5
  isVictory: Bool           — 勝利フラグ
  isBossBattle: Bool        — 黒幕戦フラグ

Output:
  score: Int

Algorithm:
  if !isVictory: return 0
  base = round(remainingSeconds * 100)
  difficultyBonus = (difficulty - 1) * 1000
  bossMultiplier = isBossBattle ? 3 : 1
  score = (base + difficultyBonus) * bossMultiplier
```

---

## エラーハンドリング

- 矛盾検出が3秒以内に応答しない場合 → `severity = "none"` を返す（ゲージ上昇なし、プレイヤー有利）
- 検出セッション失敗時のフォールバック：
  - フォールバックモード時は事件JSONの `contradictionKeywords` リストとプレイヤー質問の単純文字列マッチで判定
  - 完全失敗時は `severity = "none"`
