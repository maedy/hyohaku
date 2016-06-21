Hyohaku
====

[漫画スキャン王](http://mangascanoh.com/)で取り込んだ PDF ファイルを ZIP ファイルに変換する sh スクリプトです。

## 説明

[漫画スキャン王](http://mangascanoh.com/)で取り込んだ PDF ファイルのファイル名を [ComicGlass](http://comicglass.net/) などで表示しやすい以下の形式の ZIP ファイルに変換します。

\[著者名\] 漫画タイトル 第N巻.zip

zip ファイルに変換する過程で、 PDF ファイルの各ページを JPEG ファイルに分割し、カラーページはそのまま、グレースケールのページは紙質感を除去(漂白)します。

## 必要なツール

以下のツールがインストールされている Linux, BSD, Mac OS X なら動くと思います。

* [ImageMagick](http://www.imagemagick.org/)
* [Poppler](https://poppler.freedesktop.org/)
* [Zip](http://www.info-zip.org/)

## 使い方

pdf という名前でディレクトリを作成し、変換したい PDF ファイルを置いて mkZip.sh を実行してください。
zip という名前でディレクトリが作成され、ZIP ファイルが生成されます。
オプションは特にありません。実行イメージは以下の通りです。

    $ mkdir pdf
    $ cp *.pdf pdf/
    $ sh mkZip.sh
    START
    ...
    DONE
  
pdf にあるファイルをすべて処理すると done という名前のディレクトリにオリジナルのファイルが移動します。

## 注意事項
オリジナルのファイルは残りますが、念のためバックアップを取った上で実行してください。
並列での処理は考慮していません。

## Licence
[GPL](http://www.gnu.org/licenses/)

## Author
[Ryo](https://github.com/maedy)

