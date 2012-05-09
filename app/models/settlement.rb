# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class Settlement < ActiveRecord::Base
  include Scope
  belongs_to :company
  belongs_to :vendor
  belongs_to :user
  has_many :orders

  def revenue=(revenue)
    write_attribute(:revenue, revenue.gsub(',', '.'))
  end

  def initial_cash=(initial_cash)
    write_attribute(:initial_cash, initial_cash.gsub(',', '.'))
  end

  def print
    vendor_printer = self.vendor.vendor_printers.existing.first
    printr = Printr.new(vendor_printer)
    printr.open
    printr.print vendor_printer.id, self.escpos
    printr.close
  end

  def escpos
    string =
    "\e@"     +  # Initialize Printer
    "\e!\x38"    # doube tall, double wide, bold

    title = "#{ I18n.t('activerecord.models.settlement.one') } ##{ self.id }\n#{ self.user.login }\n\n"

    string += title +
    "\ea\x00" +  # align left
    "\e!\x00"    # Font A

    string += "Gestartet:     #{ I18n.l(self.created_at, :format => :datetime_iso) }\n"
    string += "Abgeschlossen: #{ I18n.l(self.updated_at, :format => :datetime_iso) }\n"

    string += "\nBestnr. Tisch   Zeit  Kostenstelle   Summe\n"

    total_costcenter = Hash.new
    costcenters = self.vendor.cost_centers.existing.active
    costcenters.each { |cc| total_costcenter[cc.id] = 0 }

    list_of_orders = ''
    refund_total = 0
    self.orders.existing.each do |o|
      cc = o.cost_center.name if o.cost_center
      t = l(o.created_at, :format => :time_short)
      list_of_orders += "#%6.6u %6.6s %7.7s %10.10s %8.2f\n" % [o.nr, o.table.name, t, cc, o.sum]
      total_costcenter[o.cost_center.id] += o.sum if o.cost_center
      refund_total += o.refund_sum
    end

    string += list_of_orders +
    "                               -----------\n" +
    "\e!\x18" +  # double tall, bold
    "\ea\x02"    # align right

    list_of_costcenters = ''
    costcenters.each do |cc|
      list_of_costcenters += "%s:  EUR %9.2f\n" % [cc.name, total_costcenter[cc.id]]
    end

    string += list_of_costcenters
    initial_cash = self.initial_cash ? "\nStartbetrag:  EUR %9.2f\n" % [self.initial_cash] : ''
    revenue = self.revenue ? "Endbetrag:  EUR %9.2f\n" % [self.revenue] : ''
    storno = "Storno:  EUR %9.2f\n" % [refund_total]

    string += initial_cash + revenue + storno +

    "\e!\x01" + # Font A
    "\n\n\n\n\n" +
    "\x1DV\x00" # paper cut

    Printr.sanitize(string)
  end

end
