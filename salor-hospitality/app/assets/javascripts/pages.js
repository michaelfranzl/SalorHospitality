var ran_documentready = false;

$(function() {
  if (ran_documentready) return;
  copy_orig_corrdinates();
  
  if (page_count == 1) {
    $('#page_' + ids[0]).fadeIn(1000);
  } else {
    // kick-off self-calling slide function
    show_page(0);
  }
  ran_documentready = true;
})

function show_page(idx, last_idx) {
  var time_fadein = 1000;
  var time_display = 6000;
  
  var page = $('#page_' + page_ids[idx]);
  page.css('z-index', 100);
  page.fadeIn(time_fadein, function() {
    var last_page = $('#page_' + page_ids[last_idx]);
    last_page.hide();
    page.css('z-index', 99);
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

function copy_orig_corrdinates() {
  console.log('copying');
  $.each($('.partial'), function(i, el) {
    el = $(el);
    el.attr('left_orig', parseInt(el.css('left')));
    el.attr('top_orig', parseInt(el.css('top')));
  })
  $(window).bind('resize', function() {
    resize();
  }).trigger('resize');
  ran_copy_coordinates = true;
}

function resize() {
  var unit_height = 480;
  var unit_width = 800;
  var unit_fontsize = 85;

  var display_height = $(window).height();
  var display_width = $(window).width();
  
  var factor_height = display_height / unit_height;
  var factor_width = display_width / unit_width;
  
  var scaled_fontsize = Math.floor(100 * factor_width);
  $("body").css("font-size", scaled_fontsize + '%');
  
  var scalable_elements = $('.partial');
  scalable_elements.push($('table'));
  $.each(scalable_elements, function(i, el) {
    el = $(el);
    var el_left = el.attr('left_orig');
    var el_top = el.attr('top_orig');
    scaled_left = Math.floor(el_left * factor_width);
    scaled_top = Math.floor(el_top * factor_height);
    el.css('left', scaled_left + 'px');
    el.css('top', scaled_top + 'px');
  })
}