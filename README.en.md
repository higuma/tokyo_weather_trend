[Heroku]: https://www.heroku.com/ "Heroku"
[D3]: http://d3js.org/ "D3 - Data-Driven Documents"
[jQuery]: http://jquery.com/ "jQuery"
[jQuery Mousewheel]: http://plugins.jquery.com/mousewheel/ "jQuery Mousewheel"
[node.js]: http://nodejs.org/ "node.js"
[CoffeeScript]: http://coffeescript.org/ "CoffeeScript"
[Rack]: http://rack.github.io/ "Rack: a Ruby Webserver Interface"
[Rake]: http://rake.rubyforge.org/ "Rake - Ruby Make"

# Long-term temperature/precipitation trend of Tokyo

[日本語](README.md)

This web application displays long-term temperature/precipitation trend graphs of Tokyo. You can zoom and drag graph horizontally (click on the titles to view graphs).

## [Monthly stats trend](http://tokyo-weather-trend.herokuapp.com/tokyo_monthly.html)

Monthly statistics trend graph from Jan. 1876 to Oct. 2013.

* temperature (monthly min/max of daily average: red bar)
* precipitation (monthly total: blue bar)

## [Daily stats trend](http://tokyo-weather-trend.herokuapp.com/tokyo_daily.html)

Daily statistics trend graph from Jan. 1 1949 to Oct. 31 2013.

* temperature (daily min/max of hourly average: red bar)
* precipitation (daily total: blue bar)

## [Hourly stats trend](http://tokyo-weather-trend.herokuapp.com/tokyo_hourly.html)

Hourly statistics trend graph from 01:00 Jan. 1 1990 to 00:00 Nov. 1 2013.

> (Caution) takes time at start-up due to large data.

* temperature (hourly average: red line)
* precipitation (hourly total: blue bar)

## Data

Original data is obtained from Japan meteorological agency and converted to CSV.

<http://www.data.jma.go.jp/obd/stats/etrn/index.php>

## JavaScript libraries

This application uses the following JavaScript libraries.

* [D3][]
* [jQuery][]
* [jQuery Mousewheel][]

Also uses [CoffeeScript][] on [node.js][] to generate client-side JavaScript code.

## Server-side ([Heroku][]) settings

The applitation does not uses any server-side code (this is a static application). However using [Heroku][], you cannot publish anything without writing some small code.

If you uses Ruby, [Rack][] is an easiest way. This is minimum `config.ru` setting for this application. It publishes `public/` directory on the web and also resolves '/' to 'public/index.html'

``` ruby
use Rack::Static, urls: [''], root: 'public', index: 'index.html'
run lambda {|env|}
```

## Miscellaneous

This application uses custom (hand-made) encoding to compress CSV data to condenced text (to about 40%). The encoding process is written in Ruby.

[Rake][] is used for project management and file generation (please refer `src/Rakefile`).

## License

MIT
