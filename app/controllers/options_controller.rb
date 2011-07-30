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

class OptionsController < ApplicationController
  def index
    @categories = Category.all
  end

  def new
    @option = Option.new
    @categories = Category.all
  end

  def create
    @categories = Category.all
    @option = Option.new(params[:option])
    @option.save ? redirect_to(options_path) : render(:new)
  end

  def edit
    @categories = Category.all
    @option = Option.find(params[:id])
    render :new
  end

  def update
    @categories = Category.all
    @option = Option.find(params[:id])
    success = @option.update_attributes(params[:option])
    success ? redirect_to(options_path) : render(:new)
  end

  def destroy
    @option = Option.find(params[:id])
    @option.update_attribute :hidden, true
    redirect_to options_path
  end

  def sort
    params['option'].each do |id|
      o = Option.find_by_id id
      o.position = params['option'].index(o.id.to_s) + 1
      o.save
    end
    render :nothing => true
  end

end
