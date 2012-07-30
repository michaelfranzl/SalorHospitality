/* Season Object Code */
var Season = function (s,e) {
  var start = s.split(',')
  for (var i = 0; i < start.length;i++) { start[i] = parseInt(start[i]); }
  this.start = new Date();
  this.start.setMonth(start[1] - 1);
  this.start.setDate(start[0]);
  var end = e.split(',');
  for (var i = 0; i < end.length;i++) { end[i] = parseInt(end[i]); }
  this.end = new Date();
  this.end.setMonth(end[1] - 1);
  this.end.setDate(end[0]);
}

Season.prototype.get_days = function (start,end) {
  if (this.interested(start,end)) {
    var days = 1;
    var cdate = new Date(this.start.getFullYear(),this.start.getMonth(),this.start.getDate() + 1);
    if (cdate < start) {
      while (cdate < start) {
        cdate = new Date(cdate.getFullYear(),cdate.getMonth(),cdate.getDate() + 1);
      }
    }
    while (cdate <= this.end && cdate <= end) {
      days++;
      cdate = new Date(cdate.getFullYear(),cdate.getMonth(),cdate.getDate() + 1);
    }
    return days;
  } else {
    return 0;
  }
}

Season.prototype.get_total = function (start,end,cost_per_day) {
  var days = this.get_days(start,end);
  return days * cost_per_day;
}

Season.prototype.intersects_with = function (season) {
  return ( (season.start >= this.start && season.start <= this.end) || (season.end >= this.start && season.end <= this.end) )
}

Season.prototype.contains = function (season) {
  return ( (season.start >= this.start && season.start <= this.end) && (season.end >= this.start && season.end <= this.end) )
}

Season.prototype.interested = function (start,end) {
  var ts = new Date(start);
  var te = new Date(end);
  while (ts <= te) {
    if ((ts >= this.start && ts <= this.end) || (te <= this.end && te >= this.start)) {
      return true;
    }
    ts = new Date(ts.getFullYear(),ts.getMonth(),ts.getDate() + 1);
    te = new Date(te.getFullYear(),te.getMonth(),te.getDate() - 1);
  }
  return false;
}

Season.applying_seasons = function (seasons,b_start,b_end) {
  var new_seasons = [];
  for (var i = 0; i < seasons.length; i++) {
    var s = seasons[i];
    if (s.interested(b_start,b_end)) {
      var ns = {start: date_as_ymd(s.start), end: date_as_ymd(s.end),name: s.name,id: parseInt(s.id), duration: s.get_days(b_start,b_end)};
      new_seasons.push(ns);
    }
  }
  return new_seasons;
}
Season.md = function (date) {
  return (date.getMonth() + 1) + "," + date.getDate();
}
Season.merge = function (seasons,new_seasons) {
  for (var i = 0; i < new_seasons.length; i++) {
    seasons.push(new_seasons[i]);
  }
}
Season.splice = function (season1,season2) {
  var new_seasons = [];
  var new_end_date = season1.start;
  while (new_end_date < season2.start) {
    new_end_date = new Date(new_end_date.getFullYear(),new_end_date.getMonth(),new_end_date.getDate() + 1);
  }
  new_end_date = new Date(new_end_date.getFullYear(),new_end_date.getMonth(),new_end_date.getDate() - 2);
  var new_left_side = new Season("00,00","00,00");
  new_left_side.id = season1.id;
  new_left_side.side = 'left';
  new_left_side.name = season1.name;
  new_left_side.start = season1.start;
  new_left_side.end = new_end_date;
  new_seasons.push(new_left_side);
  new_seasons.push(season2);
  var new_start_date = new Date(season2.end.getFullYear(),season2.end.getMonth(),season2.end.getDate() + 1);
  if (new_start_date < season1.end) {
    var new_right_side = new Season("00,00","00,00");
    new_right_side.id = season1.id;
    new_right_side.side = 'right';
    new_right_side.name = season1.name;
    new_right_side.start = new_start_date;
    new_right_side.end = season1.end;
    new_seasons.push(new_right_side);
  }
  return new_seasons;
}

function create_season_objects(seasons) {
  var new_seasons = [];
  $.each(seasons, function (id,season) {
    var s       =  new Season("00,00","00,00");
    s.start     = new Date(Date.parse(season.f));
    s.end       = new Date(Date.parse(season.t));
    if (s.end < s.start) {
      s.end.setFullYear(s.start.getFullYear() + 1);
    }
    s.id        = id;
    s.name      = season.n;
    new_seasons.push(s);
  });
  new_seasons.sort(function (a,b) {
    if (a.start < b.start) {
      return -1;
    } else if (a.start == b.start) {
      return 0;
    } else if (a.start > b.start) {
      return 1;
    }
  });
  var really_new_seasons = [];
  for (var i = 0; i < new_seasons.length; i++) {
    var s1 = new_seasons[i];
    var s2 = new_seasons[i+1];
    if (s1 && s2 && s1.intersects_with(s2)) {
      Season.merge(really_new_seasons,Season.splice(s1,s2));
    } else if (s1 && s2 && s2.intersects_with(s1)) {
      Season.merge(really_new_seasons,Season.splice(s2,s1));
    } else {
      really_new_seasons.push(s1);
    }
  }
  var tmp = {};
  for (i=0;i<really_new_seasons.length; i++) {
    var s = really_new_seasons[i];
    tmp[s.name + s.start + s.end] = s;
  }
  really_new_seasons = [];
  for (key in tmp)
    really_new_seasons.push(tmp[key]);
  return really_new_seasons;
}