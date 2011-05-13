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

class SessionsController < ApplicationController

  skip_before_filter :fetch_logged_in_user, :set_locale

  def new
    @users = User.all
  end

  def create
    @current_user = User.find_by_login_and_password params[:login], params[:password]
    @users = User.all
    if @current_user
      session[:user_id] = @current_user
      I18n.locale = @current_user.language
      session[:admin_interface] = !mobile? # admin panel per default on on workstation
      flash[:error] = nil
      flash[:notice] = nil
      redirect_to '/orders'
    else
      flash[:error] = t :wrong_password
      render :new
    end
  end

  def destroy
    @current_user = session[:user_id] = nil
    redirect_to '/'
  end

  def catcher
    redirect_to '/'
  end
end
