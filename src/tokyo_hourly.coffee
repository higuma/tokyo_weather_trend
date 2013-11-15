FrameW = 940
FrameH = 480

Margin = {top: 20, right: 80, bottom: 40, left: 80}
Width = FrameW - Margin.left - Margin.right
Height = FrameH - Margin.top - Margin.bottom

$('#graph').html "
<svg width='#{FrameW}' height='#{FrameH}'>
  <g transform='translate(#{Margin.left},#{Margin.top})'>
    <rect class='bg' x='0' y='0' width='#{Width}' height='#{Height}' />
    <g class='x axis' transform='translate(0,#{Height})' />
    <g class='y axis temp'>
      <text class='y axis' x='#{-Height/2}' y='-3em'
       transform='rotate(-90)'>Temperature (℃)</text>
    </g>
    <g class='y axis prec' transform='translate(#{Width},0)'>
      <text class='y axis' x='#{-Height/2}' y='3.5em'
       transform='rotate(-90)'>Precipitation (mm/h)</text>
    </g>
    <path class='graph prec' />
    <path class='graph temp' />
    <rect class='pane' width='#{Width}' height='#{Height}' />
  </g>
</svg>"

xScale = d3.time.scale().range([0, Width])
yScaleT = d3.scale.linear().range([Height, 0])
yScaleP = d3.scale.linear().range([Height, 0])

timeFormat = (d) ->
  switch
    when d.getHours()
      "#{d.getHours()}:00"
    when d.getMonth() || d.getDate() > 1
      "#{d.getMonth() + 1}/#{d.getDate()}"
    else
      "#{d.getFullYear()}"

xAxis = d3.svg.axis()
  .scale(xScale)
  .tickFormat(timeFormat)
  .orient("bottom")
  .tickSize(-Height, 0)
  .tickPadding(6)

yAxisT = d3.svg.axis()
  .scale(yScaleT)
  .orient("left")
  .tickSize(-Width)
  .tickPadding(6)

yAxisP = d3.svg.axis()
  .scale(yScaleP)
  .orient("right")
  .tickSize(-Width)
  .tickPadding(6)

lineT = d3.svg.line()
  .interpolate("step-after")
  .x((d) -> xScale(d.time))
  .y((d) -> yScaleT(d.temp))

areaT = d3.svg.area()
  .interpolate("step-after")
  .x((d) -> xScale(d.time))
  .y0((d) -> yScaleT(d.min))
  .y1((d) -> yScaleT(d.max))

areaP = d3.svg.area()
  .interpolate("step-after")
  .x((d) -> xScale(d.time))
  .y0((d) -> yScaleP(0))
  .y1((d) -> yScaleP(d.prec))

searchData = (data, at) ->
  i0 = 0
  i1 = data.length - 1
  while i0 + 1 < i1
    iMid = (i0 + i1) >> 1
    if data[iMid].time <= at
      i0 = iMid
    else
      i1 = iMid
  i0

selectData = (data, domain) ->
  [from, to] = domain
  data.slice searchData(data, from), searchData(data, to) + 1

drawGraph = (data, classT, shapeT, strokeW) ->
  part = selectData data, xScale.domain()

  d3.select("path.graph.prec")
    .data([part])
    .classed("area", true)
    .attr("d", areaP)

  d3.select("path.graph.temp")
    .classed("line area", false)
    .classed(classT, true)
    .data([part])
    .attr("d", shapeT)
    .attr("stroke-width", strokeW)

  d3.select("g.x.axis").call(xAxis)
  d3.select("g.y.axis.temp").call(yAxisT)
  d3.select("g.y.axis.prec").call(yAxisP)

decodeData = (data) ->
  tzOffset = ((new Date()).getTimezoneOffset() + 9 * 60) * 60 * 1000
  convertTime = (epochHour) -> new Date(epochHour * 1000 * 3600 + tzOffset)
  format = [
    ['n', 4]
    ['f', 2, 1]
    ['F', 2, 1]
  ]
  size = Encode64.dataSize format
  result = []
  offset = 0
  length = data.length - size
  while offset <= length
    x = Encode64.decodeFormat(format, data, offset)
    result.push
      time: convertTime(x[0])
      temp: x[1]
      prec: x[2]
    offset += size
  result

class DataSet
  constructor: (data) ->
    tzOffset = ((new Date()).getTimezoneOffset() + 9 * 60) * 60 * 1000
    tm = (epoch) -> new Date(+epoch * 1000 + tzOffset)
    @data = [decodeData(data)]
    d0 = @data[0]
    d1 = []
    i = 0
    length = d0.length
    while i < length
      d = d0[i]
      if i + 1 < length
        e = d0[i + 1]
        prec = if d.prec > e.prec then d.prec else e.prec
        if d.temp < e.temp
          d1.push {time: d.time, min: d.temp, max: e.temp, prec: prec}
        else
          d1.push {time: d.time, min: e.temp, max: d.temp, prec: prec}
      else
        d1.push {time: d.time, min: d.temp, max: d.temp, prec: d.prec}
      i += 2
    @data.push d1

    while true
      d0 = d1
      i = 0
      length = d0.length
      return if length < 2
      d1 = []
      while i < length
        d = d0[i]
        if i + 1 < length
          e = d0[i + 1]
          d1.push
            time: d.time
            min: if d.min < e.min then d.min else e.min
            max: if d.max > e.max then d.max else e.max
            prec: if d.prec > e.prec then d.prec else e.prec
        else
          d1.push {time: d.time, min: d.min, max: d.max, prec: d.prec}
        i += 2
      @data.push d1

WDomainUnit = 60 * 60 * 1000

dataSet = undefined             # DataSet instance
tmin = tmax = wtmax = undefined # calculated from data
wtmin = 48 * WDomainUnit        # <== ADJUST!

draw = ->
  [t0, t1] = xScale.domain()
  d = (+t1 - t0) / (WDomainUnit * Width)
  if d <= 4
    drawGraph dataSet.data[0], "line", lineT, 1
  else
    i = Math.floor(Math.log(d) * Math.LOG2E) - 1
    drawGraph dataSet.data[i], "area", areaT, 4 / d

  data = dataSet.data[0]
  t0 = data[0].time if t0 < data[0].time
  t1 = data[data.length - 1].time if t1 > data[data.length - 1].time
  x0 = "#{t0.getFullYear()}/#{t0.getMonth() + 1}/#{t0.getDate()} #{t0.getHours()}:00"
  x1 = "#{t1.getFullYear()}/#{t1.getMonth() + 1}/#{t1.getDate()} #{t1.getHours()}:00"
  $('#title').text "Hourly weather of Tokyo (#{x0} - #{x1})"

onLoadData = (data) ->
  dataSet = new DataSet(data)

  data = dataSet.data[0]
  d0 = data[0].time
  d1 = data[data.length - 1].time
  xScale.domain [d0, d1]
  yScaleT.domain [d3.min(data, (d) -> d.temp) - 3,
                  d3.max(data, (d) -> d.temp) + 3]
  yScaleP.domain [0, d3.max(data, (d) -> d.prec) * 1.1]
  tmin = +d0
  tmax = +d1
  wtmax = 2 * (tmax - tmin)
  draw()

class DragGraph
  constructor: (@pane, event) ->
    @x0 = @x1 = event.clientX
    domain = xScale.domain()
    @t0 = @t1 = +domain[0]
    @wt = +domain[1] - @t0

  drag: (event) ->
    return if event.clientX == @x1
    @x1 = event.clientX
    t1 = @t1
    @t1 = @t0 - (@x1 - @x0) * @wt / Width
    @t1 = t1min if @t1 < (t1min = tmin - @wt / 2)
    @t1 = t1max if @t1 > (t1max = tmax - @wt / 2)
    return if @t1 == t1
    xScale.domain([new Date(@t1), new Date(@t1 + @wt)])
    draw()

class ZoomGraph
  constructor: (@pane, event) ->
    @y0 = event.clientY

  drag: (event) ->
    @zoom(event, @y0 - event.clientY)
    @y0 = event.clientY

  zoom: (event, dy) ->
    domain = xScale.domain()
    t0 = +domain[0]
    wt = +domain[1] - t0

    rc = (event.clientX - @pane[0].getBoundingClientRect().left) / Width
    tc = t0 + wt * rc

    wt = +domain[1] - t0
    wt *= Math.exp(-dy * 0.01)  # !!! ADJUST !!!
    wt = wtmin if wt < wtmin
    wt = wtmax if wt > wtmax

    t1 = tc - wt * rc
    t1 = t1min if t1 < (t1min = tmin - wt / 2)
    t1 = t1max if t1 > (t1max = tmax - wt / 2)
    xScale.domain [new Date(t1), new Date(t1 + wt)]
    draw()

pane = $("rect.pane")

action = undefined
setCaptureSupported = false

pane.mousedown (event) ->
  event.preventDefault()
  if event.ctrlKey or event.shiftKey
    action = new ZoomGraph(pane, event)
  else
    action = new DragGraph(pane, event)
  setCaptureSupported = pane[0].setCapture?     # IE/Moz only
  pane[0].setCapture() if setCaptureSupported

pane.mousemove (event) ->
  event.preventDefault()
  action.drag(event) if action?

pane.mouseup (event) ->
  action = undefined

pane.mouseout (event) ->
  action = undefined unless setCaptureSupported

pane.mousewheel (event, delta, deltaX, deltaY) ->
  event.preventDefault()        # disable scrolling on the pane
  return if action?
  zoom = new ZoomGraph(pane, event)
  zoom.zoom(event, deltaY * 10)

$('body').css 'cursor', "wait"

$.ajax("data/tokyo_hourly.dat").done (data) ->
  onLoadData(data)
  $('body').css 'cursor', "auto"
  $('rect.pane').css 'cursor', "move"

