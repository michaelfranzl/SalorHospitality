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
      :just_order => escape_javascript(I18n.t(:just_order, :locale => @locale)),
      :enter_price => escape_javascript(I18n.t(:please_enter_item_price, :locale => @locale)),
      :enter_comment => escape_javascript(I18n.t(:please_enter_item_comment, :locale => @locale)),
      :no_ticket_printing => escape_javascript(I18n.t(:no_printing, :locale => @locale)),
      :decimal_separator => escape_javascript(I18n.t('number.currency.format.separator', :locale => @region)),
      :currency_unit => escape_javascript(I18n.t('number.currency.format.unit', :locale => @region)),
      :clear => escape_javascript(I18n.t(':clear', :locale => @locale)),
      :customers => escape_javascript(I18n.t('activerecord.models.customer.other', :locale => @locale)),
      :save => escape_javascript(I18n.t('various.save', :locale => @locale)),
      :payment_method => escape_javascript(I18n.t('activerecord.models.payment_method.other', :locale => @locale)),
      :pay => escape_javascript(I18n.t('various.pay', :locale => @locale)),
      :common_surcharges => escape_javascript(I18n.t('various.common_surcharges', :locale => @locale)),
      :cancel => escape_javascript(I18n.t('various.cancel', :locale => @locale)),
      :unamed => escape_javascript(I18n.t('various.unamed', :locale => @locale)),
      :customer => escape_javascript(I18n.t('activerecord.models.customer.one', :locale => @locale)),
      :browser_warning => escape_javascript(I18n.t('sessions.browser_warning.warning', :locale => @locale)),
      :gross => escape_javascript(I18n.t(:gross, :locale => @locale)),
      :net => escape_javascript(I18n.t(:net, :locale => @locale)),
      :tax_amount => escape_javascript(I18n.t(:tax_amount, :locale => @locale)),
      :categories => escape_javascript(I18n.t('activerecord.models.category.other', :locale => @locale)),
      :taxes => escape_javascript(I18n.t('activerecord.models.tax.other', :locale => @locale)),
      :interim_invoice => escape_javascript(I18n.t('various.interim_invoice', :locale => @locale)),
      :assign_order_to_booking => escape_javascript(I18n.t('various.consumations', :locale => @locale)),
      :rooms => escape_javascript(I18n.t('activerecord.models.room.other', :locale => @locale)),
      :delete => escape_javascript(I18n.t('various.delete', :locale => @locale)),
      :refund => escape_javascript(I18n.t(:refund, :locale => @locale)),
      :mobile_view => escape_javascript(I18n.t('various.mobile_view', :locale => @locale)),
      :workstation_view => escape_javascript(I18n.t('various.workstation_view', :locale => @locale)),
      :order_will_be_confirmed => escape_javascript(I18n.t('various.order_will_be_confirmed', :locale => @locale)),
      :finish_was_requested => escape_javascript(I18n.t('various.finish_was_requested', :locale => @locale)),
      :waiter_was_requested => escape_javascript(I18n.t('various.waiter_was_requested', :locale => @locale)),
      :no_connection_retry =>
      escape_javascript(I18n.t('various.no_connection_retry', :locale => @locale)),
      :successfully_sent =>
      escape_javascript(I18n.t('various.successfully_sent', :locale => @locale)),
      :table_contains_offline_items =>
      escape_javascript(I18n.t('various.table_contains_offline_items', :locale => @locale)),
      :attempt => escape_javascript(I18n.t('various.attempt', :locale => @locale)),
      :no_connection_giving_up => escape_javascript(I18n.t('various.no_connection_giving_up', :locale => @locale)),
      :sending => escape_javascript(I18n.t('various.sending', :locale => @locale)),
      :check_order_on_workstation => escape_javascript(I18n.t('various.check_order_on_workstation', :locale => @locale)),
      :server_not_responded => escape_javascript(I18n.t('various.server_not_responded', :locale => @locale)),
      :server_error => escape_javascript(I18n.t('various.server_error', :locale => @locale)),
      :connecting => escape_javascript(I18n.t('various.connecting', :locale => @locale)),
      :no_connection_retrying => escape_javascript(I18n.t('various.no_connection_retrying', :locale => @locale)),
      :no_connection => escape_javascript(I18n.t('various.no_connection', :locale => @locale)),
      :server_error_short => escape_javascript(I18n.t('various.server_error_short', :locale => @locale)),
      :your_shift_has_ended => escape_javascript(I18n.t('various.your_shift_has_ended', :locale => @locale)),
      :double_submission_warning => escape_javascript(I18n.t('various.double_submission_warning')),
      :already_finished_warning => escape_javascript(I18n.t('various.already_finished_warning')),
    }
    return i18n.to_json
  end

  def get_settings
    settings = {
      :mobile => mobile?,
      :workstation => workstation?,
      :mobile_special => mobile_special?,
      :screenlock_timeout => (@current_user.screenlock_timeout if @current_user),
      :advertising_timeout => (@current_user.advertising_timeout if @current_user),
      :mobile_drag_and_drop => false
    }
    return settings.to_json
  end

end
