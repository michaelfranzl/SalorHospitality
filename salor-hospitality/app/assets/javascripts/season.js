
/* Season Object Code */
var Season = function () {};

Season.prototype.get_days = function (start,end) {
  if (this.interested(start,end)) {
    var days = 0;
    var cdate = new Date(this.start.getFullYear(),this.start.getMonth(),this.start.getDate());
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
//   console.log('XXXXXXXXXXXXXXX', this.id);
  while (ts <= te) {
    if ((ts >= this.start && ts <= this.end) || (te <= this.end && te >= this.start)) {
      return true;
    }
//     console.log('narrowing');
    ts = new Date(ts.getFullYear(),ts.getMonth(),ts.getDate() + 1);
    te = new Date(te.getFullYear(),te.getMonth(),te.getDate() - 1);
  }
  return false;
}

//the result is saved for covered seasons, on item and model level
Season.applying_seasons = function (seasons,start,end) {
  var applying = [];
  for (var i = 0; i < seasons.length; i++) {
    var s = seasons[i];
    if (s.interested(start,end)) {
//       console.log('interested in season', s.id);
      var duration = s.get_days(start,end);
      if (s.start > start) {
        var start_date = s.start;
      } else {
        var start_date = start;
      }

      var end_date = (s.end < end) ? s.end : end;
      
      var ns = {start: date_as_ymd(start_date), end: date_as_ymd(end_date),name: s.name,id: parseInt(s.id), duration:duration};
      applying.push(ns);
    }
  }
  var new_applying = [];
  // let's make sure they don't overlap completely, as in the same dates
  if (applying.length == 2) {
//     console.log("checking for an eqaulity");
    var s1 = applying[0];
    var s2 = applying[1];
    if (s2.start == s1.start && s2.end == s1.end) {
      applying = [s2];
    }
    
  }
  return applying;
}

Season.merge = function (seasons,new_seasons) {
  for (var i = 0; i < new_seasons.length; i++) {
    seasons.push(new_seasons[i]);
  }
}

Season.splice = function (season1,season2) {
  var season_array = [];
  var new_end_date = new Date(season1.start);
  while (new_end_date < season2.start) {
    new_end_date.setDate(new_end_date.getDate() + 1);
  }
  new_end_date.setDate(new_end_date.getDate() - 1);
  
  var new_left_side = new Season;
  new_left_side.id = season1.id;
  new_left_side.side = 'left';
  new_left_side.name = season1.name;
  new_left_side.start = season1.start;
  new_left_side.end = new_end_date;
  season_array.push(new_left_side);
  season_array.push(season2);
  
  var new_start_date = new Date(season2.end);
  new_start_date.setDate(new_start_date.getDate() + 1);
  if (season2.end < season1.end) {
    var new_right_side = new Season;
    new_right_side.id = season1.id;
    new_right_side.side = 'right';
    new_right_side.name = season1.name;
    new_right_side.start = new_start_date;
    new_right_side.end = season1.end;
    season_array.push(new_right_side);
  }
  return season_array;
}



function _create_seasons(id,season,append_to) {
  var i = -1;
  while (i <=1) {
    var s       = new Season;
    s.start     = new Date(Date.parse(season.f));
    s.end       = new Date(Date.parse(season.t));
    s.start.setFullYear(s.start.getFullYear() + i);
    s.end.setFullYear(s.end.getFullYear() + i);
    if (s.end < s.start) {
      s.end.setFullYear(s.start.getFullYear() + 1);
    }
    s.id        = id;
    s.name      = season.n;
    append_to.push(s);
    i++;
  }
}

function create_season_objects(seasons) {
  var new_seasons = [];
  $.each(seasons, function (id,season) {
    _create_seasons(id,season,new_seasons);
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
//   console.log("At this point, new seasons are: ");
  for (var i = 0; i < new_seasons.length; i++) {
    var s = new_seasons[i];
//     console.log(s.name, date_as_ymd(s.start), date_as_ymd(s.end));
  }
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
//   console.log("At this point, really new seasons are: ");
//   for (var i = 0; i < new_seasons.length; i++) {
//     var s = really_new_seasons[i];
//     console.log("(" + s.id + ")" + s.name, date_as_ymd(s.start), date_as_ymd(s.end));
//   }
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

function render_season_illustration() {
  return;
  var year_seconds = 31536000;
  var i = -1;
  
  while (i <=1) {
    $.each(resources.sn, function(k,v) {
      var season_from = new Date(Date.parse(v.f));
      var season_year = parseInt(season_from.getFullYear()) + i;
      var year_start = new Date(Date.parse(season_year+"-01-01"));
      
      var left_percent = (season_from - year_start) / 1000 / year_seconds * 100;
      var width_percent = v.d / year_seconds * 100;
      var season_div = create_dom_element('div',{},v.n);
      season_div.css('width', width_percent + '%');
      season_div.css('left', left_percent + '%');
      var red = parseInt(v.c.substring(1,3), 16);
      var green = parseInt(v.c.substring(3,5), 16);
      var blue = parseInt(v.c.substring(5,7), 16);
      season_div.css('background-color', 'rgba('+red+','+green+','+blue+',0.3)');
      season_div.addClass('season');
      
      $('#nested_seasons').append(season_div);
    })
    i++;
  }
  
  var spliced_seasons = create_season_objects(resources.sn);
  $.each(spliced_seasons, function(i, obj) {
    var season_from = obj.start;
    var season_year = obj.start.getFullYear();
    var year_start = new Date(Date.parse("2013-01-01"));
      
    var left_percent = (obj.start.getTime() - year_start) / 1000 / year_seconds * 100;
    var season_duration = obj.end - obj.start;
    var width_percent = season_duration / 1000 / year_seconds * 100;
    
    var season_div = create_dom_element('div',{},obj.name + ' | ' +  obj.side +' | ' + season_year);
    season_div.css('width', width_percent + '%');
    season_div.css('left', left_percent + '%');
    var red = parseInt(resources.sn[obj.id].c.substring(1,3), 16);
    var green = parseInt(resources.sn[obj.id].c.substring(3,5), 16);
    var blue = parseInt(resources.sn[obj.id].c.substring(5,7), 16);
    season_div.css('background-color', 'rgba('+red+','+green+','+blue+',0.3)');
    season_div.addClass('season');
    $('#spliced_seasons').append(season_div);
  })
}