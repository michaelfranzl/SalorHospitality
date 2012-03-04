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

class GroupsController < ApplicationController

  def index
    @groups = Group.accessible_by(@current_user).find(:all)
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    @group.save ? redirect_to(groups_path) : render(:new)
  end

  def edit
    @group = Group.accessible_by(@current_user).find(params[:id])
    render :new
  end

  def update
    @group = Group.accessible_by(@current_user).find(params[:id])
    @group.update_attributes(params[:group]) ? redirect_to(groups_path) : render(:new)
  end

  def destroy
    @group = Group.accessible_by(@current_user).find(params[:id])
    @group.destroy
    redirect_to groups_path
  end

end
