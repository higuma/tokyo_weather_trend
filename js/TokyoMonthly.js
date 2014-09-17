// Generated by CoffeeScript 1.6.3
(function() {
  var DataSet, DragGraph, FrameH, FrameW, Height, Margin, WDomainUnit, Width, ZoomGraph, action, areaP, areaT, dataSet, decodeData, draw, drawGraph, onLoadData, pane, searchData, selectData, setCaptureSupported, timeFormat, tmax, tmin, wtmax, wtmin, xAxis, xScale, yAxisP, yAxisT, yScaleP, yScaleT;

  FrameW = 940;

  FrameH = 480;

  Margin = {
    top: 20,
    right: 80,
    bottom: 40,
    left: 80
  };

  Width = FrameW - Margin.left - Margin.right;

  Height = FrameH - Margin.top - Margin.bottom;

  $('#graph').html("<svg width='" + FrameW + "' height='" + FrameH + "'>  <g transform='translate(" + Margin.left + "," + Margin.top + ")'>    <rect class='bg' x='0' y='0' width='" + Width + "' height='" + Height + "' />    <g class='x axis' transform='translate(0," + Height + ")' />    <g class='y axis temp'>      <text class='y axis' x='" + (-Height / 2) + "' y='-4.5em'       transform='rotate(-90)'>Temperature (℃)</text>    </g>    <g class='y axis prec' transform='translate(" + Width + ",0)'>      <text class='y axis' x='" + (-Height / 2) + "' y='5em'       transform='rotate(-90)'>Precipitation (mm/month)</text>    </g>    <path class='graph prec area' />    <path class='graph temp area' stroke-width='0.2' />    <rect class='pane' width='" + Width + "' height='" + Height + "' />  </g></svg>");

  xScale = d3.time.scale().range([0, Width]);

  yScaleT = d3.scale.linear().range([Height, 0]);

  yScaleP = d3.scale.linear().range([Height, 0]);

  timeFormat = function(d) {
    switch (false) {
      case !d.getHours():
        return "" + (d.getHours()) + ":00";
      case !(d.getMonth() || d.getDate() > 1):
        return "" + (d.getMonth() + 1) + "/" + (d.getDate());
      default:
        return "" + (d.getFullYear());
    }
  };

  xAxis = d3.svg.axis().scale(xScale).tickFormat(timeFormat).tickFormat(function(d) {
    return timeFormat(d);
  }).orient("bottom").tickSize(-Height, 0).tickPadding(10);

  yAxisT = d3.svg.axis().scale(yScaleT).orient("left").tickSize(-Width).tickPadding(18);

  yAxisP = d3.svg.axis().scale(yScaleP).orient("right").tickSize(-Width).tickPadding(18);

  areaT = d3.svg.area().interpolate("step-after").x(function(d) {
    return xScale(d.time);
  }).y0(function(d) {
    return yScaleT(d.min);
  }).y1(function(d) {
    return yScaleT(d.max);
  });

  areaP = d3.svg.area().interpolate("step-after").x(function(d) {
    return xScale(d.time);
  }).y0(function(d) {
    return yScaleP(0);
  }).y1(function(d) {
    return yScaleP(d.prec);
  });

  searchData = function(data, at) {
    var i0, i1, iMid;
    i0 = 0;
    i1 = data.length - 1;
    while (i0 + 1 < i1) {
      iMid = (i0 + i1) >> 1;
      if (data[iMid].time <= at) {
        i0 = iMid;
      } else {
        i1 = iMid;
      }
    }
    return i0;
  };

  selectData = function(data, domain) {
    var from, to;
    from = domain[0], to = domain[1];
    return data.slice(searchData(data, from), searchData(data, to) + 2);
  };

  drawGraph = function(data, strokeW) {
    var part;
    part = selectData(data, xScale.domain());
    d3.select("path.graph.prec").data([part]).attr("d", areaP);
    d3.select("path.graph.temp").data([part]).attr("d", areaT);
    d3.select("g.x.axis").call(xAxis);
    d3.select("g.y.axis.temp").call(yAxisT);
    return d3.select("g.y.axis.prec").call(yAxisP);
  };

  decodeData = function(data) {
    var convertTime, pr, t0, t1, tm, tzOffset, unpack;
    tzOffset = ((new Date()).getTimezoneOffset() + 9 * 60) * 60 * 1000;
    convertTime = function(epochHour) {
      return new Date(epochHour * 1000 * 3600 + tzOffset);
    };
    unpack = Decpack.unpack(data, {
      eof: true
    });
    data = [];
    while (!unpack.eof()) {
      tm = convertTime(unpack.b(21));
      t0 = unpack.r(10, 1);
      t1 = unpack.r(10, 1);
      pr = unpack.R(13, 1);
      data.push({
        time: tm,
        min: t0,
        max: t1,
        prec: pr
      });
    }
    return data;
  };

  DataSet = (function() {
    function DataSet(data) {
      var d, d0, d1, e, i, length;
      this.data = [decodeData(data)];
      d1 = this.data[0];
      while (true) {
        d0 = d1;
        i = 0;
        length = d0.length;
        if (length < 2) {
          return;
        }
        d1 = [];
        while (i < length) {
          d = d0[i];
          if (i + 1 < length) {
            e = d0[i + 1];
            d1.push({
              time: d.time,
              min: d.min < e.min ? d.min : e.min,
              max: d.max > e.max ? d.max : e.max,
              prec: d.prec > e.prec ? d.prec : e.prec
            });
          } else {
            d1.push({
              time: d.time,
              min: d.min,
              max: d.max,
              prec: d.prec
            });
          }
          i += 2;
        }
        this.data.push(d1);
      }
    }

    return DataSet;

  })();

  WDomainUnit = 30 * 24 * 60 * 60 * 1000;

  dataSet = void 0;

  tmin = tmax = wtmax = void 0;

  wtmin = 60 * WDomainUnit;

  draw = function() {
    var d, data, i, t0, t1, x0, x1, _ref;
    _ref = xScale.domain(), t0 = _ref[0], t1 = _ref[1];
    d = (+t1 - t0) / (WDomainUnit * Width);
    i = Math.floor(Math.log(d) * Math.LOG2E) - 1;
    if (i < 0) {
      i = 0;
    }
    drawGraph(dataSet.data[i]);
    data = dataSet.data[0];
    if (t0 < data[0].time) {
      t0 = data[0].time;
    }
    if (t1 > data[data.length - 1].time) {
      t1 = data[data.length - 1].time;
    }
    x0 = "" + (t0.getFullYear()) + "/" + (t0.getMonth() + 1);
    x1 = "" + (t1.getFullYear()) + "/" + (t1.getMonth() + 1);
    return $('#title').text("Monthly weather of Tokyo (" + x0 + " - " + x1 + ")");
  };

  onLoadData = function(data) {
    var d0, d1;
    dataSet = new DataSet(data);
    data = dataSet.data[0];
    d0 = data[0].time;
    d1 = data[data.length - 1].time;
    xScale.domain([d0, d1]);
    yScaleT.domain([
      d3.min(data, function(d) {
        return d.min;
      }) - 2, d3.max(data, function(d) {
        return d.max;
      }) + 2
    ]);
    yScaleP.domain([
      0, d3.max(data, function(d) {
        return d.prec;
      }) * 1.1
    ]);
    tmin = +d0;
    tmax = +d1;
    wtmax = 2 * (tmax - tmin);
    return draw();
  };

  DragGraph = (function() {
    function DragGraph(pane, event) {
      var domain;
      this.pane = pane;
      this.x0 = this.x1 = event.clientX;
      domain = xScale.domain();
      this.t0 = this.t1 = +domain[0];
      this.wt = +domain[1] - this.t0;
    }

    DragGraph.prototype.drag = function(event) {
      var t1, t1max, t1min;
      if (event.clientX === this.x1) {
        return;
      }
      this.x1 = event.clientX;
      t1 = this.t1;
      this.t1 = this.t0 - (this.x1 - this.x0) * this.wt / Width;
      if (this.t1 < (t1min = tmin - this.wt / 2)) {
        this.t1 = t1min;
      }
      if (this.t1 > (t1max = tmax - this.wt / 2)) {
        this.t1 = t1max;
      }
      if (this.t1 === t1) {
        return;
      }
      xScale.domain([new Date(this.t1), new Date(this.t1 + this.wt)]);
      return draw();
    };

    return DragGraph;

  })();

  ZoomGraph = (function() {
    function ZoomGraph(pane, event) {
      this.pane = pane;
      this.y0 = event.clientY;
    }

    ZoomGraph.prototype.drag = function(event) {
      this.zoom(event, this.y0 - event.clientY);
      return this.y0 = event.clientY;
    };

    ZoomGraph.prototype.zoom = function(event, dy) {
      var domain, rc, t0, t1, t1max, t1min, tc, wt;
      domain = xScale.domain();
      t0 = +domain[0];
      wt = +domain[1] - t0;
      rc = (event.clientX - this.pane[0].getBoundingClientRect().left) / Width;
      tc = t0 + wt * rc;
      wt = +domain[1] - t0;
      wt *= Math.exp(-dy * 0.01);
      if (wt < wtmin) {
        wt = wtmin;
      }
      if (wt > wtmax) {
        wt = wtmax;
      }
      t1 = tc - wt * rc;
      if (t1 < (t1min = tmin - wt / 2)) {
        t1 = t1min;
      }
      if (t1 > (t1max = tmax - wt / 2)) {
        t1 = t1max;
      }
      xScale.domain([new Date(t1), new Date(t1 + wt)]);
      return draw();
    };

    return ZoomGraph;

  })();

  pane = $("rect.pane");

  action = void 0;

  setCaptureSupported = false;

  pane.mousedown(function(event) {
    event.preventDefault();
    if (event.ctrlKey || event.shiftKey) {
      action = new ZoomGraph(pane, event);
    } else {
      action = new DragGraph(pane, event);
    }
    setCaptureSupported = pane[0].setCapture != null;
    if (setCaptureSupported) {
      return pane[0].setCapture();
    }
  });

  pane.mousemove(function(event) {
    event.preventDefault();
    if (action != null) {
      return action.drag(event);
    }
  });

  pane.mouseup(function(event) {
    return action = void 0;
  });

  pane.mouseout(function(event) {
    if (!setCaptureSupported) {
      return action = void 0;
    }
  });

  pane.mousewheel(function(event, delta, deltaX, deltaY) {
    var zoom;
    event.preventDefault();
    if (action != null) {
      return;
    }
    zoom = new ZoomGraph(pane, event);
    return zoom.zoom(event, deltaY * 10);
  });

  $('body').css('cursor', "wait");

  $.ajax("data/tokyo_monthly.dp6").done(function(data) {
    onLoadData(data);
    $('body').css('cursor', "auto");
    return $('rect.pane').css('cursor', "move");
  });

}).call(this);
