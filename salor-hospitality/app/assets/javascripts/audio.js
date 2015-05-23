var audio_enabled_count = 0;

function enable_audio() {
  if (audio_enabled_count < 2) {
    try {
      document.getElementById('audio').load();
    }
    
    catch (err) {
      // not supported by salor-bin
    }
    debug('enable_audio called ' + audio_enabled_count);
    audio_enabled_count += 1;
  }
}

$(function(){
  enable_audio();

  jQuery.ajaxSetup({
      'beforeSend': function(xhr) {
          //xhr.setRequestHeader("Accept", "text/javascript");
          xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      }
  })
  
  $(window).keydown(function(e){
    for (var key in _key_codes) {
      if (e.keyCode == _key_codes[key]) {
        _keys_down[key] = true;
      }
    }
  });
  
  $(window).keyup(function(e){
    for (var key in _key_codes) {
      if (e.keyCode == _key_codes[key]) {
        _keys_down[key] = false;
      }
    }
  });
})

function alert_audio() {
  try {
    document.getElementById('audio').play();
  }
  
  catch(err) {
    // not supported by salor-bin
  }
}