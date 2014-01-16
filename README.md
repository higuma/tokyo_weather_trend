[CoffeeScript]: http://coffeescript.org/ "CoffeeScript"
[D3]: http://d3js.org/ "D3 - Data-Driven Documents"
[Decpack]: https://github.com/higuma/decpack "Decpack"
[Haml]: http://haml.info/ "Haml (HTML abstraction markup language)"
[Heroku]: https://www.heroku.com/ "Heroku"
[jQuery]: http://jquery.com/ "jQuery"
[jQuery Mousewheel]: http://plugins.jquery.com/mousewheel/ "jQuery Mousewheel"
[node.js]: http://nodejs.org/ "node.js"
[Rack]: http://rack.github.io/ "Rack: a Ruby Webserver Interface"
[Rake]: http://rake.rubyforge.org/ "Rake - Ruby Make"
[Sass]: http://sass-lang.com/ "Sass: Syntactically Awesome Style Sheets"

# 東京の気温・降水量長期トレンドグラフ

[English](README.en.md)

東京の気温/降水量の長期トレンドを表示するWebアプリケーションです。月間、一日、一時間の3種類のデータをズーム(横方向)、ドラッグ(左右)可能なグラフで表示します(下記タイトルをクリックするとそれぞれのページに進みます)。

## [月間統計値トレンド](http://tokyo-weather-trend.herokuapp.com/tokyo_monthly.html)

1876年1月から2013年12月までの月間値のトレンドグラフです。

* 気温(日平均の月間最小、最大: 赤のバー)
* 降水量(月間合計値: 青のバー)

## [一日統計値トレンド](http://tokyo-weather-trend.herokuapp.com/tokyo_daily.html)

1949年1月1日から2013年12月31日までの一日測定値のトレンドグラフです。

* 気温(一時間平均値の最小、最大: 赤のバー)
* 降水量(一日積算値: 青のバー)

## [一時間統計値トレンド](http://tokyo-weather-trend.herokuapp.com/tokyo_hourly.html)

> (注意)データ量が多いため立ち上げにやや時間を要します。

1990年1月1日 1:00から2014年1月1日 0:00までの一時間測定値のトレンドグラフです。

* 気温(一時間平均値: 赤の折れ線)
* 降水量(一時間積算値: 青のバー)

## 使用データ

気象庁の「過去の気象データ探索」からデータを入手してCSVにしたものを用いています。今回は気象庁にある最も古いデータから2013年12月31日までを対象としました。

<http://www.data.jma.go.jp/obd/stats/etrn/index.php>

## 使用ライブラリ、ツール

コードは[CoffeeScript][]で記述しています(要[node.js][])。次のJavaScriptライブラリを使用しています。

* [D3][]
* [jQuery][]
* [jQuery Mousewheel][]

HTMLとCSSのコード生成は[Haml][]と[Sass][]、プロジェクト管理は[Rake][]を用いています。

またデータの圧縮には自作の数値データ専用圧縮ライブラリ[Decpack][]を用いています。

## ライセンス

プログラムコードはMITライセンスとします。データは入手元の気象庁のガイドラインに従います。

