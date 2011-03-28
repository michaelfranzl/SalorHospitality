class TablesController < ApplicationController

  def index
    @tables = Table.all
    @last_finished_order = Order.find_all_by_finished(true).last
  end

  def show
    @table = Table.find(params[:id])
    @cost_centers = CostCenter.find_all_by_active(true)
    @orders = Order.find(:all, :conditions => { :table_id => @table.id, :finished => false }) # @orders array needed for view 'go_to_invoice_form'
    respond_to do |wants|
      wants.js {
        if @orders.size > 1
          render 'orders/go_to_invoice_form'
        else
          @order = @orders.first
          render 'orders/go_to_order_form'
        end
      }
    end
  end

  def new
    @table = Table.new
  end

  def create
    @table = Table.new(params[:table])
    @table.save ? redirect_to(tables_path) : render(:new)
  end

  def edit
    @table = Table.find(params[:id])
    render :new
  end

  def update
    @table = Table.find(params[:id])
    success = @table.update_attributes(params[:table])
    respond_to do |wants|
      wants.html{ success ? redirect_to(tables_path) : render(:new)}
      wants.js { render :nothing => true }
    end
  end

  def destroy
    @table = Table.find(params[:id])
    flash[:notice] = t(:successfully_deleted, :what => @table.name)
    @table.destroy
    redirect_to tables_path
  end

  def time_range
    @from = Date.civil( params[:from][:year ].to_i,
                        params[:from][:month].to_i,
                        params[:from][:day  ].to_i) if params[:from]
    @to =   Date.civil( params[:to  ][:year ].to_i,
                        params[:to  ][:month].to_i,
                        params[:to  ][:day  ].to_i) if params[:to]
    @tables = Table.find(:all)
    render :index
  end

  def ipod
    @tables = Table.all
  end

end
