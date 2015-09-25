/*
 *  Allows us to latch onto events in the UI 
 */
function emit(type, params) {
  //console.log("emitting", type, params);
  $('body').triggerHandler({type: type, packet: params});
}

function connect(label, hookname, callback) {
  //console.log("connecting", label, hookname);
  var pcd = _get('plugin_callbacks_done');
  if (!pcd) {
    pcd = [];
  }
  if (pcd.indexOf(label) == -1) {
    $('body').on(hookname, callback);
    pcd.push(label);
  }
  _set('plugin_callbacks_done',pcd) // just for debug
}