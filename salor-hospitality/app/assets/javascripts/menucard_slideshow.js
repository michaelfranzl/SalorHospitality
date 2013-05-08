var ran_documentready_menucard_slideshow = false;

$(function() {
  if (ran_documentready_menucard_slideshow) return;
  
  if (page_count == 1) {
    $('#page_' + page_ids[0]).fadeIn(1000);
  } else {
    // kick-off self-calling slide function
    show_page(0, page_count - 1);
  }
  ran_documentready_menucard_slideshow = true;
})

function show_page(idx, last_idx) {
  var time_fadein = 1000;
  var time_display = 6000;
  
  var page = $('#page_' + page_ids[idx]);
  page.css('z-index', 100);
  page.fadeIn(time_fadein, function() {
    var last_page = $('#page_' + page_ids[last_idx]);
    last_page.fadeOut(time_fadein, function() {
      page.css('z-index', 99);
      last_page.hide();
    });
    
  });
  
  if (idx == (page_count - 1)) {
    //wrap to first page
    next_idx = 0
  } else {
    next_idx = idx + 1;
  }
  
  setTimeout(function(){
    show_page(next_idx, idx);
  }, time_display);
}