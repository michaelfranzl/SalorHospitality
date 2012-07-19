# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class PresentationsController < ApplicationController

  before_filter :check_permissions

  def index
    @presentations = @current_vendor.presentations.existing.active
  end
  
  def show
    @presentation = get_model
  end
  
  def new
    @presentation = Presentation.new
  end

  def edit
    @presentation = get_model
    render :new
  end
  
  def create
    @presentation = Presentation.new params[:presentation]
    @presentation.vendor = @current_vendor
    @presentation.company = @current_company
    if @presentation.save
      redirect_to presentations_path
    else 
      render 'new'
    end
  end

  def update
    @presentation = get_model
    @presentation.update_attributes params[:presentation]
    redirect_to presentations_path
  end

  def destroy
    @presentation = get_model
    @presentation.destroy
    redirect_to presentations_path
  end

  private

    def check_permissions
      redirect_to '/' if not @current_user.role.permissions.include? 'manage_pages'
    end

end
