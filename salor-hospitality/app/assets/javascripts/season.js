var Season = function () {};

Season.prototype.debug = function (id,msg) {
  function _name(str) {
    var num = 10;
    var new_str = str.substring(0,num);
    if (new_str.length < num) {
      while (new_str.length < num) {
        new_str += ".";
      }
    }
    return new_str;
  }
}

Season.diff = function (date_1,date_2) {
  var t1 = date_1.getTime();
  var t2 = date_2.getTime();
  
  return parseInt( (t1-t2) / (24 * 3600 * 1000) );
}

Season.list = function (name, id) {
  var seasons = _get("possible_seasons");
  for (var i = 0; i < seasons.length; i++) {
    var s  = seasons[i];
    if (s.name.indexOf(name) != -1) {
      s.debug();
    }
  }
}

Season.prototype.get_days = function (start,end) {
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
  return days - 1;
}


Season.prototype.contains = function (season) {
  return ( 
    (season.start >= this.start && season.start <= this.end) && 
    (season.end >= this.start && season.end <= this.end) 
  );
}

Season.prototype.interested = function (start,end) {
  var ts = new Date(start);
  var te = new Date(end);
  while (ts <= te) {
    if (ts >= this.start && ts <= this.end) {
      return true;
    }
    if (te >= this.start && te <= this.end) {
      return true;
    }
    ts = new Date(ts.getFullYear(),ts.getMonth(),ts.getDate() + 1);
    te = new Date(te.getFullYear(),te.getMonth(),te.getDate() - 1);
  }
  return false;
}

// the result is saved for covered seasons, on item and model level
Season.applying_seasons = function (seasons,start,end) {
  start.setHours(0);
  end.setHours(0);
  var applying = [];
  for (var i = 0; i < seasons.length; i++) {
    var s = seasons[i];

    if (s.interested(start,end)) {
      var duration = s.get_days(start,end);
      if (duration > 0) {
        // do not display a season with zero duration
        
        if (s.start > start) {
          var start_date = s.start;
        } else {
          var start_date = start;
        }
        
        var end_date = (s.end < end) ? s.end : end;
        
        var ns = {
          start: date_as_ymd(start_date),
          end: date_as_ymd(end_date),
          name: s.name,
          id: parseInt(s.id),
          duration:duration
        };
        applying.push(ns);
      }
    }
  }
  return applying;
}

function create_season_objects(seasons) {
  var season_objects = [];

  // copy the backend-defined seasons one year into the past and into the future
  var year_offset = -1;
  while (year_offset <= 1 ) {
    $.each(seasons, function (i,season) {
      var s       = new Season;
      s.start     = new Date(Date.parse(season.f));
      s.end       = new Date(Date.parse(season.t));
      s.name      = season.n;
      if ( s.end < s.start) {
        s.end.setFullYear(s.end.getFullYear() + 1);
      }
      s.start.setFullYear( s.start.getFullYear() + year_offset);
      s.end.setFullYear( s.end.getFullYear() + year_offset);
      s._object = season;
      s.id = season.id;
      season_objects.push(s);
    });
    year_offset += 1;
  }
  //render_season_illustration("#nested_seasons", season_objects);
  
  // save all boundary dates into an array of objects
  var boundary_array = [];
  $.each(season_objects, function(idx, season) {
    boundary_array.push({
      date: season.start,
      type: 'start',
      season_id: season.id,
    });
    boundary_array.push({
      date: season.end,
      type: 'end',
      season_id: season.id,
    });
  });
  
  // sort the boundary array by date
  boundary_array.sort(function(b1, b2) {
    if (b1.date > b2.date) return 1;
    if (b1.date < b2.date) return -1;
    if (b1.date == b2.date) return 0;
  });
  
  // create spliced seasons from the boundary array
  var season_breadcrumb = [];
  var spliced_seasons = [];
  for(var i = 0; i < boundary_array.length - 1; i++) {
    var b1 = boundary_array[i];
    var b2 = boundary_array[i+1];
    
    if (boundary_array[i].type == "start" && boundary_array[i+1].type == "end") {
      // this is a regular (non-nested) season
      s = new Season;
      s.start = b1.date;
      s.end = new Date(b2.date.getTime());
      s.id = b1.season_id;
      s.name = resources.sn[b1.season_id].n;
      spliced_seasons.push(s);
      
    } else if (boundary_array[i].type == "start" && boundary_array[i+1].type == "start") {
      // create a season until next season starts
      s = new Season;
      s.start = b1.date;
      s.end = new Date(b2.date.getTime());
      s.id = b1.season_id;
      s.name = resources.sn[b1.season_id].n;
      spliced_seasons.push(s);
      // remember last season to which we have to go back
      season_breadcrumb.push(b1.season_id);
      
    } else if (boundary_array[i].type == "end" && boundary_array[i+1].type == "end") {
      var last_season_id = season_breadcrumb[season_breadcrumb.length - 1];
      if (typeof last_season_id != "undefined") {
        s = new Season;
        s.start = b1.date;
        s.end = new Date(b2.date.getTime());
        s.id = last_season_id;
        s.name = resources.sn[last_season_id].n;
        spliced_seasons.push(s);
        season_breadcrumb.pop();
      }
      
    } else if (boundary_array[i].type == "end" && boundary_array[i+1].type == "start") {
      var last_season_id = season_breadcrumb[season_breadcrumb.length - 1];
      if (typeof last_season_id != "undefined") {
        s = new Season;
        s.start = b1.date;
        s.end = new Date(b2.date.getTime());
        s.id = last_season_id;
        s.name = resources.sn[last_season_id].n;
        spliced_seasons.push(s);
      }
    }
  }
  render_season_illustration("#spliced_seasons", spliced_seasons);
  return spliced_seasons;
}

function render_season_illustration(target, seasons) {
  var year_seconds = 31536000;
  $(target).html("");
  $.each(seasons, function(i, obj) {
    var season_from = obj.start;
    var season_year = obj.start.getFullYear();
    var current_year = new Date().getFullYear();
    var year_start = new Date(Date.parse(current_year + "-01-01"));
      
    var left_percent = (obj.start.getTime() - year_start) / 1000 / year_seconds * 100;
    var season_duration = Season.diff(obj.end,obj.start);
    var width_percent = season_duration * 24 * 3600 / year_seconds * 100;
    
    var season_div = create_dom_element('div',{},obj.name);
    season_div.css('width', width_percent + '%');
    season_div.css('left', left_percent + '%');
    var red = parseInt(resources.sn[obj.id].c.substring(1,3), 16);
    var green = parseInt(resources.sn[obj.id].c.substring(3,5), 16);
    var blue = parseInt(resources.sn[obj.id].c.substring(5,7), 16);
    season_div.css('background-color', 'rgba('+red+','+green+','+blue+',0.3)');
    season_div.addClass('season');
    $(target).append(season_div);
  })
}