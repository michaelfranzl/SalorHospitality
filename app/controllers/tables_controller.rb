class TablesController < ApplicationController
  def index
    @tables = Table.find(:all)
  end

  def show
    @table = Table.find(params[:id])
    @unfinished_orders = Order.find_all_by_finished(false, :conditions => { :table_id => params[:id] })
    flash[:notice] = "#{ @table.name } ist frei." if !@unfinished_orders
    @cost_centers = CostCenter.all
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
    if request.xhr?
      @table.left = params[:pagexoffset].to_i  + params[:table][:left].to_i
      @table.top =  params[:pageyoffset].to_i  + params[:table][:top].to_i
      @table.save
    end
    respond_to do |wants|
      wants.html{ success ? redirect_to(tables_path) : render(:new)}
      wants.js { render :nothing => true }
    end
  end

  def destroy
    @table = Table.find(params[:id])
    flash[:notice] = "Der Tisch \"#{ @table.name }\" wurde erfolgreich geloescht."
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

end
