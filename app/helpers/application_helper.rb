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
      if o.images.empty? then
        o.images.build
        o.images.first.image_type = 'logo' if o.class.name == 'Vendor' and o.images.first.image_type.nil?
      end
      if o.class.name == 'Vendor' and o.images.count < 2 then
        o.images.first.image_type = 'logo' if o.images.first.image_type.nil?
        o.images.build
        o.images.first.image_type == 'logo' ? o.images.last.image_type = 'invoice_logo' : o.images.last.image_type = 'logo'
      end
    end
  end

  def permit(p)
    @current_user.role.permissions.include?(p)
  end

end
