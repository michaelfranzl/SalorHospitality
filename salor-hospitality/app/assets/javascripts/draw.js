/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

var ctx; // canvas context
var canvas;
var scribe_contents = '';
var stop_scrolling = false;
var last_action_line = false;
var x = 0;
var y = 0;
var touchdevice = 'ontouchstart' in window;

function init_scribe(d) {
  canvas = document.createElement('canvas');
  //canvas.setAttribute('id', 'scribearea');
  canvas.setAttribute('d', d);

  canvas.width  = 470; //window.innerWidth;
  canvas.height = 250; //window.innerHeight - 150;

  show_canvas(canvas);
  
  ctx = canvas.getContext('2d');

  ctx.beginPath();
  ctx.rect(0, 0, 470, 50);
  ctx.fillStyle = '#000000';
  ctx.fill();

  ctx.beginPath();
  ctx.lineWidth = 6;
  ctx.strokeStyle = 'darkblue';
  ctx.lineCap = 'round';
  ctx.lineJoin = 'round';

  if (touchdevice) {
    document.addEventListener('touchmove', preventScrollingHandler, false);
    canvas.addEventListener("touchstart", draw_start, false); // A finger is down
    canvas.addEventListener("touchmove", draw_move, false); // The finger is moving
    canvas.addEventListener("touchcancel", draw_stop, false); // External interruption
  } else {
    canvas.addEventListener("mousedown", draw_start, false);
    canvas.addEventListener("mouseup", draw_stop, false);
  }
}

function draw_start(event) {
  canvas.addEventListener("mousemove", draw_move, false);
  stop_scrolling = true;
  if (touchdevice) {
    x = event.touches[0].pageX;
    y = event.touches[0].pageY;
  } else {
    x = event.x;
    y = event.y;
  }

  ctx.moveTo(x, y);
  ctx.lineTo(x, y-1);
  ctx.lineTo(x+1, y+1);
  ctx.lineTo(x-1, y+1);
  ctx.lineTo(x, y);
  ctx.stroke();
  scribe_contents += 'M ' + x + ',' + y + ' ' + 'L ' + (x) + ',' + (y-1) + ' ' + 'L ' + (x+1) + ',' + (y+1) + ' ' + 'L ' + (x-1) + ',' + (y+1) + ' ' + 'L ' + (x) + ',' + (y) + ' ';
  last_action_line = false;
  last_x = x;
  last_y = y;
}

function draw_move(event) {
  if (touchdevice) {
    x = event.touches[0].pageX;
    y = event.touches[0].pageY;
  } else {
    x = event.x;
    y = event.y;
  }
  if (Math.abs(last_x - x) > 3 || Math.abs(last_y - y) > 3) {
    ctx.lineTo(x, y);
    ctx.stroke();
    if (last_action_line == true) {
      scribe_contents += x + ',' + y + ' ';
    } else {
      scribe_contents += 'L ' + x + ',' + y + ' ';
    }
    last_action_line = true;
    last_x = x;
    last_y = y;
  }
}

function draw_stop(event) {
  canvas.removeEventListener("mousemove", draw_move, false);
}

function preventScrollingHandler(event) {
  if ( stop_scrolling ) {
   event.preventDefault(); // Flags this event as handled. Prevents the UA from handling it at window level
  }
}

function show_canvas(canvas) {
  d = canvas.getAttribute('d');
  $('#item_configuration_' + d).hide();
  scribe_contents = '';
  if (settings.mobile) {
    $('#orderform').hide();
    $('#functions').hide();
    $('#functions_footer').hide();
    $('h2').hide();
  }
  window.scrollTo(0,0);
  $('#draw_controls').show();
  $('#draw_controls').prepend(canvas);
}

function hide_canvas() {
  stop_scrolling = false;
  d = canvas.getAttribute('d');
  if (settings.mobile) {
    $('#orderform').show();
    $('#functions').show();
    $('#functions_footer').show();
    $('h2').show();
  }
  $(canvas).remove();
  $('#draw_controls').hide();
  setTimeout(function(){scroll_to('#item_' + d, 25);}, 100); // timeout is needed for iPod 3rd Generation
}

function submit_drawing() {
  hide_canvas();
  d = canvas.getAttribute('d');
  set_json('order', d, 'scribe', scribe_contents);
  $('#scribe_'+d).html('ABC');
}


function scribe_image(object) {
  var path;
  if (object.h == true) {
    path = "<img src='/items/" + object.id + ".svg'>";
  } else {
    path = '';
  }
  return path;
}