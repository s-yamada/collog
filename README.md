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

collog list summary [project] [-n] [--sort created_at|id] [--asc|--desc] [-r] [--id]
                                           # SUMMARY履歴を表示（1プロジェクト分。既定: 直近5件・新しい順）
collog list change [project] [-n] [--sort created_at|id] [--asc|--desc] [-r] [--id]
                                           # CHANGESの一覧をMarkdown形式で表示（既定: 全件・古い順）
collog list todo [project] [--all] [--id]  # TODO一覧（既定は未完了のみ、requestも含む）
collog list request [project] [--all] [--id]  # 上記のうちrequestだけに絞り込み

collog status [--sort created_at|project] [--asc|--desc]
                                           # 全プロジェクトの最新SUMMARYを横断表示

collog search summary|change|todo|all <keyword> [project]
                                           # 本文にkeywordを含む記録を横断検索
collog show summary|change [project] <id> # SUMMARY/CHANGESを1件だけ表示

collog update summary|change|todo [project] <id> [--at 日時]  # 本文を標準入力の内容で置き換え
collog delete summary|change|todo [project] <id>              # 削除

collog export [project]                   # データをJSON形式で書き出す（省略時は全プロジェクト）
collog import                              # 標準入力のJSON（exportの出力形式）を取り込む

collog help [command...]                  # サブコマンドのヘルプを表示（'<cmd> -h'と同じ）
```

`add`/`list`/`finish`/`search`/`show`は、それぞれさらに対象（`summary`/`change`/`todo`等）を
指定する2段階のサブコマンドになっている。対象名は`add`/`finish`/`show`と同じ単数形
（`summary`/`change`/`todo`/`request`）で統一している——`list`/`search`は元々複数形
（`todos`/`summaries`等）だったが、動詞によって種別名の数が違うと覚えにくいため単数形に
揃えた（複数形は入力としてのみ受け付ける非表示エイリアス。`list todo`↔`list todos`など。
ただし`search all`だけは省略・複数形化していない——検索キーワード自体が種別名と偶然
一致した場合に誤動作するため、明示必須のまま）。各サブコマンドの詳細は`collog <cmd> -h`
または `collog help <cmd> [<サブコマンド>]`（例: `collog help add summary`）で確認できる。

`[project]`と書かれている箇所は省略可能で、省略するとカレントディレクトリから登録済み
プロジェクトを推測する（`main/`のようなサブディレクトリからでも拾える。詳細は後述）。
`add request`の`project`（依頼先）だけは推測しようがないため引き続き明示必須。`status`は
横断表示専用で`project`引数自体を持たず、`search`の`project`省略は「全プロジェクト対象」
という別の意味なので、どちらも対象外。

### list todo の表示

各項目をGFM（GitHub Flavored Markdown）のタスクリスト記法（`- [ ] ...` / `- [x] ...`）で
出力する（素の`[ ]`は`mdcat`等でMarkdown化すると1段落にmergeされてしまうため）。作成日時は
表示しない。

### #id表示（list summary/change/todo/request共通）

`list`系4種はいずれも`#id`を既定では表示せず、`--id`を付けた時だけ表示する。ファイルへの
リダイレクトや他ツールへのパイプでは`#id`はノイズになりがちなこと、「一覧を見て気が
変わったら`--id`付きで実行し直せばよい」という程度の手間で済むことから、全コマンドで
「既定OFF・`--id`で表示」に統一している（`todo`/`request`は当初`finish todo`のために
既定表示にしていたが、後から反転した）。

### request（他プロジェクトからの依頼）

`add request <project> [--from <source_project>]`で、他プロジェクトからの依頼をTODOとして
記録する。`project`（依頼先）は明示必須、`--from`（依頼元）は省略するとカレントディレクトリ
から推測される（依頼を登録する時は大抵、依頼元のディレクトリで作業しているはずのため）。
`--from`を名前付きフラグにしているのは、`project`と`source_project`が同じ「プロジェクト名」
という形の値なので、位置引数2つだと順序を取り違えやすいため。

内部的には独立テーブルではなく`todos`に`from_project`列を足しただけなので、
`finish todo`/`search todo`はそのまま使える。`list todo`はrequestも含めて全件表示し
（見落とし防止）、見出しに`[from: <source_project>]`タグが付く。`list request`で
requestだけに絞り込める。

### projectのカレントディレクトリ自動推測

`[project]`と書かれているコマンドは、省略すると`os.getcwd()`を登録済み`projects.path`と
照合してプロジェクトを推測する。完全一致だけでなく、そのサブディレクトリ（`main/`等）に
いる場合も拾える。ネストした登録が複数一致する場合は最も深いパスを優先する。該当が無く
`project`も省略されている場合はエラーで終了する（`collog init`を促すメッセージが出る）。

`status`は横断表示専用で`project`引数を持たない。`search`の`project`省略は「全プロジェクト
対象」という別の意味を持つため、この自動推測の対象外（挙動は変えていない）。`add request`の
`project`（依頼先）も、CWDからは「今どのプロジェクトにいるか」しか分からず「どの他
プロジェクトへ送るか」は推測しようがないため対象外（`--from`（依頼元）は対象）。

### status / list summary・list change の表示

いずれもMarkdown形式で出力する（`status`は`# collog status` + `## [日時] project`見出し、
`list summary`/`list change`は`# collog list summary: <project>` /
`# collog list change: <project>` + `## 日時`見出し）。`status`は横断表示専用で、標準出力が
端末（TTY）の場合に本文を冒頭の段落（無ければ400文字付近の文末）でプレビュー表示する
（`list summary`/`list change`は常に全文表示）。

出力全体が端末の行数を超える場合のみ自動で`$PAGER`（未設定なら`less`）に通す（3パターンとも
共通）。パイプ・リダイレクト時（非TTY）はページャを経由せず、省略せず全文を出力する。

`list summary`/`list change`の並べ替えは`--sort`と`--asc`/`--desc`で指定する。`list change`の
既定は`created_at`昇順（changelogを古い方から時系列で読む用途のため）、`list summary`の
既定は`created_at`降順・`-n 5`（元は`status <project>`として実装していたものを移植した
挙動をそのまま継承）。`status`（横断表示）の並べ替えは`--sort {created_at,project}`のみ。
`-r`は、`-n`件を絞り込んだ後の**表示順だけ**を反転する（`list summary`/`list change`のみ。
例: 直近3件を古い方から時系列順に読みたい時は`list summary <project> -n 3 -r`）。

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

### update/delete（訂正・削除）

`update summary|change|todo [project] <id> [--at 日時]`で本文を標準入力の内容で
置き換え、`delete summary|change|todo [project] <id>`で削除する。`update`は`add`と
同様、本文の見出しレベル制約（`#`/`##`禁止）を検証する。`project`/`kind`/`id`の
組み合わせが一致しない場合はエラーで拒否する（他プロジェクト・他kindのidを
誤って指定した場合の誤爆防止）。

`entries`（summary/change）は元々「追記したら書き換えない」という設計方針だった
（`todos`だけ完了マークで`UPDATE`が発生するため別テーブルにした、という経緯もこの
前提あってのもの）。`list summary`/`list change`にも`--id`が付いて`show`と組み合わせ
やすくなったのを機に、「間違えたら直したい・消したい」という実需要を優先して
方針を転換した。対象を直近1件だけに絞る`amend`/`undo`方式（gitの`commit --amend`の
ような発想）も検討したが、任意のidを指定できる汎用コマンドとして実装している。

### export/import（データの持ち出し・持ち込み）

`export [project]`（省略時は全プロジェクト）でJSON形式に書き出し、`import`で
標準入力から取り込む。バックアップ、他マシンへの移行、他プロジェクトへの共有が
主な用途。

形式は普通のJSON（`{"projects": [...], "entries": [...], "todos": [...]}`）。
NDJSON・YAML・SQLダンプも検討したが、3テーブルをまとめる自然さと「標準ライブラリ
のみで完結する」原則（YAMLは`pyyaml`等の外部パッケージが必要）を優先し、通常の
JSONにした（`ensure_ascii=False`で出力し、日本語が`\uXXXX`エスケープされて
読みにくくなるのを防いでいる）。

importは元の`id`を使わず新規`INSERT`する（別DBへの取り込みでのid衝突を回避。
`created_at`/`completed_at`/`from_project`等は元の値を保持）。未登録の
プロジェクトはexport内の`path`で自動`init`する。`entries`/`todos`が参照する
プロジェクト（`from_project`含む）が「既に登録済み」でも「importデータの
`projects`に含まれる」でもない場合はエラーで拒否する（依存関係が欠けた不完全な
取り込みを防ぐ）。重複排除はしない。

### rename（プロジェクト名の変更）

`rename [old_name] <new_name>`で登録済みプロジェクトの名前を変更する（`old_name`は他の
`[project]`引数と同様、省略するとカレントディレクトリから推測される）。`projects.name`
だけでなく、`entries.project`・`todos.project`・`todos.from_project`（requestの依頼元
参照）も1トランザクションでまとめて更新する。`path`は変更しないため、CWD自動推測は
rename後もそのディレクトリから引き続き機能する。

`mv`（Unixの慣習）ではなく`rename`にしたのは、`mv`だと「移動」＝パス変更を連想させ、
既にパス変更は`init`の役割なので紛らわしいため。ここでやりたいのは識別子（名前）の
変更なので`rename`が実態に合う。

## 備考

### データの保存先

SQLiteにて管理（`~/.collog/collog.db`がデフォルト、`COLLOG_DB`環境変数で変更可）。

### 依存ライブラリ

標準ライブラリのみ使用（`argparse`, `sqlite3`など）。追加インストール不要。
