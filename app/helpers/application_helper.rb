# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.

module ApplicationHelper
  #%script== $.datepicker.setDefaults({#{ raw generate_default_calendar_options.join(", ") }});
  def generate_html(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f  

    form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
      render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
    end
  end

  def generate_template(form_builder, method, options = {})
    escape_javascript generate_html(form_builder, method, options)
  end

  def generate_default_calendar_options
    options = []
    options.push('dateFormat : ' + t("date.formats.default").gsub("%Y", "yy").gsub("%y", "y").gsub("%m", "mm").gsub("%d", "dd").to_json)
    options.push('dayNames : ' + generate_calendar_names('day_names').to_json)
    options.push('dayNamesShort : ' + generate_calendar_names('abbr_day_names').to_json)
    options.push('dayNamesMin : ' + generate_calendar_names('abbr_day_names').to_json)
    month_names = generate_calendar_names('month_names')
    month_names.shift if month_names.length > 12 # Remove the '~' entry
    options.push('monthNames : ' + month_names.to_json)
    abbr_month_names = generate_calendar_names('abbr_month_names')
    abbr_month_names.shift if abbr_month_names.length > 12 # Remove the '~' entry
    options.push('monthNamesShort : ' + abbr_month_names.to_json)
    #options.push('currentText : ' + t(:today).to_json)
  end

  def generate_calendar_names(type)
    t("date.#{type}")
  end

  def generate_calendar_date_format
    format = t("date.formats.default")
  end
  
end
