class RolesController < ApplicationController

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  def edit
    @role = Role.find(params[:id])
    render :new
  end

  def create
    @role = Role.new(params[:role])

    if @role.save
      redirect_to(roles_path, :notice => 'Role was successfully created.')
    else
      render :action => 'new'
    end
  end

  def update
    @role = Role.find(params[:id])

    if @role.update_attributes params[:role]
      redirect_to(roles_path, :notice => 'Role was successfully created.')
    else
      render :action => 'new'
    end
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
  end
end
