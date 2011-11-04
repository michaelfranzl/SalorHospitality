class PresentationsController < ApplicationController
  def index
    @presentations = Presentation.existing
  end
  
  def show
    @presentation = Presentation.find_by_id params[:id]
  end
  
  def new
    @presentation = Presentation.new
  end

  def edit
    @presentation = Presentation.find_by_id params[:id]
    render :new
  end
  
  def create
    @presentation = Presentation.create params[:presentation]
    redirect_to presentations_path
  end

  def update
    @presentation = Presentation.find_by_id params[:id]
    @presentation.update_attributes params[:presentation]
    redirect_to presentations_path
  end

  def destroy
    @presentation = Presentation.find_by_id params[:id]
    @presentation.destroy
    redirect_to presentations_path
  end

end
