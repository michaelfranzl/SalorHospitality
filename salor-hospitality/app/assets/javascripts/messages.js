

sh.fn.messages.displayMessage = function(type, msg, id) {
  var statusbar = $("#messages");
  if ($("#" + id).length > 0) {
    $("#" + id).html(msg);
  } else {
    var statusmessage = $("<div></div>");
    statusmessage.html(msg);
    statusmessage.addClass("statusmessage");
    if (type == "notice") {
      statusmessage.addClass("message_notice");
    } else if (type == "alert") {
      statusmessage.addClass("message_alert");
    }
    if (typeof id == "undefined") {
      id = "notice_" + Math.floor((Math.random()*100000)+1);
    }
    statusmessage.attr("id", id);
    statusbar.prepend(statusmessage);
    setTimeout(function() {
      statusmessage.fadeOut(1000);
    }, 10000);
  }
}

sh.fn.messages.displayMessages = function() {
  var notices = sh.data.messages.notices;
  var alerts = sh.data.messages.alerts;
  var prompts = sh.data.messages.prompts;
  
  $.each(notices, function(idx) {
    var random_id = "message_" + Math.floor((Math.random()*10000)+1);
    sh.fn.messages.displayMessage("notice", notices[idx], random_id);
  });
  
  $.each(alerts, function(idx) {
    var random_id = "message_" + Math.floor((Math.random()*10000)+1);
    sh.fn.messages.displayMessage("alert", alerts[idx], random_id);
  });
  
  $.each(prompts, function(i,o) {
    var dialog_id = 'prompt-dialog_' + i;
    var dialog = create_dialog('', dialog_id, o);
    var okbutton = create_dom_element('div', {clss: 'button'}, 'OK', dialog);
    
    okbutton.on("click", function() {
      dialog.remove();
//       sh.fn.debug.ajaxLog({
//         action_taken:'confirmed_prompt_dialog',
//         called_from: o,
//       });
      console.log("ok clicked");
      dialog.remove();
    });
  });
  
  sh.data.messages.notices = [];
  sh.data.messages.alerts = [];
  sh.data.messages.prompts = [];
}


sh.fn.messages.fadeMessages = function() {
  $('#messages').fadeIn(1000);
  setTimeout(function(){
    $('#messages').fadeOut(1000);
  }, 10000);
}