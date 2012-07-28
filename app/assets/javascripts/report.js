gastro.functions.report = {
  initiate:function() {
    $('#report_progress').show();
    $.ajax({
      url: '/settlements',
      dataType: 'json',
      data: {from:gastro.variables.report_from, to:gastro.variables.report_to},
      success: function(data){
        gastro.variables.report_items = data;
        if (data == "") {
          $('#report_container').html('');
          return;
        }
        gastro.functions.report.convert_from_yaml();
        gastro.functions.report.calculate();
        gastro.functions.report.render();
        $('#report_progress').hide();
      }
    });
  },
  
  convert_from_yaml: function() {
    $.each(gastro.variables.report_items, function(k,v) {
      gastro.variables.report_items[k].t = YAML.eval(v.t);
    })
  },
  
  calculate: function() {
    //calculate sums by category
    var c = {};
    $.each(gastro.variables.report_items, function(k,v) {
      var category_id = v.y;
      catname = resources.c[category_id].n;
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
    })
    gastro.variables.report.categories = c;
    
    //calculate sums by taxes
    var taxes = {};
    $.each(gastro.variables.report_items, function(key,value) {
      $.each(value.t, function(k,v) {
        var tax_id = k;
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
      })
    })
    gastro.variables.report.taxes = taxes;
    
  },
  
  render: function() {
    $('#report_container').html('');
    salor.functions.table_from_json(gastro.variables.report.categories, {class:'settlements'}, '#report_container', i18n.categories);
    salor.functions.table_from_json(gastro.variables.report.taxes, {class:'settlements'}, '#report_container', i18n.taxes);
  },

  display_popup: function() {
    gastro.variables.report = {};
    $('#report').remove();
    report_popup = create_dom_element('div',{id:'report'}, '', '#container');
    close_button = create_dom_element('span',{class:'done'}, '', report_popup);
    close_button.on('click', function() { $('#report').remove(); });
    from_input = create_dom_element('input', {type:'text',id:'report_from'}, '', report_popup);
    from_input.datepicker({
      onSelect: function(date, inst) {
        gastro.variables.report_from = date;
      }
    })
    to_input = create_dom_element('input', {type:'text',id:'report_to'}, '', report_popup);
    to_input.datepicker({
      onSelect: function(date, inst) {
        gastro.variables.report_to = date;
        gastro.functions.report.initiate();
      }
    })
    report_container = create_dom_element('div',{id:'report_container'}, '', report_popup);
    progress_indicator = create_dom_element('img',{id:'report_progress', src:'/images/ajax-loader2.gif', class:'displaynone'}, '', report_popup);
    report_popup.fadeIn();
  }
}


YAML = {
  valueOf: function(token) {
    if (/\d/.exec(token)) {
      return eval('(' + token + ')');
    } else {
      return token;
    }
  },

  tokenize: function(str) {
    //tokens = str.match(/(---|true|false|null|#(.*)|\[(.*?)\]|\{(.*?)\}|[\w\-]+:|-(.+)|\d+\.\d+|\d+|\n+)/g)
    tokens = str.match(/(---|true|false|null|#(.*)|\[(.*?)\]|\{(.*?)\}|[\w\-]+:|-(.+)|\d+\.\d+|\d+|\n+|[^ :].*)/g)
    return tokens;
  },

  strip: function(str) {
    return str.replace(/^\s*|\s*$/, '')
  },

  parse: function(tokens) {
    var token, list = /^-(.*)/, key = /^([\w\-]+):/, stack = {}
    while (token = tokens.shift())
      if (token[0] == '#' || token == '---' || token == "\n" || token == "")
  continue
      else if (key.exec(token) && tokens[0] == "\n")
  stack[RegExp.$1] = this.parse(tokens)
      else if (key.exec(token))
  stack[RegExp.$1] = this.valueOf(tokens.shift())
      else if (list.exec(token))
  (stack.constructor == Array ?
    stack : (stack = [])).push(this.strip(RegExp.$1))
    return stack
  },

  eval: function(str) {
    return this.parse(this.tokenize(str))
  }
}

//print(YAML.eval(readFile('config.yml')).toSource())
//string = "---\n2:\n  :percent: 20\n  :tax: 0.88\n  :gro: 4.4\n  :net: 3.52\n  :letter: G\n  :name: Getränke"