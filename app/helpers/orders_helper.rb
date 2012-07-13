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
      :currency_unit => escape_javascript(I18n.t('number.currency.format.unit')),
      :clear => escape_javascript(I18n.t(':clear')),
      :customers => escape_javascript(I18n.t('activerecord.models.customer.other')),
      :save => escape_javascript(I18n.t('various.save')),
      :payment_method => escape_javascript(PaymentMethodItem.model_name.human),
      :pay => escape_javascript(I18n.t('various.pay')),
      :common_surcharges => escape_javascript(I18n.t('various.common_surcharges')),
      :cancel => escape_javascript(I18n.t('various.cancel')),
      :unamed => escape_javascript(I18n.t('various.unamed')),
      :customer => escape_javascript(I18n.t('activerecord.models.customer.one')),
      :browser_warning => escape_javascript(I18n.t('sessions.browser_warning.warning'))
    }
    return i18n.to_json
  end

  def get_settings
    settings = {
      :mobile => mobile?,
      :workstation => workstation?,
      :mobile_special => mobile_special?,
      :screenlock_timeout => @current_user.screenlock_timeout
    }
    return settings.to_json
  end

  def compose_option_names_without_price(item)
    item.options.collect{ |o| "<br>#{ o.name }" }.join
  end

end
