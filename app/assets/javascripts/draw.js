var ctx; // Our canvas context
var scribe_contents = '';
var stop_scrolling = false;
var last_action_line = false;
var canvas;
var x = 0;
var y = 0;

function init_scribe(d) {
  if('ontouchstart' in window == false){
    alert('Sorry, you need a touch enabled device to use this demo');
    return;
  }

  document.addEventListener('touchmove', preventScrollingHandler, false); //Prevent scrolling

  canvas = document.createElement('canvas');
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
  ctx.lineWidth = 8;
  ctx.strokeStyle = 'darkblue';
  ctx.stroke();
  
  canvas.addEventListener("touchstart", draw_start, false); // A finger is down
  canvas.addEventListener("touchmove", draw_move, false); // The finger is moving
  canvas.addEventListener("touchcancel", draw_stop, false); // External interruption
}

function draw_start(event) {
  stop_scrolling = true;
  x = event.touches[0].pageX;
  y = event.touches[0].pageY;
  ctx.moveTo(x, y);
  ctx.lineTo(x + 2, y - 2);
  ctx.stroke();
  ctx.moveTo(x, y);
  scribe_contents += 'M ' + x + ',' + y + ' ' + 'L ' + (x+2) + ',' + (y-2) + ' ';
  last_action_line = false;
  last_x = x;
  last_y = y;
}

function draw_move(event) {
  x = event.touches[0].pageX;
  y = event.touches[0].pageY;
  if (Math.abs(last_x - x) > 5 || Math.abs(last_y - y) > 5) {
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
	alert('Drawing was interrupted.');
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
  $('#orderform').hide();
  $('#functions').hide();
  $('#functions_footer').hide();
  $('h').hide();
  $('#draw_controls').show();
  $('#draw_controls').prepend(canvas);

  scroll_to('canvas', 25);
}

function hide_canvas() {
  stop_scrolling = false;
  d = canvas.getAttribute('d');
  $('#orderform').show();
  $('#functions').show();
  $('#functions_footer').show();
  $('h').show();
  $(canvas).remove();
  $('#draw_controls').hide();

  scroll_to('#item_' + d, 25);
}

function submit_drawing() {
  hide_canvas();
  d = canvas.getAttribute('d');
  set_json(d,'scribe',scribe_contents);
}
