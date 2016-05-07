# WKWiki

D言語製の弱いWikiソフトウェアです．
弱いので，このソフトウェア単体ではWikiとして動作しません．

Wikiとして動作させるためには，MDWikiやJekyllといったソフトウェアと連携する必要があります．


## WKWikiを動かす

`source/app.d`やその他ソースファイル，`public`フォルダなどを書き換えた後，次のコマンドを実行するだけです．

~~~~
$ dub
~~~~


## WKWikiの詳細

WKWikiはWikiソフトウェアではありません．
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
