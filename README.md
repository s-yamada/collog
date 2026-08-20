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

collog add summary <project> [--at 日時]   # 標準入力の内容をSUMMARYとして記録
collog add change <project> [--at 日時]    # 標準入力の内容をCHANGESとして記録
collog add todo <project> [--at 日時]      # 標準入力の内容をTODOとして追加
collog add request <project> --from <source_project> [--at 日時]
                                           # 他プロジェクトからの依頼としてTODOに追加
collog finish todo <project> <id> [--at 日時]  # 指定TODOを完了にする

collog list todos|todo <project> [--all] [--no-id]  # TODO一覧（既定は未完了のみ、requestも含む）
collog list requests|request <project> [--all] [--no-id]  # 上記のうちrequestだけに絞り込み
collog list changes|change <project> [-n] [--sort created_at|id] [--asc|--desc] [-r]
                                           # CHANGESの一覧をMarkdown形式で表示

collog status [project] [--sort ...] [--asc|--desc] [-n] [-r]
                                           # project省略時: 全プロジェクトの最新SUMMARYを横断表示
                                           # project指定時: そのプロジェクトのSUMMARY履歴を表示

collog search summaries|summary|changes|change|todos|todo|all <keyword> [project]
                                           # 本文にkeywordを含む記録を横断検索
collog show summary|change <project> <id> # SUMMARY/CHANGESを1件だけ表示

collog help [command...]                  # サブコマンドのヘルプを表示（'<cmd> -h'と同じ）
```

`add`/`list`/`finish`/`search`/`show`は、それぞれさらに対象（`summary`/`change`/`todo`等）を
指定する2段階のサブコマンドになっている。`list`/`search`の対象名は単数形でも指定できる
（`list todos`↔`list todo`など。ただし`search all`だけは省略・単数化していない——検索
キーワード自体が種別名と偶然一致した場合に誤動作するため）。各サブコマンドの詳細は
`collog <cmd> -h` または `collog help <cmd> [<サブコマンド>]`（例: `collog help add summary`）
で確認できる。

### list todos の表示

各項目をGFM（GitHub Flavored Markdown）のタスクリスト記法（`- [ ] ...` / `- [x] ...`）で
出力する（素の`[ ]`は`mdcat`等でMarkdown化すると1段落にmergeされてしまうため）。作成日時は
表示しない。`#id`は`finish todo`の入力として必須なため既定で表示するが、閲覧目的で邪魔な場合は
`--no-id`で消せる。

### request（他プロジェクトからの依頼）

`add request <project> --from <source_project>`で、他プロジェクトからの依頼をTODOとして
記録する。`--from`はcollogで唯一の必須フラグ（他は全て任意）——`project`（依頼先）と
`source_project`（依頼元）が同じ「プロジェクト名」という形の値なので、位置引数2つだと
順序を取り違えやすく、名前付きで明示する方を選んだ。

内部的には独立テーブルではなく`todos`に`from_project`列を足しただけなので、
`finish todo`/`search todos`はそのまま使える。`list todos`はrequestも含めて全件表示し
（見落とし防止）、見出しに`[from: <source_project>]`タグが付く。`list requests`で
requestだけに絞り込める。

### status / list changes の表示

いずれもMarkdown形式で出力する（`status`は横断時`# collog status` + `## [日時] project`見出し、
project指定時`# collog status: <project>` + `## 日時`見出し。`list changes`は
`# collog changes: <project>` + `## 日時`見出し）。`status`の横断表示のみ、標準出力が端末（TTY）
の場合に本文を冒頭の段落（無ければ400文字付近の文末）でプレビュー表示する（project指定時の
`status`と`list changes`は常に全文表示）。

出力全体が端末の行数を超える場合のみ自動で`$PAGER`（未設定なら`less`）に通す（3パターンとも
共通）。パイプ・リダイレクト時（非TTY）はページャを経由せず、省略せず全文を出力する。

並べ替えは`--sort`と`--asc`/`--desc`で指定する。`list changes`の既定は`created_at`昇順
（changelogを古い方から時系列で読む用途のため）。`status`にproject指定時の既定は`created_at`
降順（新しい方から。省略時は`--sort {created_at,project}`が選べる）。`-r`は、`-n`件を絞り込んだ
後の**表示順だけ**を反転する（`status`/`list changes`ともproject指定時のみ有効。例:
直近3件を古い方から時系列順に読みたい時は`status <project> -n 3 -r`）。

### search の表示

本文にキーワードを含む記録を、`entries`（summary/change）と`todos`の両方から検索する。
大小文字は区別しない部分一致で、ヒット箇所の前後（既定80文字ずつ）を切り出した
スニペットを表示する（grepのcontext表示に近い形）。todoのヒットは`#id`と完了状態
（`[x]`/`[ ]`）も見出しに含める。`project`は省略可（省略時は全プロジェクト横断）。

単純な部分一致のため、複合語の境界をまたいだ偶然の一致がありうる（例: `PDO`で検索すると
`BitmapDocument`にヒットすることがある）。単語境界を意識した検索は日本語との相性が
悪いため、今のところ見送っている。

見出しには`#id`を含める（summary/changeも含め全種別）。summary/changeの`#id`は
`show summary|change <project> <id>`に渡すと、その1件だけを全文表示できる
（スニペットで気になった記録を、そのまま全文で確認する用途）。

## 備考

### データの保存先

SQLiteにて管理（`~/.collog/collog.db`がデフォルト、`COLLOG_DB`環境変数で変更可）。

### 依存ライブラリ

標準ライブラリのみ使用（`argparse`, `sqlite3`など）。追加インストール不要。
