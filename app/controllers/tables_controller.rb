class TablesController < ApplicationController
  def index
    @tables = Table.find(:all)
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
    @table.update_attributes(params[:table]) ? redirect_to(tables_path) : render(:new)
  end

  def destroy
    @table = Table.find(params[:id])
    flash[:notice] = "Der Tisch \"#{ @table.name }\" wurde erfolgreich geloescht."
    @table.destroy
    redirect_to tables_path
  end

end
