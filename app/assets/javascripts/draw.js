var ctx; // Our canvas context
var scribe_contents = '';
var stop_scrolling = false;
var canvas;

function init_scribe(d) {
  if('ontouchstart' in window == false){
    alert('Sorry, you need a touch enabled device to use this demo');
    return;
  }

  document.addEventListener('touchmove', preventScrollingHandler, false); //Prevent scrolling

  canvas = document.createElement('canvas');
  canvas.setAttribute('d', d);

  canvas.width  = 470; //window.innerWidth;
  canvas.height = 240; //window.innerHeight - 150;

  show_canvas(canvas);
  
  ctx = canvas.getContext('2d');
  ctx.strokeStyle = "rgba(255,0,0,1)";
  ctx.lineWidth = 2;
  ctx.lineCap = 'round';
  
  canvas.addEventListener("touchstart", draw_start, false); // A finger is down
  canvas.addEventListener("touchmove", draw_move, false); // The finger is moving
  canvas.addEventListener("touchcancel", draw_stop, false); // External interruption
}

function draw_start(event) {
  var x = event.touches[0].pageX;
  var y = event.touches[0].pageY;
  ctx.moveTo(x, y);
  scribe_contents += 'M ' + x + ',' + y + ' ';
}

function draw_move(event) {
  var x = event.touches[0].pageX;
  var y = event.touches[0].pageY;
  ctx.lineTo(x,y);
  ctx.stroke();
  scribe_contents += 'L ' + x + ',' + y + ' ';
}

function draw_stop(event) {
	alert('Drawing was interrupted.');
}

function preventScrollingHandler(event) {
  // Flags this event as handled. Prevents the UA from handling it at window level
  if ( stop_scrolling ) {
   event.preventDefault();
  }
}

function show_canvas(canvas) {
  $('#orderform').hide();
  $('#functions').hide();
  //$('#tables').hide();
  //$('#rooms').hide();
  $('#functions_footer').hide();
  //$('#invoices').hide();
  $('#draw_controls').show();
  $('#main').prepend(canvas);
}

function hide_canvas() {
  $('#orderform').show();
  $('#functions').show();
  //$('#tables').show();
  //$('#rooms').show();
  $('#functions_footer').show();
  //$('#invoices').show();
  $('#draw_controls').hide();
  $(canvas).remove();
}

function submit_drawing() {
  hide_canvas();
  d = canvas.getAttribute('d');
  set_json(d,'scribe',scribe_contents);
  //$.ajax({
  //  url: '/items',
  //  data: {drawing:drawing, item_id:canvas.getAttribute('d')}
  //});
}
