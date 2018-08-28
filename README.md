# Pukiwiki2esa: PukiWiki の記事と添付ファイルを esa へ移行する

PukiWiki を esa へ移行するスクリプトのサンプルです。実際、私の環境でこのスクリプトを使って移行をしましたが、手順依存の部分があるため動作の保証はしません。

![pukiwiki2esa.svg](https://site.hacklife.net/images/articles/purkiwiki2esa.svg)

説明については以下のブログ記事を参照してください。

* [Ruby で自分のための問題を解決していく話 (個人の Wiki を esa に移行した話)](https://site.hacklife.net/articles/from-pukiwiki-to-esa/)
* [Ruby で自分のための問題を解決していく話 (個人の Wiki を esa に移行した話) : 続き](https://site.hacklife.net/articles/from-pukiwiki-to-esa-2/)

ブログの記事にコードを転載にするにあたってなるべく個人に依存する情報を外へ追い出したつもりですが、まだ一部依存があったりするのでこのままは使えない部分があります (create_post の author が sunaot 固定だったりとか)。使う場合は適宜調整してください。

極力不可逆な操作をしないようにしていますが、S3 へのアップロードと esa への記事投稿は副作用のある操作なので実行前にコードを読んで内容を理解し、DRYRUN やら CONTINUE やらを適切に設定したり試験的に実行できる環境で試行してください。

実際使ったときは初回は WikiName の変換をしていなかったので WikiName のデータベースがなくても問題なく実行できていたり、いくらか実行手順に依存して今から新規でブログの手順で実行したときにうまく動かない部分があるかもしれません。あくまで事例として参考にして、これをベースで pukiwiki2md を使うサンプルとしての位置付けの公開です。

PukiWiki のコードは使っていませんが仕様には多いに依存しています。10年以上もの長い間お世話になった PukiWiki には足を向けて寝られません。ありがとうございました。

ブログ中でも書いていますがこんなファイルを作って使う想定にしています。

```
.
├── esa
├── esa_pages
├── esa_pages.full
├── esa_posts
├── files_index
└── update_pages
```

| name | description |
| --- | --- |
| esa | esa 用の Markdown を出力するディレクトリ. Git repo にして差分管理をする |
| esa_pages | esa に新規投稿するときの索引ファイル. esa_pages.full を元に投稿が終了したページを削除したもの. 途中で異常終了したときに CONTINUE = true にしてこのファイルに記載のページを対象に新規投稿を実行継続する |
| esa_pages.full | プログラムの中からは使われることがないファイル. `ruby -Ilib lib/page_file.rb > esa_pages.full` して作成する. 何度でも生成できるのでなくてもいい |
| esa_posts | esa 上の記事の索引ファイル. `lib/get_posts_esa.rb` を使って生成する |
| files_index | S3 へアップロードされた添付ファイルの索引ファイル。 `lib/upload.rb` が生成する. seed を固定しているので dry-run でも索引の生成はできます |
| update_pages | esa ディレクトリの差分からつくった更新対象のファイルリスト |

update_pages の作り方. esa ディレクトリで以下を実行する.

    git diff --name-status | grep -P '^M' | awk '{print $2}' > ../update_pages

また、使うときには `.config/file` と `.esa/credentials` を作成して設定を入れる必要があります。

なお、Gemfile があるので bundle install が必要とか、実行時には bundle exec が必要とか、lib のファイルを参照するから `ruby -Ilib lib/filename.rb` しないといけないとか、その辺の Ruby の作法がわからない場合はまずそこから調べて理解しておく必要があります。
