/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

var tableupdates = -1;

var debugmessages = [];

var _CTRL_DOWN = false;

var _key_codes = {tab: 9,shift: 16, ctrl: 17, alt: 18, f2: 113};

var _keys_down = {tab: false,shift: false, ctrl: false, alt: false, f2:false};

var report = {functions:{}, variables:{}};

var upper_delivery_time_limit = 45 * 60000;

var send_queue_attempts = 1;

var toggle_drag_tables_state = 0;

var interim_receipt_enabled = false;

var invoice_update = true;
var get_table_show_retry = true;
var last_table_id = null;

var new_order = true;
var option_position = 0;
var item_position = 0;
var payment_method_uid = 0;
var audio_enabled = true;

var resources = {};
var plugin_callbacks_done = [];
var permissions = {};
var intervals = {};
var items_json = {};
var submit_json = {model:{}};
var items_json_queue = {};
var submit_json_queue = {};
var customers_json = {};

var timeout_update_tables = 19;
var timeout_update_item_lists = 31;
var timeout_update_resources = 127;
var timeout_refresh_queue = 4;

var counter_update_resources = timeout_update_resources;
var counter_update_tables = 3;
var counter_update_item_lists = 3;
var counter_refresh_queue = timeout_refresh_queue;