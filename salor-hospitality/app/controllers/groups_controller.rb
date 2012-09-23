# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
