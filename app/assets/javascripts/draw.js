var ctx; // Our canvas context
var drawing = '';
var stop_scrolling = false;

function init_draw(d) {
  if('ontouchstart' in window == false){
    alert('Sorry, you need a touch enabled device to use this demo');
    return;
  }

  document.addEventListener('touchmove', preventScrollingHandler, false); //Prevent scrolling
  //canvas = $('#draw1');
  var canvas = document.createElement('canvas');

  canvas.width  = window.innerWidth;
  canvas.height = window.innerHeight - 150;
  $('#main').prepend(canvas);
  
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
  drawing += 'M ' + x + ',' + y + ' ';
}

function draw_move(event) {
  var x = event.touches[0].pageX;
  var y = event.touches[0].pageY;
  ctx.lineTo(x,y);
  ctx.stroke();
  drawing += 'L ' + x + ',' + y + ' ';
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

function submit_drawing() {
  $.ajax({
    url: '/items',
    data: {drawing:drawing}
  });
}
