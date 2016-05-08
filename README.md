# WKWiki

D言語製の弱いWiki/Blogソフトウェアです．
弱いので，このソフトウェア単体ではWiki/Blogとして動作しません．

Wikiとして動作させるためには，MDWikiやJekyllといったソフトウェアと連携する必要があります．
MDWikiやJekyllといったソフトウェアと連携することで，次のようなことが可能になります．

+ Javascriptを通じて，Markdownファイルの追加(上書変更)・取得・削除などが行えます．
+ したがって，HTML上でMarkdownを編集することが可能になります．
+ Javascriptを通じて，任意のページに関連付けられた添付ファイルの追加(上書変更)・取得・削除が行えます．
+ したがって，Wikiに必要な要素である添付ファイルという概念を容易に扱うことができます．


## WKWikiの利点

WKWikiは，他のWikiソフトウェアとは異なり，データベースを必要としません．
Markdownファイルや添付ファイルは常にローカルディスクに保存されます．
これは，Wikiソフトウェアの乗換の際には大いに役立つはずです．
また，Jekyllでサイトを構築できるため，サイトの自由度は格段に上昇します．

## WKWikiの欠点

WKWikiは単体では動作せず，MDWikiやJekyllの力を借りる必要があります．
また，標準ではMarkdownや添付ファイルの追加・取得・削除以外のAPIは提供していません．
したがって，一般的なWiki/Blogで搭載されている次の機能を有していません．

+ ユーザ認証
+ 閲覧制限や編集権限制限
+ 編集履歴の閲覧 (git及びgitlabで代替は可能)
+ 検索機能


## TODO

+ Markdown以外の任意のファイル形式に対応する
+ 全文検索API (やるかも)


## WKWikiを動かす

`source/app.d`やその他ソースファイル，`public`フォルダなどを書き換えた後，次のコマンドを実行するだけです．

~~~~
$ dub
~~~~


## WKWikiの詳細

WKWikiはWiki/Blogソフトウェアではありません．
WKWikiは，ファイルのuploadとdownloadをサポートするREST APIを持ったサーバソフトウェアです．

WKWikiでは次のようなAPIをサポートしています．

~~~~
POST /api/document.json
GET  /api/document.json
DEL  /api/document.json

POST /api/attachment.json
GET  /api/attachment.json
DEL  /api/attachment.json
~~~~


### `POST /api/document.json`

このAPIは，HTTPサーバ上のあるパスに対応するMarkdownファイルを追加するためのAPIです．
このAPIのインターフェイスは次のようになっています．

~~~~~d
/**
 * path: ドキュメントへのパス
 *       例1: index.html
 *       例2: /foo/bar/hoge/fuge.html
 *
 * document: Markdownドキュメントの内容
 */
bool addDocument(string path, string document);
~~~~~


### `GET /api/document.json`

このAPIは，HTTPサーバのあるパスに対応するMarkdownファイルを取得するためのAPIです．
このAPIのインターフェイスは次のようになっています．

~~~~d
struct Document
{
    string document;            // Markdownファイルの中身
    string[] attachmentList;    // 添付ファイルのファイル名リスト
}

Document getDocument(string path);
~~~~~


### `DEL /api/document.json`

このAPIは，HTTPサーバ上のあるパスに対応するMarkdownファイルを削除するためのAPIです．
このAPIのインターフェイスは次のようになっています．

~~~~d
bool deleteDocument(string path);
~~~~~


### `POST /api/attachment.json`

このAPIは，HTTPサーバのあるパスにあるドキュメントに関連付けられた添付ファイルを追加するためのAPIです．
このAPIのインターフェイスは次のようになっています．

~~~~d
/**
 * path: 関連付けるドキュメントへのパス
 *       例1: index.html
 *       例2: /foo/bar/hoge/fuge.html
 *
 * name: ファイル名
 *       例1: foo.txt
 *       例2: slide.pptx
 *
 * content: Base64エンコードされたファイルの内容
 */
bool addAttachment(string path, string name, string content);
~~~~~


### `GET /api/attachment.json`

このAPIは，HTTPサーバのあるパスにあるドキュメントに関連付けられた添付ファイルを取得するためのAPIです．
このAPIのインターフェイスは次のようになっています．

~~~~d
// 返却値は，添付ファイルがBase64エンコードされた文字列
string getAttachment(string path, string name);
~~~~


### `DEL /api/attachment.json`

このAPIは，HTTPサーバのあるパスにあるドキュメントに関連付けられた添付ファイルを削除するためのAPIです．
このAPIのインターフェイスは次のようになっています．

~~~~d
bool deleteAttachment(string path, string name);
~~~~
