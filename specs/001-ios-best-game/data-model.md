# Data Model: 白い嘘 — One Minute Interrogation

**Date**: 2026-05-07

---

## エンティティ関係

```
Progress (1, シングルトン)
   │
   └── PlaySession (N) ── CaseRecord (1) ── SuspectRecord (1)
            │                                       │
            └── InterrogationTurn (N) ──────────────┘
```

---

## CaseRecord

AIが生成した事件のスナップショット（その回限り保存）。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `id` | UUID | 主キー |
| `caseType` | String | "murder" / "theft" / "fraud" / "kidnap" / "betrayal" / "spy" / "forgery" / "smuggle" / "scandal" / "boss" |
| `victimName` | String | 被害者名（日本語） |
| `weapon` | String | 凶器または手段 |
| `trueMotive` | String | 容疑者の真の動機（プレイヤーには敗北時のみ公開） |
| `difficulty` | Int | 1〜5（黒幕戦は5固定） |
| `isFallback` | Bool | フォールバック事件かどうか |
| `generatedAt` | Date | 生成日時 |

---

## SuspectRecord

事件ごとに生成される容疑者プロファイル。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `id` | UUID | 主キー |
| `caseId` | UUID | 紐づく事件ID |
| `name` | String | 容疑者名（日本語） |
| `age` | Int | 年齢 |
| `job` | String | 職業 |
| `personaType` | String | "stoic" / "anxious" / "aggressive" / "pitiful" / "intellectual" |
| `alibiStory` | String | 主張するアリバイ（嘘） |
| `weakPoint` | String | アリバイの弱点（プレイヤーが突けば矛盾になる箇所、UI非表示） |

---

## InterrogationTurn

1ターンの発話レコード。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `id` | UUID | 主キー |
| `sessionId` | UUID | 紐づく PlaySession |
| `index` | Int | ターン番号（0始まり） |
| `speaker` | String | "player" / "suspect" |
| `text` | String | 発話テキスト |
| `contradictionSeverity` | String? | suspectターンのみ："none" / "small" / "medium" / "large" |
| `gaugeDelta` | Double | このターンでの自白ゲージ変化量（0.0〜0.30） |
| `gaugeAfter` | Double | このターン後のゲージ値（0.0〜1.0） |
| `timestamp` | Date | 発話日時 |
| `latencyMs` | Int? | suspectターンのみ：返答開始までのms |

---

## PlaySession

1事件の1プレイ全体。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `id` | UUID | 主キー |
| `caseId` | UUID | 事件ID |
| `suspectId` | UUID | 容疑者ID |
| `startedAt` | Date | 尋問開始時刻 |
| `endedAt` | Date? | 終了時刻 |
| `result` | String | "victory" / "defeat" / "abandoned" |
| `finalGauge` | Double | 終了時の自白ゲージ |
| `remainingSeconds` | Double | 終了時の残り秒数 |
| `score` | Int | 算出スコア |
| `isBossBattle` | Bool | 黒幕戦フラグ |

**バリデーション**: `finalGauge` は 0.0〜1.0、`remainingSeconds` は 0.0〜180.0。

---

## Progress

キャンペーン進捗（id 固定値の単一レコード）。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `id` | UUID | 固定値（プロジェクト定数） |
| `totalCleared` | Int | 累計クリア数 |
| `totalPlayed` | Int | 累計プレイ数（敗北含む） |
| `bossUnlocked` | Bool | 黒幕戦解禁フラグ |
| `bossCleared` | Bool | 黒幕戦クリアフラグ |
| `bonusModeUnlocked` | Bool | エンディング後ボーナスモード解禁 |
| `highScoreOverall` | Int | 総合ハイスコア |
| `highScoreByType` | Data | 事件タイプ別ハイスコア（JSONエンコードされた `[String: Int]`） |
| `lastPlayedAt` | Date? | 最終プレイ日時 |

---

## 状態遷移

```
PlaySession.result:
  生成中（DBに未保存）
    → in_progress（startedAt セット時）
       → victory（ゲージ100%到達）
       → defeat（タイマー切れ）
       → abandoned（プレイヤーが中断）
```

```
Progress.bossUnlocked:
  false → true（totalCleared が10に達した時）

Progress.bossCleared:
  false → true（黒幕戦に勝利した時）
   → bonusModeUnlocked も同時にtrue
```
