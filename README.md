# collog: Collaboration Log

AIとのバイブコーディングを想定した、プロジェクトの進行管理ツール。

## Features

- AIエージェント（Claude Codeなど）がCLIから記録・参照する前提の設計（出力はMarkdown）
- 作業の記録・変更履歴・将来の要件を、プロジェクトごとに一元管理
- プロジェクト間で依頼・連絡をやり取りできる
- サーバー不要。データは手元の1ファイルに保存

## Requirements

- Python 3（標準ライブラリのみ使用。追加インストール不要）

## Installation

```bash
git clone https://github.com/s-yamada/collog.git
cd collog
./install.sh
```

`collog`の実体を`~/.local/share/collog/collog`にコピーし、起動用シンボリックリンク`~/.local/bin/collog`を作成する（`~/.local/bin`にPATHが通っていることが前提）。コードを更新したら再実行する。

## Usage

```bash
cd ~/src/myapp
collog init myapp                  # カレントディレクトリをプロジェクト名「myapp」で登録

echo 'CSVエクスポートに文字コード指定を追加する' | collog add todo
collog todo                        # 未完了のTODOを表示
```

```
$ collog todo
- [ ] CSVエクスポートに文字コード指定を追加する
```

登録したディレクトリで実行すると、`project`の指定を省略できる。

- コマンド・オプションの一覧と詳しい説明: [docs/usage.md](docs/usage.md)
- 各コマンドのヘルプ: `collog help <command>`

## License

[LICENSE](LICENSE) を参照
