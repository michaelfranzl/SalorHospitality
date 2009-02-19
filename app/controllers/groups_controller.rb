class GroupsController < ApplicationController

  def index
    @groups = Group.find(:all)
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    @group.save ? redirect_to(groups_path) : render(:new)
  end

  def edit
    @group = Group.find(params[:id])
    render :new
  end

  def update
    @group = Group.find(params[:id])
    @group.update_attributes(params[:group]) ? redirect_to(groups_path) : render(:new)
  end

  def destroy
    @group = Group.find(params[:id])
    flash[:notice] = "Die Gruppe \"#{ @group.name }\" wurde erfolgreich geloescht."
    @group.destroy
    redirect_to groups_path
  end

end
