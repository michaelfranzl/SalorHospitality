class DiscountsController < ApplicationController
  # GET /discounts
  # GET /discounts.xml
  def index
    @discounts = Discount.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @discounts }
    end
  end

  # GET /discounts/1
  # GET /discounts/1.xml
  def show
    @discount = Discount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @discount }
    end
  end

  # GET /discounts/new
  # GET /discounts/new.xml
  def new
    @discount = Discount.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @discount }
    end
  end

  # GET /discounts/1/edit
  def edit
    @discount = Discount.find(params[:id])
  end

  # POST /discounts
  # POST /discounts.xml
  def create
    @discount = Discount.new(params[:discount])

    respond_to do |format|
      if @discount.save
        format.html { redirect_to(@discount, :notice => 'Discount was successfully created.') }
        format.xml  { render :xml => @discount, :status => :created, :location => @discount }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @discount.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /discounts/1
  # PUT /discounts/1.xml
  def update
    @discount = Discount.find(params[:id])

    respond_to do |format|
      if @discount.update_attributes(params[:discount])
        format.html { redirect_to(@discount, :notice => 'Discount was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @discount.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /discounts/1
  # DELETE /discounts/1.xml
  def destroy
    @discount = Discount.find(params[:id])
    @discount.destroy

    respond_to do |format|
      format.html { redirect_to(discounts_url) }
      format.xml  { head :ok }
    end
  end
end
