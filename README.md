# collog: Collaboration Log

プロジェクトの進行管理ツール。
プロジェクトごとに TODO/CHANGES/SUMMARY を一元管理。
AIとのバイブコーディングでの使用を想定しています。

## インストール

```bash
main/install.sh
```

`collog`の実体を`~/.local/share/collog/collog`にコピーし、起動用シンボリックリンク`~/.local/bin/collog`を作成する（`~/.local/bin`にPATHが通っていることが前提）。コードを更新したら再実行する。

## 使い方

```
collog init <project> [path]              # プロジェクトを登録（既存ならpathを更新）
collog projects                           # 登録済みプロジェクトの一覧
collog rename [old_name] <new_name>       # プロジェクト名を変更（entries/todosの参照も追従）

collog add summary [project] [--at 日時]   # 標準入力の内容をSUMMARYとして記録
collog add change [project] [--at 日時]    # 標準入力の内容をCHANGESとして記録
collog add todo [project] [--at 日時]      # 標準入力の内容をTODOとして追加
collog add request <project> [--from <source_project>] [--at 日時]
                                           # 他プロジェクトからの依頼としてTODOに追加
collog finish todo [project] <id> [--at 日時]  # 指定TODOを完了にする

collog summary [project] [-n] [--date YYYY-MM-DD] [--from 日時] [--to 日時] [--sort created_at|id|project] [--asc|--desc] [-r] [--id]
                                           # SUMMARYを表示（省略時は全プロジェクト横断、指定時はそのプロジェクトの履歴）
collog change [project] [-n] [--sort created_at|id] [--asc|--desc] [-r] [--id]
                                           # CHANGESの一覧をMarkdown形式で表示（既定: 全件・古い順）
collog todo [project] [--all] [--id]      # TODO一覧（既定は未完了のみ、requestも含む）
collog request [project] [--all] [--id]   # 他プロジェクトからの依頼を表示（省略時は全プロジェクト横断）

collog search summary|change|todo|all <keyword> [project] [--global|-g]
                                           # 本文にkeywordを含む記録を検索（既定はカレントディレクトリのプロジェクトのみ）
collog show summary|change [project] <id> # SUMMARY/CHANGESを1件だけ表示

collog update summary|change|todo [project] <id> [--at 日時]  # 本文を標準入力の内容で置き換え
collog delete summary|change|todo [project] <id>              # 削除

collog export [project]                   # データをJSON形式で書き出す（省略時は全プロジェクト）
collog import [--safety]                  # 標準入力のJSON（exportの出力形式）を取り込む

collog help [command...]                  # サブコマンドのヘルプを表示（'<cmd> -h'と同じ）
```

### projectのカレントディレクトリ自動推測

- `[project]`省略時、カレントディレクトリを登録済み`projects.path`と照合して推測（サブディレクトリからでも可）
- 複数該当する場合は最も深いパスを優先
- 該当なしかつ`project`も省略の場合はエラー（`collog init`を促すメッセージ）
- 対象外: `summary`/`request`の`project`省略（下記参照。全プロジェクト横断の意味になる）、`add request`の`project`（依頼先）

### summary・change の表示

- `summary [project]`は、`project`省略時は全プロジェクトの最新1件ずつを横断表示、指定時はそのプロジェクトのsummary履歴を表示する（2つのモードで意味を持つオプションが違う）
- `change [project]`は横断表示を持たず、常にそのプロジェクト（省略時はCWD自動推測）の履歴を表示する
- いずれもMarkdown形式で出力
- 横断表示（`summary`省略時）は端末（TTY）出力時のみ本文をプレビュー表示。履歴表示（`summary <project>`/`change`）は常に全文
- 出力が端末の行数を超える場合は自動で`$PAGER`（既定`less`）に通す。パイプ・リダイレクト時はそのまま全文出力
- 履歴表示は`--sort`/`--asc`/`--desc`/`-r`で並べ替え可能（既定: `change`は`created_at`昇順、`summary <project>`は`created_at`降順・直近5件）。`summary`の横断表示の並べ替えは`--sort {created_at,project}`のみ
- `summary`は`--date YYYY-MM-DD`で指定日付の記録のみに絞り込める（作業履歴の日次抽出など外部連携用途）。横断表示では「最新1件」ではなく該当する記録全部（複数プロジェクト分）を表示し、履歴表示では`-n`の既定値を無視して全件表示する（`-n`を明示指定した場合はそちらが優先）
- `--from`/`--to`で日時範囲による絞り込みもできる（`--from`は以上、`--to`は未満）。日付のみの指定も可（`00:00:00`扱い）。`--date`と併用でき、指定した条件はすべてAND合成される（例: 日付境界と実際の作業感覚がずれる深夜作業を前日扱いにしたい場合は`--from "2026-09-17 06:00" --to "2026-09-18 06:00"`のように指定する）
- `--date`/`--from`/`--to`はいずれも区切り文字に`-`と`/`の両方（`2026-09-18`/`2026/09/18`）、ゼロパディングの有無どちらも受け付ける

### todo の表示

- タスクリスト記法（`- [ ] ...` / `- [x] ...`）で出力
- 作成日時は非表示
- `change`と同様、横断表示は持たない（`project`省略時はCWD自動推測）

### #id表示（summary/change/todo/request共通）

- 既定では非表示、`--id`を付けた時だけ表示

### search の表示

- `entries`（summary/change）と`todos`の両方を対象に、本文の部分一致（大小文字区別なし）で検索
- ヒット箇所前後（既定80文字）のスニペットを表示
- todoのヒットは`#id`と完了状態（`[x]`/`[ ]`）も表示
- `project`省略時はカレントディレクトリから推測（他コマンドと同じCWD自動推測）。全プロジェクト横断で検索したい場合は`--global`/`-g`を付ける（`project`とは同時指定不可）
- summary/changeの`#id`は`show summary|change <project> <id>`で全文表示できる
- 単純な部分一致のため、複合語をまたいだ誤ヒットがありうる（例: `PDO`で`BitmapDocument`にヒット）

### request（他プロジェクトからの依頼）

- `add request <project> [--from <source_project>]`で他プロジェクトからの依頼をTODOとして記録
- `project`（依頼先）は明示必須、`--from`（依頼元）は省略するとカレントディレクトリから推測
- `todo`はrequestも含めて全件表示（見出しに`[from: <source_project>]`が付く）
- `request`でrequestだけに絞り込み。`project`省略時は全プロジェクトの未完了requestをプロジェクトごとに横断表示（他プロジェクトへの依頼の対応漏れチェック用）
- 完了操作は通常のtodoと同じ`finish todo`

### update/delete（訂正・削除）

- `update summary|change|todo [project] <id> [--at 日時]`で本文を標準入力の内容に置き換え
- `delete summary|change|todo [project] <id>`で削除
- `update`は`add`と同様、見出しレベル制約（`#`/`##`禁止）を検証
- `project`/`kind`/`id`の組み合わせが一致しない場合はエラー

### export/import（データの持ち出し・持ち込み）

- `export [project]`（省略時は全プロジェクト）でJSON形式に書き出し
- `import`で標準入力から取り込み（デフォルトは`INSERT OR REPLACE`、`--safety`でエラー中断に切り替え）
- `entries`/`todos`は元の`id`があれば上書き、無ければ自動採番で新規追加
- `projects`も`name`が既存なら上書き（`path`が異なる環境へ移行した場合はimport後に`init`で設定し直す）
- `--safety`指定時は`id`/`name`の重複でエラー中断し、import全体をロールバック
- 未登録のプロジェクトはexport内の`path`で自動`init`
- 参照先プロジェクトが未登録かつimportデータにも含まれない場合はエラー

### rename（プロジェクト名の変更）

- `rename [old_name] <new_name>`でプロジェクト名を変更
- `projects.name`・`entries.project`・`todos.project`・`todos.from_project`をまとめて更新
- `path`は変更しないため、CWD自動推測はrename後も引き続き機能

## 備考

### データの保存先

SQLiteにて管理（`~/.collog/collog.db`がデフォルト、`COLLOG_DB`環境変数で変更可）。

### 依存ライブラリ

標準ライブラリのみ使用（`argparse`, `sqlite3`など）。追加インストール不要。
