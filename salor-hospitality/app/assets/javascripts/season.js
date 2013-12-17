
/* Season Object Code */
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
  if (!id || id == this.id) {
    //console.log("{ Id:\t" + this.id + "\tName: " + _name(this.name) + "\tStart:\t" +date_as_ymd(this.start) + "\tEnd: " + date_as_ymd(this.end) + "\tDuration: " + Season.diff(this.end,this.start) + "\tSide: " + this.side + " }",msg);
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
  var ret = ( 
              (season.start >= this.start && 
                season.start <= this.end) || (season.end >= this.start && season.end <= this.end) )
  return ret;
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
  //   console.log('XXXXXXXXXXXXXXX', this.id);
  while (ts <= te) {
    if ((ts >= this.start && ts <= this.end)) {
      console.log("INTERESTED", start, end, this.name, date_as_ymd(this.start), date_as_ymd(this.end), "is interested from first case in ", date_as_ymd(ts),date_as_ymd(te));
      return true;
    }
    if ((te <= this.end && te >= this.start)) {
      //console.log(this.name, this.start,this.end, "is interested from second case in ", ts,te);
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

// //the result is saved for covered seasons, on item and model level
Season.applying_seasons = function (seasons,start,end) {
  var applying = [];
  for (var i = 0; i < seasons.length; i++) {
    var s = seasons[i];
    //s.debug(6);
    
    if (s.interested(start,end)) {
      var duration = s.get_days(start,end);
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
  //console.log("Applying is",applying);
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

function season_starts_on(date,seasons) {
  var date_string = date_as_md(date);
  for (var id in seasons) {
    var season = seasons[id];
    var start = date_as_md(new Date(Date.parse(season.f)));
    if (start == date_string) {
      season.id = id;
      return season;
    }
  }
  return false;
}
function season_ends_on(date,seasons) {
  var date_string = date_as_md(date);
  for (var id in seasons) {
    var season = seasons[id];
    var end = date_as_md(new Date(Date.parse(season.t)));
    if (end == date_string) {
      season.id = id;
      return season;
    }
  }
  return false;
}
function _last_entry(array) {
//   console.log("Returning last entry",array[array.length - 1], array);
  return array[array.length - 1];
}
// function _create_season(id,season, i) {
//   var current_year = new Date().getFullYear();
//   var s       = new Season;
//   s.start     = new Date(Date.parse(season.f));
//   s.end       = new Date(Date.parse(season.t));
//   s.start.setFullYear(s.end.getFullYear() + i);
//   s.end.setFullYear(s.end.getFullYear() + i);
//   s.is_master = season.is_master;
//   s.id        = id;
//   s.name      = season.n;
//   //season.f = date_as_ymd(s.start);
//   //season.t = date_as_ymd(s.end);
//   s._object = season;
//   // s._duration = Season.diff(s.end,s.start);
//   // if (Season.diff(s.end,s.start) > 365) {
//   //   //console.log(id,season,i,s);
//   //   throw "create season wtf?";
//   // }
// //   console.log("created season");
// //   s.debug();
//   return s;
// }
function sort_seasons_func(a,b) {
  if (a.start < b.start) {
    return -1;
  } else if (a.start == b.start) {
    return 0;
  } else if (a.start > b.start) {
    return 1;
  }
}
function next_date(current_date,i) {
  if (!i)
    i = 1;
  return new Date(current_date.getTime() + (i * 24 * 3600 * 1000));
}
// function get_next_season(current_date,seasons) {
//   var current_season = false;
//   var cap = 365;
//   var x = 0;
//   while ( current_season == false ) {
//     x++;
//     if (x == cap) {
//       //console.log("get_next_season cap reached");
//       return false;
//     }
//     current_date = next_date(current_date,1);
//     current_season = season_starts_on(current_date,seasons);
//   }
//   if (current_season) {
//     var obj = _create_season(current_season.id,current_season,0);
//     obj.start = current_date;
//     return obj;
//   }
//   return false;
// }
// function normalize_season_objects(seasons) {
//     // for some reason, dates get all wonky
// //     console.log("Normalizing", seasons);
//     var last_season = null;
//     var next_season;
//     for (var i = 0; i < seasons.length; i++) {
//       var current_season = seasons[i];
//       if (!last_season) {
//         last_season = current_season;
//         continue;
//       }
// //       current_season.debug();
// //       last_season.debug();
//       if (current_season.start.getFullYear() > current_season.end.getFullYear()) {
//         // seasons cannot go back in time
//         current_season.end.setFullYear(current_season.start.getFullYear());
//         current_season.duration = Season.diff(current_season.end,current_season.start);
//       }
//       if (current_season.end < current_season.start) {
//         //ends cannot be in the past
//         while (current_season.end < current_season.start) {
//           // we cannot change the month dates, only the years
//           current_season.end.setFullYear(current_season.end.getFullYear() + 1);
//         }
//       }
//       if (current_season.start < last_season.end) {
//         //console.log("End is less than start",current_season.name,date_as_ymd(current_season.end),date_as_ymd(current_season.start));
//        // current_season.end.setFullYear(current_season.end.getFullYear() + 1);
//       }
//       current_season.duration = Season.diff(current_season.end,current_season.start);
//       seasons[i] = current_season;
//       last_season = current_season;
//     }
//     seasons.sort(sort_seasons_func);
//   return seasons;
// }

// // this is for _get("possible_seasons") BUGGY!
// function create_season_objects(seasons) {
//   if ($.isEmptyObject(seasons)) {
//     return
//   }
//   //if (_get("normalized_season_objects")) {
//     //console.log("season objects already generated");
//     //return _get("normalized_season_objects");
//   //}
//   var current_date = new Date();
//   current_date = new Date(current_date.getFullYear(),current_date.getMonth(),current_date.getDate() - 1);
//   var season_objects = [];
//   // this is a temp/in place function
//   function _find(id) {
//     for (var i = 0; i < season_objects.length; i++) { if (season_objects[i].id == id) { return season_objects[i]; } }
//   }
//   var current_season = false;
//   // first we need to walk back in time and find a season that starts on the current_date
//   var cap = 1000;
//   var x = 0;
//   while (current_season == false) {
//     x++;
//     if (x > cap) {
//       throw "create season objects cap reached";
//       break;
//     }
//     current_season = season_starts_on(current_date,seasons);
//     if (current_season && !current_season.is_master) {
// //       console.log("season is not a master", current_season);
//       current_season = false;
//     }
//     if (!current_season) {
//       current_date = next_date(current_date,-1);
// //       console.log("moving backward to",date_as_ymd(current_date));
//     }
//   }
//   current_season_object = _create_season(current_season.id,current_season,0);
//   current_season_object.start = current_date;
//   current_season_object.side = "master";
//   season_objects.push(current_season_object);
//   var last_season = null;
//   for (var i = 0; i < 600; i++) {
//     current_date = next_date(current_date,1);
//     current_season = season_starts_on(current_date,seasons);
//     if (current_season) {
//       current_season_object = _create_season(current_season.id,current_season,0);
//       current_season_object.start = current_date;
//       if (current_season_object.start.getFullYear() > current_season_object.end.getFullYear()) {
//         // seasons cannot go back in time
//         current_season_object.end.setFullYear(current_season_object.start.getFullYear());
//         current_season_object.duration = Season.diff(current_season_object.end,current_season_object.start);
//       }
//       if (current_season_object.end < current_season_object.start) {
//         //ends cannot be in the past
//         while (current_season_object.end < current_season_object.start) {
//           // we cannot change the month dates, only the years
//           current_season_object.end.setFullYear(current_season_object.end.getFullYear() + 1);
//         }
//       }
//       last_season = _last_entry(season_objects);
//       //console.log(last_season);
//       if (last_season.end > current_season_object.start) {
// //         console.log("setting season end for");
// //         last_season.debug();
//         last_season.end = next_date(current_season_object.start,-1);
//         season_objects[season_objects.length -1] = last_season;
//         current_season.side = "center";
//       } else if (last_season) {
// //         console.log(date_as_ymd(last_season.end), " !> ", date_as_ymd(current_season_object.start));
//       }
//       season_objects.push(current_season_object);
//     } else {
//       var tmp_season = season_ends_on(current_date,seasons);
//       if (tmp_season && !tmp_season.is_master) {
//         // so a season ends on this day
// //         console.log("season ends on", date_as_ymd(current_date), _find(tmp_season.id));
//         var tmp_season2 = season_starts_on(next_date(current_date,1),seasons);
//         if (!tmp_season2 && !tmp_season2.is_master ) {
// //           console.log("there is no immediate season after");
//           var tmp_prev = season_objects[season_objects.length -2];
//           var new_tmp = _create_season(tmp_prev._object.id,tmp_prev._object,0);
//           new_tmp.start = next_date(current_date,1);
//           new_tmp.side = "right";
//           season_objects.push(new_tmp);
//         } else {
// //           console.log(tmp_season2, "starts immediately after");
//         }
//       }
//     }
//   }
//   season_objects = normalize_season_objects(season_objects);
//   _set("normalized_season_objects",season_objects);
// //   for (var i = 0; i < season_objects.length; i++) {
// //     season_objects[i].debug();
// //   }
//   return season_objects;
// }


// New code:

function create_season_objects(seasons) {
  //console.log(seasons);
  var season_objects = [];
  // var current_date = new Date(current_date.getFullYear(),current_date.getMonth(),current_date.getDate() - 1);
  $.each(seasons, function (i,season) {
    var s       = new Season;
    s.start     = new Date(Date.parse(season.f));
    s.end       = new Date(Date.parse(season.t));
    s.name      = season.n;
    s.is_master = season.is_master;
    if ( s.end < s.start) {
      s.end.setFullYear(s.end.getFullYear() + 1);
    }
    s._object = season;
    s.id = season.id;
    season_objects.push(s);
  });
  
  // Now we need to copy the list to the previous year.
  $.each(season_objects, function (i, season_object) {
    var s       = new Season;
    s.start     = new Date(season_object.start);
    s.start.setFullYear( season_object.start.getFullYear() - 1);
    s.end       = new Date(season_object.end);
    s.end.setFullYear( season_object.end.getFullYear() - 1);
    s.name      = season_object.name;
    s.is_master = season_object.is_master;
    s._object = season_object._object;
    s.id = season_object.id;
    s.previous_year = true;
    season_objects.push(s);
  });
  // Now we need to copy the list to the next year.
  $.each(season_objects, function (i, season_object) {
    var s       = new Season;
    s.start     = new Date(season_object.start);
    s.start.setFullYear( season_object.start.getFullYear() + 1);
    s.end       = new Date(season_object.end);
    s.end.setFullYear( season_object.end.getFullYear() + 1);
    s.name      = season_object.name;
    s.is_master = season_object.is_master;
    s._object = season_object._object;
    s.id = season_object.id;
    s.previous_year = true;
    season_objects.push(s);
  });
  season_objects.sort(sort_seasons_func);
  // At this point, the seasons are copied to the previous year,
  // and are ordered. We now need to find seasons that contain other
  // seasons and sort them off to the left and the right.
  for (var i = 0; i < season_objects.length; i++ ) {
    var current_season_object = season_objects[i];
    for ( var j = 0; j < season_objects.length; j++ ) {
      var other_season_object = season_objects[j];
      if ( other_season_object == current_season_object) {
        // i.e. we don't need to see if one season contains itself!
        continue;
      }
      if ( current_season_object.contains(other_season_object) ) {
        // So we know that this season contains another, we need
        // to duplicate the season for the "tail" end, and then
        // resize current season to end 1 day before the inner season,
        // and resize the "tail" to one day after the inner season.
        // Then we will need to swap the current season to the tail season.
        // as it could theoretically contain yet another season. Since
        // they should all be in order, this may just work!
        var cloned_season_object = new Season();
            cloned_season_object.start     = new Date(current_season_object.start);
            cloned_season_object.end       = new Date(current_season_object.end);
            cloned_season_object.name      = current_season_object.name;
            cloned_season_object.is_master = current_season_object.is_master;
            cloned_season_object._object   = current_season_object._object;
            cloned_season_object.id        = current_season_object.id;
        // now we have the cloned season, let's set the end of
        // current_season_object to the beginning of other_season_object - 1.day
        current_season_object.end   = new Date( other_season_object.start.getTime()  - (1 * 24 * 3600 * 1000) );
        // now we set the start of cloned_season_object to the end of other_season_object + 1.day
        cloned_season_object.start  = new Date( other_season_object.end.getTime()    + (1 * 24 * 3600 * 1000) );
        // now we swap current_season for cloned season and continue;
        current_season_object = cloned_season_object;
        season_objects.push(cloned_season_object);
        continue;
      }
    }
  }
  //console.log(season_objects);
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
    //console.log("Object is: ",obj);
    var season_from = obj.start;
    var season_year = obj.start.getFullYear();
    var year_start = new Date(Date.parse("2013-01-01"));
      
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
    $('#spliced_seasons').append(season_div);
  })
}