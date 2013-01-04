
/* Season Object Code */
var Season = function () {};
Season.prototype.debug = function (id,msg) {
  if (!id || id == this.id) {
    console.log("{ Id: " + this.id + " Name: " + this.name + " Start: " +date_as_ymd(this.start) + " End: " + date_as_ymd(this.end) + " duration: " + Season.diff(this.end,this.start) + " Side: " + this.side + " }",msg);
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
  var ret = ( (season.start >= this.start && season.start <= this.end) || (season.end >= this.start && season.end <= this.end) )
  return ret;
}

Season.prototype.contains = function (season) {
  return ( (season.start >= this.start && season.start <= this.end) && (season.end >= this.start && season.end <= this.end) )
}

Season.prototype.interested = function (start,end) {
  var ts = new Date(start);
  var te = new Date(end);
  //   console.log('XXXXXXXXXXXXXXX', this.id);
  while (ts <= te) {
    if ((ts >= this.start && ts <= this.end)) {
      console.log(this.name, date_as_ymd(this.start),date_as_ymd(this.end), "is interested from first case in ", date_as_ymd(ts),date_as_ymd(te));
      return true;
    }
    if ((te <= this.end && te >= this.start)) {
      console.log(this.name, this.start,this.end, "is interested from second case in ", ts,te);
      return true;
    }
    //     console.log('narrowing');
    ts = new Date(ts.getFullYear(),ts.getMonth(),ts.getDate() + 1);
    te = new Date(te.getFullYear(),te.getMonth(),te.getDate() - 1);
  }
  return false;
}
Season.merge = function (seasons,new_seasons) {
  for (var i = 0; i < new_seasons.length; i++) {
    seasons.push(new_seasons[i]);
  }
}

//the result is saved for covered seasons, on item and model level
Season.applying_seasons = function (seasons,start,end) {
  var applying = [];
  for (var i = 0; i < seasons.length; i++) {
    var s = seasons[i];
    s.debug(6);
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
      var already_in_array = false;
      
      if (already_in_array == false) {
        applying.push(ns);
      }
    }
  }
  console.log("Applying is",applying);
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
Season.prototype.intersects_with = function (season) {

  var ret = ( (season.start >= this.start && season.start <= this.end) || 
              (season.end >= this.start && season.end <= this.end) ||
              (this.start >= season.start && this.start <= season.end) ||
              (this.end >= season.start && this.end <= season.end) ||
              (this.start < season.start && this.end > season.end)
            )

  return ret;
}
Date.prototype.year = function () {
  return this.getFullYear();
}
function _create_season(id,season, i) {
  var current_year = new Date().getFullYear();
  var s       = new Season;
  s.start     = new Date(Date.parse(season.f));
  s.end       = new Date(Date.parse(season.t));
  s.start.setFullYear(current_year + i);
  s.end.setFullYear(s.end.getFullYear() + i);

  if (s.end < s.start) {
    s.end.setFullYear(s.end.getFullYear() + 1);
  }
  if (s.start > s.end) {
    s.start.setFullYear(s.start.getFullYear() - 1);
  }
  s.id        = id;
  s.name      = season.n;
  //season.f = date_as_ymd(s.start);
  //season.t = date_as_ymd(s.end);
  s._object = season;
  s._duration = Season.diff(s.end,s.start);

  if (Season.diff(s.end,s.start) > 365) {
    console.log(id,season,i,s);
    throw "What the fuck?";
  }
  return s;
}
function _insert_after(needle,haystack,append_this) {
  var new_haystack = [];
  for (var i = 0; i < haystack.length; i++) {
    new_haystack.push(haystack[i]);
    if (needle == i) {
      new_haystack.push(append_this);
    }
  }
  return new_haystack;
}
function _insert_before(needle,haystack,append_this) {
  var new_haystack = [];
  for (var i = 0; i < haystack.length; i++) {
    if (needle == i) {
      new_haystack.push(append_this);
    }
    new_haystack.push(haystack[i]);
  }
  return new_haystack;
}
function _create_seasons(id,season,append_to) {
  var i = -1;
  while (i <=1) {
    var s = _create_season(id,season,i);
    append_to.push(s);
    i++;
  }
}
function create_season_objects(seasons) {
  var season_objects = [];
  $.each(seasons, function (id,season) {
    _create_seasons(id,season,season_objects);
  });
  // now we need to resize each season so that it doesn't overlap on the right or left side
  var right_sides = [];
  for (var i = 0; i < season_objects.length; i++) {
    var current_season = season_objects[i];
    var right_season = null;
    // now we need to descend into the objects and find the overlaps
    for (var j = 0; j < season_objects.length; j++) {
      var other_season = season_objects[j];
      
      if (current_season.id == other_season.id) {
        continue;
      } else {
      
        // we need to know IF they over lap
        if (current_season.intersects_with(other_season)) {
          // now we need to know the type of the intersection
          var has_left_overlap = false;
          var has_right_overlap = false;
          var new_end_date = false;
          if (current_season.start < other_season.start) {
            has_left_overlap = Season.diff(other_season.start,current_season.start);
          } // end if (current_season.start < other_season.start) 
          if (current_season.end > other_season.end) {
            has_right_overlap = Season.diff(current_season.end,other_season.end);
          } // if (current_season.end > other_season.end)
          // When we have left side days, we need to shrink
          if (has_left_overlap && has_left_overlap > 0) {
            var days_to_sub = has_left_overlap;
            var new_end_date = new Date(current_season.start.getFullYear(),current_season.start.getMonth(),current_season.start.getDate() + has_left_overlap - 1);
          }
          if (has_right_overlap && has_right_overlap > 0) {
            // in this case, we need to create a new one
            right_season = _create_season(current_season.id,current_season._object,0);
            right_season.start = new Date( other_season.end.getFullYear(), other_season.end.getMonth(), other_season.end.getDate() + 1 );
            right_season.end = new Date(current_season.end.getFullYear(), current_season.end.getMonth(),right_season.start.getDate() + has_right_overlap);
            right_season.side = "right";
            
            console.log("creating right sided");
            right_sides.push(right_season);
          }
          if (has_left_overlap && has_left_overlap > 0) {
            current_season.end = new_end_date;
            current_season.side = "left";
          }
        } else {
  //         console.log("No Intersection");
        }
      
      } // end if (current_season.id == other_season.id) 
        
    } // end for (var j = 0; j < season_objects.length; j++) 
  } // end  for (var i = 0; i < season_objects.length; i++) 
  Season.merge(season_objects,right_sides);
  console.log("Right Sides",right_sides);
  for (var x = 0; x < right_sides.lenght; x++) {
    right_sides[x].debug();
  }
  console.log(season_objects);
  season_objects.sort(function (a,b) {
    if (a.start < b.start) {
      return -1;
    } else if (a.start == b.start) {
      return 0;
    } else if (a.start > b.start) {
      return 1;
    }
  });
  return season_objects;
}

























function render_season_illustration() {
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