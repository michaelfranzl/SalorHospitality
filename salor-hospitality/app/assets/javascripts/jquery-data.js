function _get(value, el) {
  if (el) {
    return $.data(el[0], value);
  } else {
    return $.data(document.body, value);
  }
}

function _set(name, value, el) {
  if (el) {
    return $.data(el[0], name, value);
  } else {
    return $.data(document.body, name, value);
  } 
}