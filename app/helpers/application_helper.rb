# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
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

  def nest_image(object)
    object.tap do |o|
      o.images.build if o.images.empty?
    end
  end

  def assign_from_to(p)
    f = Date.civil( p[:from][:year ].to_i,
                    p[:from][:month].to_i,
                    p[:from][:day  ].to_i) if p[:from]
    t = Date.civil( p[:to  ][:year ].to_i,
                    p[:to  ][:month].to_i,
                    p[:to  ][:day  ].to_i) + 1.day if p[:to]
    return f, t
  end

end
