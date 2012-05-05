# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
class SettlementsController < ApplicationController
  def index
    @from, @to = assign_from_to(params)
    @from = @from ? @from.beginning_of_day : 1.week.ago.beginning_of_day
    @to = @to ? @to.end_of_day : DateTime.now
    @settlements = @current_vendor.settlements.find(:all, :conditions => { :created_at => @from..@to})
    @to -= 1.day
    @taxes = @current_vendor.taxes.existing
    @cost_centers = @current_vendor.cost_centers.existing.active
    @selected_cost_center = @current_vendor.cost_centers.find_by_id(params[:cost_center_id]) if params[:cost_center_id] and !params[:cost_center_id].empty?
  end

  def new
    @settlement = Settlement.new
    @settlement.user_id = params[:user_id]
    @orders = @current_vendor.orders.where( :settlement_id => nil, :user_id => @settlement.user_id, :finished => true ).order('created_at DESC')
  end

  def detailed_list
    @selected_cost_center = @current_vendor.cost_centers.find_by_id(params[:cost_center_id]) if params[:cost_center_id]
    if params[:settlement_id]
      @settlement = @current_vendor.settlements.find_by_id(params[:settlement_id])
      @orders = @settlement.orders
    elsif params[:user_id]
      @settlement = Settlement.new :user_id => params[:user_id]
      @orders = @current_vendor.orders.where(:user_id => params[:user_id], :settlement_id => nil, :finished => true).order('id DESC')
    end
    redirect_to 'settlements/open' unless @orders
  end

  def print
    @settlement = get_model
    render :nothing => true and return if not @settlement
    @orders = @settlement.orders
    printers = initialize_printers
    text = generate_escpos_settlement(@settlement, @orders)
    do_print printers, @current_company.vendor_printers.existing.first.id, text
    close_printers printers
    redirect_to settlements_path
  end

  def update
    @settlement = get_model
    @settlement.update_attributes params[:settlement]
    @settlement.vendor = @current_vendor
    @settlement.company = @current_company
    @orders = @current_vendor.orders.where(:settlement_id => nil, :user_id => @settlement.user_id, :finished => true)
    if params[:print] != '' and local_variant?
      printers = initialize_printers
      text = generate_escpos_settlement(@settlement, @orders)
      do_print printers, params[:port].to_i, text
      close_printers printers
    end
    if @settlement.finished
      @orders.update_all :settlement_id => @settlement.id
      @settlement = Settlement.new :user_id => @settlement.user_id, :vendor_id => @current_vendor.id, :company_id => @current_company.id
    end
    respond_to do |wants|
      wants.js
    end
  end

  def create
    @settlement = Settlement.create params[:settlement]
    @settlement.vendor = @current_vendor
    @settlement.company = @current_company
    @settlement.save
    respond_to do |wants|
      wants.js
    end
  end

  def open
    @users = @current_vendor.users.existing.active
  end

  
  private

    def generate_escpos_settlement(settlement, orders)
      string =
      "\e@"     +  # Initialize Printer
      "\e!\x38"    # doube tall, double wide, bold

      if settlement.id
        title = "#{ t('activerecord.models.settlement.one') } ##{ settlement.id }\n#{ settlement.user.login }\n\n"
      else
        title = "#{ t('activerecord.models.settlement.one') }\n#{ settlement.user.login }\n\n"
      end

      string += title +
      "\ea\x00" +  # align left
      "\e!\x00"    # Font A

      string += "Gestartet:     #{ l(settlement.created_at, :format => :datetime_iso) }\n"
      string += "Abgeschlossen: #{ l(settlement.updated_at, :format => :datetime_iso) }\n"

      string += "\nNr.     Tisch   Zeit  Kostenstelle   Summe\n"

      total_costcenter = Hash.new
      CostCenter.all.each { |cc| total_costcenter[cc.id] = 0 }

      list_of_orders = ''
      storno_sum = 0
      orders.each do |o|
        cc = o.cost_center.name
        t = l(o.created_at, :format => :time_short)
        list_of_orders += "#%6.6u %6.6s %7.7s %10.10s %8.2f\n" % [o.nr, o.table.abbreviation, t, cc, o.sum]
        total_costcenter[o.cost_center.id] += o.sum
        storno_sum += o.storno_sum
      end

      string += list_of_orders +
      "                               -----------\n" +
      "\e!\x18" +  # double tall, bold
      "\ea\x02"    # align right

      list_of_costcenters = ''
      CostCenter.all.each do |cc|
        list_of_costcenters += "%s:  EUR %9.2f\n" % [cc.name, total_costcenter[cc.id]]
      end

      string += list_of_costcenters
      initial_cash = settlement.initial_cash ? "\nStartbetrag:  EUR %9.2f\n" % [settlement.initial_cash] : ''
      revenue = settlement.revenue ? "Endbetrag:  EUR %9.2f\n" % [settlement.revenue] : ''
      storno = "Storno:  EUR %9.2f\n" % [storno_sum]

      string += initial_cash + revenue + storno +

      "\e!\x01" + # Font A
      "\n\n\n\n\n" +
      "\x1DV\x00" # paper cut

      sanitize_character_encoding(string)
    end

end
