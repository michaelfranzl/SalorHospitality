# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module ApplicationHelper

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
