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

class RolesController < ApplicationController

  before_filter :check_permissions

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
  end

  def edit
    @role = Role.find(params[:id])
    render :new
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      redirect_to roles_path
    else
      render :action => 'new'
    end
  end

  def update
    @role = Role.find(params[:id])
    if @role.update_attributes params[:role]
      redirect_to roles_path
    else
      render :action => 'new'
    end
  end

  private

    def check_permissions
      redirect_to '/' if not @current_user.role.permissions.include? 'manage_settings'
    end
end
