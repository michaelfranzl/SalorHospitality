/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/* =========================================================*/
/* ============ JSON POPULATING AND MANAGING ===============*/
/* =========================================================*/

function create_json_record(model, object) {
  d = object.d;
  item_position += 10;
  if (typeof(object.s) == 'undefined') {
    s = item_position;
  } else {
    s = object.s;
  }
  if (items_json.hasOwnProperty(d)) {
    //items_json already contains an item with a designator that is identical to the designator of the to-be-added item. When this happens, e.g. when an item is split (see function split_item()), we create an item clone.
    d = 'c' + item_position + d;
    // c is a magic designator prefix which means "cloned". Adding item_position to the designator allows us to have several cloned items. This is important for complex Option adding.
    s += 1;
  }
  if (model == 'order') {
    items_json[d] = {ai:object.ai, qi:object.qi, d:d, c:1, o:'', t:{}, i:[], p:object.p, pre:'', post:'', n:object.n, s:s, ci:object.ci, changed:true};
  } else if (model == 'booking') {
    items_json[d] = {guest_type_id:object.guest_type_id, season_id:object.season_id, duration:object.duration, count:1, parent_key:object.parent_key, has_children:false, surcharges:{}, date_locked:false, from_date:object.from_date, to_date:object.to_date, covered_seasons:object.covered_seasons}
  }
  if ( ! object.hasOwnProperty('qi')) { delete items_json[d].qi; }
  create_submit_json_record(model,d,items_json[d]);
  return d;
}

// sets attributes in both, submit_json and items_json
function set_json(model, d, attribute, value) {
  if (items_json.hasOwnProperty(d)) {
    items_json[d][attribute] = value;
    items_json[d].changed = true;
  } else {
    //alert('Unexpected error: Object items_json doesnt have the key ' + d + ' yet');
  }
  if ( attribute != 't' ) {
    // never copy the options object to submit_json
    create_submit_json_record(model, d, items_json[d]);
    submit_json.items[d][attribute] = value;
  }
}

// this creates a new record, copied from items_json, which must exist
function create_submit_json_record(model, d, object) {
  if( !submit_json.hasOwnProperty('items')) { submit_json.items = {}; };
  if( !submit_json.items.hasOwnProperty(d)) {
    if (model == 'order') {
      submit_json.items[d] = {id:object.id, ai:object.ai, qi:object.qi, s:object.s};
    } else if (model == 'booking') {
      submit_json.items[d] = {id:object.id, guest_type_id:object.guest_type_id, duration:object.duration, season_id:object.season_id, parent_id:object.parent_id, from_date:object.from_date, to_date:object.to_date};
    }
    // remove redundant fields to reduce ajax request byte size
    if (
      items_json[d].hasOwnProperty('id') &&
      items_json[d].id != null &&
      items_json[d].id > 0
    ) {
      delete submit_json.items[d].ai;
      delete submit_json.items[d].qi;
    }
    if ( ! items_json[d].hasOwnProperty('qi')) {
      delete submit_json.items[d].qi;
    }
  }
}

function copy_json_from_submit_queue(object_id) {
  submit_json = $.extend(true, {}, submit_json_queue[object_id]); // deep copy
  items_json = $.extend(true, {}, items_json_queue[object_id]); // deep copy
  delete submit_json_queue[object_id];
  delete items_json_queue[object_id];
}

function copy_json_to_submit_queue(object_id) {
  submit_json_queue[object_id] = $.extend(true, {}, submit_json);
  if ( typeof submit_json_queue[object_id].sent_at == 'undefined' ) {
    submit_json_queue[object_id].sent_at = (new Date).getTime();
  }
  items_json_queue[object_id] = $.extend(true, {}, items_json);
  submit_json.model = {};
  delete submit_json.items;
  items_json = {};
}

function send_json(object_id, callback) {
  callback = typeof callback !== 'undefined' ? callback : function(){};
  copy_json_to_submit_queue(object_id);
  send_queue_after_server_online(object_id, callback);
}