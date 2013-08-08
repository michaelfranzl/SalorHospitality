/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function manage_counters() {
  counter_update_resources -= 1;
  counter_update_tables -= 1;
  counter_update_item_lists -= 1;
  counter_refresh_queue -= 1;

  if (counter_update_resources == 0) {
    update_resources();
    counter_update_resources = timeout_update_resources;
  }
  if (counter_update_item_lists == 0) {
    update_item_lists();
    counter_update_item_lists = timeout_update_item_lists;
  }
  if (counter_update_tables == 0) {
    update_tables();
    counter_update_tables = timeout_update_tables;
  }
  if (counter_refresh_queue == 0) {
    //display_queue();
    counter_refresh_queue = timeout_refresh_queue;
  }
  return 0;
}