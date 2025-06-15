# Claude Team (cteam) - Multi-Agent Development Environment

Claude Team は Claude Code を使用した汎用的なマルチエージェント開発支援ツールです。Manager Agent と Developer Agent が協調してプロジェクト開発を支援します。

## 概要

cteam は tmux を使用した 3 ペイン構成で動作し、以下の構成になります：

- **User Pane (左)**: ユーザーのワークスペース
- **Manager Agent (右上)**: タスク管理・指示出し・進捗管理を担当
- **Developer Agent (右下)**: 実装・コーディング・テストを担当

## 主な特徴

- 🚀 **汎用的**: どのプロジェクトでも使用可能
- 🔧 **プロジェクト固有設定**: `.cteam/` ディレクトリで設定を管理
- 🤖 **マルチエージェント**: Manager と Developer が役割分担して作業
- 📋 **自動化**: タスクの委譲・進捗管理・完了報告を自動化
- ⚡ **tmux 統合**: 効率的な画面分割とプロセス管理

## インストール

### 前提条件

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) がインストールされていること
- tmux がインストールされていること

### インストール手順

1. このリポジトリをクローン:
```bash
git clone <repository-url> ~/.cteam
```

2. PATH にバイナリを追加:
```bash
echo 'export PATH="$HOME/.cteam/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

または、シンボリックリンクを作成:
```bash
sudo ln -s ~/.cteam/bin/cteam /usr/local/bin/cteam
```

## 使用方法

### 1. プロジェクト初期化

プロジェクトルートディレクトリで初期化:

```bash
cd /path/to/your/project
cteam init
```

これにより `.cteam/` ディレクトリが作成され、設定ファイルとエージェントコンテキストがセットアップされます。

### 2. 開発セッション開始

```bash
cteam start
```

tmux セッションが起動し、3 つのペインが表示されます。

### 3. タスク指示

```bash
cteam order "ユーザー登録機能を実装してください"
```

Manager Agent がタスクを受け取り、分析して Developer Agent に委譲します。

### 4. セッション終了

```bash
cteam exit
```

## プロジェクト構造

初期化後、プロジェクトに以下の構造が作成されます：

```
your-project/
├── .cteam/
│   ├── config.yaml                    # プロジェクト設定
│   └── contexts/
│       ├── manager_context.md         # Manager Agent のコンテキスト
│       └── developer_context.md       # Developer Agent のコンテキスト
└── ... (your project files)
```

## 設定のカスタマイズ

### エージェントコンテキストの編集

各エージェントの動作をカスタマイズできます：

```bash
# Manager Agent のコンテキストを編集
vim .cteam/contexts/manager_context.md

# Developer Agent のコンテキストを編集
vim .cteam/contexts/developer_context.md
```

### プロジェクト設定

`.cteam/config.yaml` でプロジェクト設定を変更できます：

```yaml
project:
  name: my-awesome-project
  root: /path/to/project
agents:
  manager:
    context: contexts/manager_context.md
  developer:
    context: contexts/developer_context.md
session:
  name: cteam_my_awesome_project
```

## ワークフロー

1. **指示受領**: `cteam order` でユーザーの指示を Manager Agent が受領
2. **タスク分析**: Manager Agent がタスクを分析・分解
3. **タスク委譲**: Developer Agent に具体的な実装タスクを委譲
4. **実装**: Developer Agent がブランチ作成・実装・テスト
5. **完了報告**: Developer Agent が Manager Agent に完了を報告
6. **最終確認**: Manager Agent がユーザーに完了を報告

## コマンドリファレンス

### `cteam init`
現在のディレクトリを cteam プロジェクトとして初期化します。

### `cteam start`
tmux セッションを開始し、Manager Agent と Developer Agent を起動します。

### `cteam order "<指示>"`
Manager Agent に開発指示を送信します。

### `cteam exit`
tmux セッションを終了し、すべてのエージェントを停止します。

### `cteam help`
使用方法を表示します。

## トラブルシューティング

### Claude Code CLI が見つからない

```bash
# Claude Code CLI をインストール
curl -fsSL https://claude.ai/install | bash
```

### tmux セッションが残っている

```bash
# 手動でセッションを削除
tmux kill-session -t cteam_<project_name>
```

### エージェントが応答しない

1. tmux セッション内で Ctrl+C を押してエージェントを再起動
2. `cteam exit` でセッション終了後、`cteam start` で再開

## 開発者向け情報

### ディレクトリ構造

```
cteam/
├── bin/
│   └── cteam                          # メインコマンド
├── src/
│   ├── tmux_manager.sh               # tmux セッション管理
│   ├── agent_launcher.sh             # エージェント起動
│   ├── order_manager.sh              # 指示送信管理
│   ├── delegate_task.sh              # タスク委譲ヘルパー
│   ├── report_completion.sh          # 完了報告ヘルパー
│   └── complete.sh                   # 簡易完了通知
├── config/
│   └── contexts/                     # デフォルトコンテキスト
│       ├── manager_context.md
│       └── developer_context.md
├── README.md
└── DESIGN.md                         # 設計ドキュメント
```

### 拡張方法

1. **新しいエージェントタイプの追加**: `config/contexts/` に新しいコンテキストファイルを追加
2. **カスタムヘルパースクリプト**: `src/` ディレクトリにスクリプトを追加
3. **設定オプションの追加**: `config.yaml` のスキーマを拡張

## ライセンス

MIT License

## 貢献

Issue や Pull Request をお待ちしています。開発に参加される場合は、まず Issue を作成してください。

## 更新履歴

- v1.0.0: 初回リリース - 基本的なマルチエージェント機能