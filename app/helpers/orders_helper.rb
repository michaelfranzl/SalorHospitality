# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

module OrdersHelper
  def get_i18n
    i18n = {
      :server_no_response => escape_javascript(I18n.t(:server_no_response)),
      :just_order => escape_javascript(I18n.t(:just_order)),
      :enter_price => escape_javascript(I18n.t(:please_enter_item_price)),
      :enter_comment => escape_javascript(I18n.t(:please_enter_item_comment)),
      :no_ticket_printing => escape_javascript(I18n.t(:no_printing)),
      :decimal_separator => escape_javascript(I18n.t('number.currency.format.separator')),
      :takeaway => escape_javascript(I18n.t('articles.new.takeaway')),
      :course => escape_javascript(I18n.t('printr.course')),
      :clear => escape_javascript(I18n.t(':clear'))
    }
    return i18n.to_json
  end

  def get_settings
    settings = {
      :mobile => mobile?,
      :workstation => workstation?,
      :mobile_special => mobile_special?,
      :screenlock_timeout => @current_user.screenlock_timeout,
      :use_courses => @current_vendor.use_courses,
      :use_takeaway => @current_vendor.use_takeaway
    }
    return settings.to_json
  end
end
