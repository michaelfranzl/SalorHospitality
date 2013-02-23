function date_as_ymd(date) {
  var ret = date.getFullYear() + '-' + (date.getMonth()+1) + '-' + date.getDate();
  return ret;
}

function date_as_md(date) {
  var ret = ( date.getMonth() + 1) + '-' + date.getDate();
  return ret;
}

function get_date(str) {
  return new Date(Date.parse(str));
}

function days_between_dates(from, to) {
  var days = Math.floor((Date.parse(to) - Date.parse(from)) / 86400000);
  if (days == 0)
    days = 0
  return days;
}