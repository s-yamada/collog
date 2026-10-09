# collog: Collaboration Log

プロジェクトの進行管理ツール。プロジェクトごとに作業の記録・変更履歴・要件・他プロジェクトとの連絡をSQLiteで一元管理する。
AIとのバイブコーディング（Claude Codeなど、AIエージェントからのCLI利用）での使用を想定しています。

## できること

- 作業の記録（summary）: セッションごとの議事録
- 変更履歴（change）: ユーザーに影響する変更の記録
- 将来の要件（todo）
- 他プロジェクトへの依頼（request）・連絡（message）

## 動作環境

- Python 3（標準ライブラリのみ使用。追加インストール不要）

## インストール

```bash
git clone https://github.com/s-yamada/collog.git
cd collog
./install.sh
```

`collog`の実体を`~/.local/share/collog/collog`にコピーし、起動用シンボリックリンク`~/.local/bin/collog`を作成する（`~/.local/bin`にPATHが通っていることが前提）。コードを更新したら再実行する。

## 使い方

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

## 利用条件

[LICENSE](LICENSE) を参照
