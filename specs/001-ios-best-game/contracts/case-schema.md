# Contract: 事件生成 Structured Output スキーマ

**Date**: 2026-05-07

`CaseGeneratorService.generate()` が返す `@Generable struct CaseGeneration` の仕様。

---

## CaseGeneration

```
caseType: String
  許容値: "murder" | "theft" | "fraud" | "kidnap" | "betrayal"
        | "spy" | "forgery" | "smuggle" | "scandal" | "boss"

victimName: String
  日本語の人名（2〜10文字）

weapon: String
  日本語、凶器または手段の短い説明（10〜30文字）
  例: "毒入りワイン" / "コンピュータの不正侵入" / "偽造書類"

trueMotive: String
  日本語、容疑者の真の動機（30〜100文字）
  例: "被害者が会社の不正を告発しようとしたため、口封じのため毒殺した"

suspectName: String
  日本語の人名

suspectAge: Int
  許容範囲: 18〜80

suspectJob: String
  日本語の職業名（5〜20文字）

persona: String
  許容値: "stoic" | "anxious" | "aggressive" | "pitiful" | "intellectual"

alibiStory: String
  日本語、容疑者が主張するアリバイ（80〜200文字）
  必ず嘘である必要がある（trueMotiveと矛盾していなければならない）

weakPoint: String
  日本語、アリバイの弱点（30〜100文字）
  プレイヤーが質問で突けば矛盾になる箇所
  UIには表示しない（敗北時の解説には使う）

difficulty: Int
  許容範囲: 1〜5
  通常事件は 1〜4、黒幕戦は 5
```

---

## バリデーションルール

- `caseType` が許容値外の場合 → "theft" にフォールバック
- `persona` が許容値外の場合 → "stoic" にフォールバック
- `suspectAge` が範囲外の場合 → 35 にクランプ
- `difficulty` が範囲外の場合 → 3 にクランプ
- `alibiStory` が `trueMotive` と整合してしまっている場合（嘘になっていない）→ AI に再生成リクエスト（最大2回）

---

## エラー時のフォールバック

3秒以内に AI が応答しない or バリデーション失敗が3回続く場合、
`FallbackCaseProvider` から固定事件をランダム選択して返す。
