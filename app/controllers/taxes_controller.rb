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

class TaxesController < ApplicationController
  def index
    @taxes = Tax.scopied.existing
  end

  def new
    @tax = Tax.new
  end

  def create
    @tax = Tax.new(params[:tax])
    @tax.save ? redirect_to(taxes_path) : render(:new)
  end

  def edit
    @tax = Tax.scopied.find(params[:id])
    render :new
  end

  def update
    @tax = Tax.scopied.find(params[:id])
    @tax.update_attributes(params[:tax]) ? redirect_to(taxes_path) : render(:new)
  end

  def destroy
    @tax = Tax.scopied.find(params[:id])
    @tax.update_attribute :hidden, true
    redirect_to taxes_path
  end

end
