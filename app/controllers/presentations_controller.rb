class PresentationsController < ApplicationController
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
    @presentation.save
    redirect_to presentations_path
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

end
