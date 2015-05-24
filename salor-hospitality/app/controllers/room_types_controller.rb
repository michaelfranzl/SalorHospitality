# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class RoomTypesController < ApplicationController

  before_filter :check_permissions
  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    @room_types = @current_vendor.room_types.existing
  end

  def new
    @room_type = RoomType.new
  end

  def create
    permitted = params.require(:room_type).permit :name
    @room_type = RoomType.new permitted
    @room_type.vendor = @current_vendor
    @room_type.company = @current_company
    if @room_type.save
      redirect_to room_types_path
    else
      render(:new)
    end
  end

  def edit
    @room_type = RoomType.accessible_by(@current_user).existing.find_by_id(params[:id])
    render :new
  end

  def update
    @room_type = RoomType.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to room_types_path and return unless @room_type
    permitted = params.require(:room_type).permit :name
    if @room_type.update_attributes permitted
      redirect_to(room_types_path)
    else
      render(:new)
    end
  end

  def destroy
    @room_type = RoomType.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to room_types_path and return unless @room_type
    @room_type.update_attribute :hidden, true
    redirect_to room_types_path
  end

  private

    def check_permissions
      redirect_to '/' if not @current_user.role.permissions.include? 'manage_hotel'
    end
end
