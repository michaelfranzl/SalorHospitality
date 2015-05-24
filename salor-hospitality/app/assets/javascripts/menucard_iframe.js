var ran_documentready_menucard_iframe = false;

$(function() {
  if (ran_documentready_menucard_iframe == true) return;
  
  $(window).bind('resize', function() {
    var display_height = $(window).height();
    var display_width = $(window).width();
    //console.log('inside menucard_iframe documentready');
    page_resize(display_width, display_height);
  }).trigger('resize');
  
  ran_documentready_menucard_iframe = true;
})