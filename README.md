[Heroku]: https://www.heroku.com/ "Heroku"
[D3]: http://d3js.org/ "D3 - Data-Driven Documents"
[jQuery]: http://jquery.com/ "jQuery"
[jQuery Mousewheel]: http://plugins.jquery.com/mousewheel/ "jQuery Mousewheel"
[node.js]: http://nodejs.org/ "node.js"
[CoffeeScript]: http://coffeescript.org/ "CoffeeScript"
[Rack]: http://rack.github.io/ "Rack: a Ruby Webserver Interface"
[Rake]: http://rake.rubyforge.org/ "Rake - Ruby Make"

# 東京の気温・降水量長期トレンド

[English](README.en.md)

東京の気温/降水量の長期トレンドを表示するWebアプリケーションです。月間、一日、一時間の3種類のデータをズーム(横方向)、ドラッグ(左右)可能なグラフで表示します(下記タイトルをクリックするとそれぞれのページに進みます)。

## [月間統計値トレンド](http://tokyo-weather-trend.herokuapp.com/tokyo_monthly.html)

1876年1月から2013年10月までの月間値のトレンドグラフです。

* 気温(日平均の月間最小、最大: 赤のバー)
* 降水量(月間合計値: 青のバー)

## [一日統計値トレンド](http://tokyo-weather-trend.herokuapp.com/tokyo_daily.html)

1949年1月1日から2013年10月31日までの一日測定値のトレンドグラフです。

* 気温(一時間平均値の最小、最大: 赤のバー)
* 降水量(一日積算値: 青のバー)

## [一時間統計値トレンド](http://tokyo-weather-trend.herokuapp.com/tokyo_hourly.html)

1990年1月1日 1:00から2013年11月1日 0:00までの一時間測定値のトレンドグラフです。

> (注意)データ量が多いため立ち上げに少し時間がかかります。

* 気温(一時間平均値: 赤の折れ線)
* 降水量(一時間積算値: 青のバー)

## 使用データ

気象庁の「過去の気象データ探索」からデータを入手してCSVにしたものを元データとして用いています。今回は気象庁で入手できる最も古いデータから2013年10月30日までを対象としました。

<http://www.data.jma.go.jp/obd/stats/etrn/index.php>

## 使用ライブラリ

次のJavaScriptライブラリを使用しています。

* [D3][]
* [jQuery][]
* [jQuery Mousewheel][]

またクライアントサイドJavaScriptコードの生成に[node.js][]上の[CoffeeScript][]を用いています。

## サーバサイド([Heroku][])の設定

本アプリケーションは[Heroku][]を利用して公開しています。サーバ側で実行するコードのないstaticなアプリケーションですが、[Heroku][]を利用する場合は最低限何かコードを記述しないとファイルを公開できません。

Rubyを使う場合は[Rack][]を利用するのが最も簡単な方法です。今回使った`config.ru`の設定は次の通りです。これで`public/`ディレクトリの内容を公開し、`/`へのアクセスを`public/index.html`に解決します。

``` ruby
use Rack::Static, urls: [''], root: 'public', index: 'index.html'
run lambda {|env|}
```

## その他

データ量が多いため自作の特殊エンコーディングで圧縮しています(元のCSVファイルから約40%に削減)。このエンコード処理はRubyで記述しています。またプロジェクト管理に[Rake][]を使っています(ファイル生成手順はRakefileを参照して下さい)。

## ライセンス

MIT
