report.functions = {
  
  fetch:function() {
    $('#report_progress').show();
    $.ajax({
      type: 'GET',
      url: '/vendors/report',
      cache: false,
      dataType: 'json',
      data: {from:report.variables.report_from, to:report.variables.report_to},
      success: function(data){
        report.variables.datasource = data;
        if (data == "") {
          $('#report_container').html('');
        } else {
          report.functions.calculate_categories_table();
          report.functions.calculate_rooms_table();
          report.functions.calculate_taxes_table();
          report.functions.calculate_payment_methods_table();
          report.functions.render();
        }
        $('#report_progress').hide();
      }
    });
  },
  
  calculate_categories_table: function() {
    //calculate sums by category
    var c = {};
    $.each(report.variables.datasource.items, function(k,v) {
      var category_id = v.y;
      catname = resources.c[category_id].n;
      if ( v.r == null ) {
        if (c.hasOwnProperty(catname)) {
          $.each(v.t, function(s,t) {
            c[catname][i18n.gross] += t.g
            c[catname][i18n.net] += t.n
            c[catname][i18n.tax_amount] += t.t
          })
        } else {
          $.each(v.t, function(s,t) {
            c[catname] = {};
            c[catname][i18n.gross] = t.g
            c[catname][i18n.net] = t.n
            c[catname][i18n.tax_amount] = t.t
          })
        }
      }
    })
    report.variables.categories_tablesource = c;
  },
  
  calculate_rooms_table: function() {
    //calculate sums by room
    var r = {};
    $.each(report.variables.datasource.booking_items, function(k,v) {
      var room_id = v.m;
      roomname = resources.r[room_id].n;
      if (! r.hasOwnProperty(roomname)) {
        r[roomname] = {}
        r[roomname][i18n.gross] = 0
        r[roomname][i18n.net] = 0
        r[roomname][i18n.tax_amount] = 0
      }
      $.each(v.t, function(s,t) {
        r[roomname][i18n.gross] += t.g
        r[roomname][i18n.net] += t.n
        r[roomname][i18n.tax_amount] += t.t
      })
    })
    report.variables.rooms_tablesource = r;
  },
  
  calculate_payment_methods_table: function() {    
    //calculate sums by method
    var output = {};
    $.each(report.variables.datasource.payment_method_items, function(k,v) {
      var pm_id = v.pm_id;
      pmname = resources.pm[pm_id].n;
      if (! output.hasOwnProperty(pmname)) {
        // column headers
        output[pmname] = {}
        output[pmname][' '] = 0
        output[pmname][i18n.refund] = 0
      }
      if (v.r == true) {
        output[pmname][i18n.refund] += v.a
      } else {
        output[pmname][' '] += v.a
      }
    })
    report.variables.payment_methods_tablesource = output;
  },
  
  calculate_taxes_table: function() {    
    //calculate sums by taxes
    var taxes = {};
    $.each(report.variables.datasource.items, function(key,value) {
      taxes = report.functions.accumulate_taxes(taxes, value);
    })
    $.each(report.variables.datasource.booking_items, function(key,value) {
      taxes = report.functions.accumulate_taxes(taxes, value);
    })
    report.variables.taxes_tablesource = taxes;
  },
  
  accumulate_taxes: function(taxes, object) {
    $.each(object.t, function(k,v) {
      var tax_id = k;
      if ( object.r == null ) {
        // not refunded
        taxname = resources.t[tax_id].n + ' (' + resources.t[tax_id].p + '%)';
        if (taxes.hasOwnProperty(taxname)) {
          taxes[taxname][i18n.gross] += v.g
          taxes[taxname][i18n.net] += v.n
          taxes[taxname][i18n.tax_amount] += v.t
        } else {
          taxes[taxname] = {};
          taxes[taxname][i18n.gross] = v.g
          taxes[taxname][i18n.net] = v.n
          taxes[taxname][i18n.tax_amount] = v.t
        }
      }
    })
    return taxes;
  },
  
  render: function() {
    $('#report_container').html('');
    report.functions.table_from_json(report.variables.categories_tablesource, 'settlements', '#report_container', i18n.categories);
    report.functions.table_from_json(report.variables.rooms_tablesource, 'settlements', '#report_container', i18n.rooms);
    report.functions.table_from_json(report.variables.taxes_tablesource, 'settlements', '#report_container', i18n.taxes);
    report.functions.table_from_json(report.variables.payment_methods_tablesource, 'settlements', '#report_container', i18n.payment_method);
  },

  display_popup: function() {
    report.variables = {};
    $('#report').remove();
    report_popup = create_dom_element('div',{id:'report'}, '', 'body');
    close_button = create_dom_element('span',{}, '', report_popup);
    close_button.addClass('done');
    close_button.on('click', function() { $('#report').remove(); });
    from_input = create_dom_element('input', {type:'text',id:'report_from'}, '', report_popup);
    from_input.datepicker({
      onSelect: function(date, inst) {
        report.variables.report_from = date;
        if (report.variables.hasOwnProperty('report_to')) {
          report.functions.fetch();
        }
      }
    })
    to_input = create_dom_element('input', {type:'text',id:'report_to'}, '', report_popup);
    to_input.datepicker({
      onSelect: function(date, inst) {
        report.variables.report_to = date;
        if (report.variables.hasOwnProperty('report_from')) {
          report.functions.fetch();
        }
      }
    })
    report_container = create_dom_element('div',{id:'report_container'}, '', report_popup);
    progress_indicator = create_dom_element('img',{id:'report_progress', src:'/images/ajax-loader2.gif'}, '', report_popup);
    progress_indicator.addClass('displaynone');
    report_popup.fadeIn();
  },
  
  table_from_json: function(source, cls, target, heading) {
    if ($.isEmptyObject(source)) return;
    create_dom_element('h2',{},heading,target);
    table = create_dom_element('table', {}, '', target);
    table.addClass(cls);
    header_row = create_dom_element('tr',{},'',table);
    // get table headers from the first JSON object
    var first;
    $.each(source, function(k,v) {
      first = v;
      return false; // break after the first element, since we only need the headers
    })
    // render the table header
    var headers = Object.keys(first);
    var sums = {};
    var empty_element = create_dom_element('td', {}, '', header_row);
    empty_element.addClass('link');
    for (i in headers) {
      create_dom_element('th',{},headers[i],header_row);
      sums[headers[i]] = 0; // initialize sums for each column
    }
    // render the table body
    $.each(source, function(k,v) {
      data_row = create_dom_element('tr', {}, '', table);
      var label_element = create_dom_element('td', {}, k, data_row);
      label_element.addClass('link');
      for (j in v) {
        create_dom_element('td', {}, number_to_currency(v[j]), data_row);
        sums[j] += v[j];
      }
    })
    //render thr table footer
    footer_row = create_dom_element('tr', {}, '', table);
    create_dom_element('th', {}, '', footer_row);
    for (i in headers) {
      create_dom_element('th',{},number_to_currency(sums[headers[i]]), footer_row);
    }
  }
}