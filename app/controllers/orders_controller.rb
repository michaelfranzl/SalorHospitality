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

class OrdersController < ApplicationController

  skip_before_filter :fetch_logged_in_user, :set_locale, :only => [:login]

  def index
    @tables = Table.all
    @categories = Category.find(:all, :order => :sort_order)
    @users = User.all
    session[:admin_interface] = !mobile? # on workstation, switch admin panel on per default
  end

  # happens only in invoice_form if user changes CostCenter or Tax of Order
  def update
    @order = Order.find_by_id params[:id]
    @order.update_attributes params[:order]
    @order.tax = Tax.find_by_id params[:order][:tax_id] if params[:order][:tax_id] # explicit setting of tax so that setter method in order.rb is executed.
    @orders = Order.find_all_by_finished(false, :conditions => { :table_id => Order.find_by_id(params[:id]).table_id })
    @cost_centers = CostCenter.all
    @taxes = Tax.all
    render 'items/update'
  end

  def edit
    @order = Order.find_by_id params[:id]
    @table = @order.table
    render 'orders/go_to_order_form'
  end

  def login
    @current_user = User.find_by_login_and_password(params[:login], params[:password])
    if @current_user
      @tables = Table.all
      @categories = Category.find(:all, :order => :sort_order)
      session[:user_id] = @current_user
      session[:admin_interface] = !mobile? # admin panel per default on on workstation
      I18n.locale = @current_user.language
      render 'login_successful'
    else
      @users = User.all
      @errormessage = t :wrong_password
      render 'login_wrong'
    end
  end

  def show
    @client_data = File.exist?('config/client_data.yml') ? YAML.load_file( 'config/client_data.yml' ) : {}
    if params[:id] != 'last'
      @order = Order.find(params[:id])
    else
      @order = Order.find_all_by_finished(true).last
    end
    @previous_order, @next_order = neighbour_orders(@order)
    respond_to do |wants|
      wants.html
      wants.bon { render :text => generate_escpos_invoice(@order) }
    end
  end

  def unsettled
    @unsettled_orders = Order.find(:all, :conditions => { :settlement_id => nil, :finished => true })
    unsettled_userIDs = Array.new
    @unsettled_orders.each do |uo|
      unsettled_userIDs << uo.user_id
    end
    unsettled_userIDs.uniq!
    @unsettled_users = User.find(:all, :conditions => { :id => unsettled_userIDs })
    flash[:notice] = t(:there_are_no_open_settlements) if @unsettled_users.empty?
  end

  def toggle_admin_interface
    if session[:admin_interface]
      session[:admin_interface] = !session[:admin_interface]
    else
      session[:admin_interface] = true
    end
    @tables = Table.all
  end

  def toggle_tax_colors
    if session[:display_tax_colors]
      session[:display_tax_colors] = !session[:display_tax_colors]
    else
      session[:display_tax_colors] = true
    end
    @orders = Order.find_all_by_finished(false, :conditions => { :table_id => Order.find_by_id(params[:id]).table_id })
    @cost_centers = CostCenter.all
    @taxes = Tax.all
    render 'items/update'
  end

  def print_and_finish
    @order = Order.find params[:id]

    BillGastro::Application::largest_order_number = @order.nr if @order.nr > BillGastro::Application::largest_order_number 

    if not @order.finished and mobile?
      @order.user = @current_user
      @order.created_at = Time.now
    end

    if @order.order # unlink any parent relationships or Order and Item
      @order.items.each do |item|
        item.item.update_attribute( :item_id, nil ) if item.item
        item.update_attribute( :item_id, nil )
      end
      @order.order.items.each do |item|
        item.item.update_attribute( :item_id, nil ) if item.item
        item.update_attribute( :item_id, nil )
      end
      @order.order.update_attribute( :order_id, nil )
      @order.update_attribute( :order_id, nil )
    end

    invoice = generate_escpos_invoice @order
    BillGastro::Application::SP.write invoice if defined? BillGastro::Application::SP
    File.open('/dev/usb/lp0', 'w') { |f| f.write invoice } if File.exists? '/dev/usb/lp0' and File.writable? '/dev/usb/lp0'

    justfinished = false
    if not @order.finished
      @order.finished = true
      @order.printed_from = "#{ request.remote_ip } on printer #{ params[:port] }"
      justfinished = true
      @order.save
    end

    @orders = Order.find(:all, :conditions => { :table_id => @order.table, :finished => false })
    @order.table.update_attribute :user, nil if @orders.empty?
    @cost_centers = CostCenter.find_all_by_active(true)
    @taxes = Tax.all

    respond_to do |wants|
      wants.html { redirect_to order_path @order }
      wants.js {
        if not justfinished
          render :nothing => true
        elsif not @orders.empty?
          render('go_to_invoice_form')
        else
          @tables = Table.all
          render('go_to_tables')
        end
      }
    end
  end

  def storno
    @order = Order.find_by_id params[:id]
  end

  def go_to_order_form # to be called only with /id
    @order = Order.find(params[:id])
    @table = @order.table
    @cost_centers = CostCenter.find_all_by_active(true)
    render 'go_to_order_form'
  end

  def receive_order_attributes_ajax
    if not params[:order_action] == 'cancel_and_go_to_tables'
      if params[:order][:id] == 'add_offline_items_to_order'
        @order = Order.find(:all, :conditions => { :finished => false, :table_id => params[:order][:table_id] }).first
      else
        @order = Order.find(params[:order][:id]) if not params[:order][:id].empty?
      end

      @cost_centers = CostCenter.find_all_by_active(true)
      @taxes = Tax.all

      if @order
        # similar to update
        @order.update_attributes(params[:order])
        @order.table.update_attribute :user, @order.user
      else
        # similar to create
        # create new order or, if order exists already on table, add items to existing order
        @order = Order.new(params[:order])
        @order.nr = get_next_unique_and_reused_order_number
        @order.credit = Order.last ? Order.last.credit - 1 : BillGastro::Application::INITIAL_CREDITS
        @order.sum = calculate_order_sum @order
        @order.cost_center = @cost_centers.first
        @order.save
        @order.table.update_attribute :user, @order.user
      end
      BillGastro::Application::largest_order_number = @order.nr if @order.nr > BillGastro::Application::largest_order_number
      process_order(@order)
    end
    conditional_redirect_ajax(@order)
  end

  def last_invoices
    @last_orders = Order.find(:all, :conditions => { :finished => true }, :limit => 10, :order => 'created_at DESC')
  end

  private

    def process_order(order)
      order.reload
      if order.items.size.zero?
        BillGastro::Application::unused_order_numbers << order.nr
        order.delete
        order.table.update_attribute :user, nil
        return
      end

      order.update_attribute( :sum, calculate_order_sum(order) )

      group_identical_items(order)

      drinks_normal   = generate_escpos_items order, 0, 0
      foods_normal    = generate_escpos_items order, 1, 0
      drinks_takeaway = generate_escpos_items order, 1, 1

      if defined? BillGastro::Application::SP
        BillGastro::Application::SP.write drinks_normal
        BillGastro::Application::SP.write foods_normal
        BillGastro::Application::SP.write drinks_takeaway
      end

      if File.exists? '/dev/usb/lp0' and File.writable? '/dev/usb/lp0'
        File.open('/dev/usb/lp0', 'w') { |f| f.write drinks_normal }
        File.open('/dev/usb/lp0', 'w') { |f| f.write foods_normal }
        File.open('/dev/usb/lp0', 'w') { |f| f.write drinks_takeaway }
      end

    end

    def conditional_redirect_ajax(order)
      @tables = Table.all

      render('go_to_tables') and return if not order or order.destroyed?

      case params[:order_action]
        when 'save_and_go_to_tables'
          render 'go_to_tables'
        when 'cancel_and_go_to_tables'
          render 'go_to_tables'
        when 'save_and_go_to_invoice'
          @orders = Order.find(:all, :conditions => { :table_id => order.table.id, :finished => false })
          render 'go_to_invoice_form'
        when 'move_order_to_table'
          move_order_to_table(order, params[:target_table])
          @tables = Table.all
          render 'go_to_tables'
      end
    end

    def move_order_to_table(order,target_table_id)
      target_order = Order.find(:all, :conditions => { :table_id => target_table_id, :finished => false }).first
      if target_order
        Item.transaction do
          order.items.each do |i|
            i.order = target_order
            result = i.save
            raise "Gruppieren von Item 1 schlug fehl. Oops!" if not result
          end
        end

        target_order.reload
        target_order.update_attribute( :sum, calculate_order_sum(target_order) )
        group_identical_items(target_order)
        order.reload # important before destroying, otherwise rails deletes all previously assigned items because of has_many :items, :dependent => :destroy
        order.destroy
      else
        # move order to empty table
        order.update_attribute :table_id, target_table_id
      end

      # change table users and colors
      unfinished_orders_on_this_table = Order.find(:all, :conditions => { :table_id => order.table.id, :finished => false })
      order.table.update_attribute :user, nil if unfinished_orders_on_this_table.empty?
      unfinished_orders_on_target_table = Order.find(:all, :conditions => { :table_id => target_table_id, :finished => false })
      Table.find(target_table_id).update_attribute :user, order.user
    end

    def group_identical_items(o)
      items = o.items
      n = items.size - 1
      0.upto(n-1) do |i|
        (i+1).upto(n) do |j|
          Item.transaction do
            if (items[i].article_id  == items[j].article_id and
                items[i].quantity_id == items[j].quantity_id and
                items[i].price       == items[j].price and
                items[i].comment     == items[j].comment
               )
              items[i].count += items[j].count
              items[i].printed_count += items[j].printed_count
              result = items[i].save
              raise "Gruppieren von Item 2 schlug fehl. Oops!" if not result
              items[j].destroy
            end
          end
        end
      end
    end

    def neighbour_orders(order)
      orders = Order.find_all_by_finished(true)
      idx = orders.index(order)
      previous_order = orders[idx-1]
      previous_order = order if previous_order.nil?
      next_order = orders[idx+1]
      next_order = order if next_order.nil?
      return previous_order, next_order
    end

    def reduce_stocks(order)
      order.items.each do |item|
        item.article.ingredients.each do |ingredient|
          ingredient.stock.balance -= item.count * ingredient.amount
          ingredient.stock.save
        end
      end
    end

end
