# Selfware Protocol Demo

言語: [English](README.md) | [中文](README.zh-CN.md) | [Italiano](README.it.md) | **日本語** | [Français](README.fr.md) | [Deutsch](README.de.md)

このリポジトリは **Selfware Protocol** のデモ版で、中国語版と英語版のプロトコル草案テンプレートを提供します。

## 現在の内容

- `template.self/selfware-zh.md`: プロトコル草案（中国語版）
- `template.self/selfware.md`: プロトコル草案（英語版）

現在のプロトコル版: `v0.1.0 (Draft)`

## Selfware とは

Selfware は、Agent 時代の統一ファイルプロトコルを定義することを目指します。

- A file is an app. Everything is a file.
- データ・ロジック・ビューを、1つの配布単位（単一ファイルまたは `.self` コンテナ）に任意で統合できます。
- 人間↔Agent、Agent↔Agent の協調を分散型で実現します。

## 主要原則（概要）

- **Canonical Data Authority**: 各インスタンスは真理源を明確に定義する必要があります。
- **Write Scope Boundary**: 書き込みは `content/`（または宣言された同等の canonical 範囲）に限定すべきです。
- **No Silent Apply**: 更新は、説明とユーザー確認なしに適用してはいけません。
- **View as Function**: `View = f(Data, Intent, Rules)`。ビューは真理源ではありません。

## 使い方

素早く体験するには、次のデモを試してください: `https://github.com/awesome-selfware/openoffice.self`

1. 中国語版草案を読む: `template.self/selfware-zh.md`
2. 英語版草案を読む: `template.self/selfware.md`
3. これらのテンプレートを元に独自のインスタンス用プロトコルを作成し、必要に応じて runtime モジュール（API、パッケージング、協調、Memory、Discovery など）を拡張します。

## リポジトリに関する補足

- 現在、このリポジトリにはプロトコルのテンプレート文書のみが含まれます。
- 完全な runtime/server 実装は含まれていません。

## ライセンス

プロトコル本文では、任意の MIT ライセンスが宣言されています（詳細はプロトコルファイルを参照）。

