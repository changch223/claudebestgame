# Quickstart: 白い嘘 — One Minute Interrogation

**Date**: 2026-05-07

---

## 必要環境

| 項目 | 要件 |
|------|------|
| Xcode | 16.3 以上 |
| Swift | 6.0 以上 |
| 実機 | iPhone 15 Pro/Pro Max または iPhone 16 シリーズ（Apple Intelligence対応） |
| iOS | 18.1 以上、Apple Intelligence 有効化済み |
| macOS | 15.2 以上（ホストMac） |

> シミュレータでも起動可能。Apple Foundation Models が使えない場合は自動的にフォールバックモードが起動する。

---

## セットアップ

```bash
git clone <repo-url>
cd ClaudeBestGame
open ClaudeBestGame.xcodeproj
```

Swift Package 依存なし。Apple 純正フレームワーク（FoundationModels / SwiftUI / SwiftData）のみ使用。

---

## 初回ビルド

1. Xcode で `ClaudeBestGame` スキームを選択
2. 実機を接続してターゲット選択
3. `Cmd + R` でビルド＆実行

### Capabilities（初回のみ）

`Signing & Capabilities` で特に追加機能は不要（バックグラウンドタスクなし、通知なし）。

---

## ゴールデンパス（手動動作確認）

1. アプリ起動 → メニュー画面（「事件開始」「ハイスコア」「黒幕戦（ロック）」）
2. 「事件開始」をタップ → 事件生成中ローディング（最大5秒）
3. 事件説明と容疑者プロファイルが表示 → 「尋問開始」をタップ
4. 60秒タイマー起動、容疑者アバター表示
5. 質問を入力（例：「事件当夜どこにいたか？」）→ 送信
6. 容疑者が1秒以内にストリーミング応答開始
7. プレイヤーが矛盾を突く質問をする → ゲージが赤くフラッシュ + 上昇
8. ゲージ100%到達 → 自白演出 + スコア表示
9. メニューに戻る → 累計クリア数+1
10. 10事件クリア → 「黒幕戦」が解禁・点滅
11. 黒幕戦をクリア → 真エンディング表示

---

## テスト実行

```bash
# ユニットテスト
xcodebuild test \
  -scheme ClaudeBestGame \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# UIテスト（実機推奨）
xcodebuild test \
  -scheme ClaudeBestGame \
  -destination 'id=<device-udid>' \
  -only-testing:ClaudeBestGameUITests
```

主要ユニットテスト：
- `ContradictionDetectorTests` — モックされた発言ログで重大度判定
- `ConfessionGaugeEngineTests` — ゲージ計算ロジック
- `ScoreCalculatorTests` — スコア算出
- `InterrogationTimerTests` — タイマー精度

---

## フォールバックモード確認

シミュレータ起動時、Apple Intelligence 利用不可なので自動的にフォールバック。
固定事件10件 + 容疑者の決定論的応答でゲームループが動作する。

---

## デバッグ Tips

- `DEBUG` ビルドでは矛盾判定理由がコンソールに print される
- SwiftData の中身は Xcode の Database Inspector で確認
- 黒幕戦を強制解禁したい場合：
  ```swift
  // ClaudeBestGameApp.swift の onAppear で
  Progress.shared.bossUnlocked = true
  ```
