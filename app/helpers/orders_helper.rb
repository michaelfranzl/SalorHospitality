# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
      :browser_warning => escape_javascript(I18n.t('sessions.browser_warning.warning')),
      :gross => escape_javascript(I18n.t(:gross)),
      :net => escape_javascript(I18n.t(:net)),
      :tax_amount => escape_javascript(I18n.t(:tax_amount)),
      :categories => escape_javascript(I18n.t('activerecord.models.category.other')),
      :taxes => escape_javascript(I18n.t('activerecord.models.tax.other')),
      :interim_invoice => escape_javascript(I18n.t('various.interim_invoice')),
      :assign_order_to_booking => escape_javascript(I18n.t('various.consumations')),
      :rooms => escape_javascript(I18n.t('activerecord.models.room.other'))
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
