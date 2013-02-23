function scroll_to(element, speed) {
  target_y = $(window).scrollTop();
  //current_y = $(element).offset().top;
  var elementid = $(element).attr('id');
  current_y = document.getElementById(elementid).offsetTop;
  if (settings.workstation) {
    do_scroll((current_y - target_y)*1.05, speed);
  } else {
    window.scrollTo(0, current_y);
  }
}

function scroll_for(distance, speed) {
  do_scroll(distance, speed);
}

function do_scroll(diff, speed) {
  window.scrollBy(0,diff/speed);
  newdiff = (speed-1)*diff/speed;
  scrollAnimation = setTimeout(function(){ do_scroll(newdiff, speed) }, 20);
  if(Math.abs(diff) < 5) { clearTimeout(scrollAnimation); }
}