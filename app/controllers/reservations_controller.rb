require 'net/http'
require 'json'
class ReservationsController < ApplicationController
  # GET /reservations
  # GET /reservations.xml
  def index
    @reservations = Reservation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reservations }
    end
  end

  # GET /reservations/1
  # GET /reservations/1.xml
  def show
    @reservation = Reservation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reservation }
    end
  end

  # GET /reservations/new
  # GET /reservations/new.xml
  def new
    @reservation = Reservation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reservation }
    end
  end

  # GET /reservations/1/edit
  def edit
    @reservation = Reservation.find(params[:id])
  end

  # POST /reservations
  # POST /reservations.xml
  def create
    @reservation = Reservation.new(params[:reservation])

    respond_to do |format|
      if @reservation.save
        format.html { redirect_to(@reservation, :notice => 'Reservation was successfully created.') }
        format.xml  { render :xml => @reservation, :status => :created, :location => @reservation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reservation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reservations/1
  # PUT /reservations/1.xml
  def update
    @reservation = Reservation.find(params[:id])

    respond_to do |format|
      if @reservation.update_attributes(params[:reservation])
        format.html { redirect_to(@reservation, :notice => 'Reservation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reservation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reservations/1
  # DELETE /reservations/1.xml
  def destroy
    @reservation = Reservation.find(params[:id])
    @reservation.destroy

    respond_to do |format|
      format.html { redirect_to(reservations_url) }
      format.xml  { head :ok }
    end
  end
  
  def fetch
    path = "/billgastro/fetch_reservations.php"
    cpath = "/billgastro/confirm_reservation"
    host = "allenbranson.com"
    port = 80
    req = Net::HTTP::Get.new(path, initheader = {'Content-Type' =>'application/json'})
    response = Net::HTTP.new(host, port).start {|http| http.request(req) }
    response = JSON.parse(response.body)
    if response.any? then
      response.each do |res|
        r = Reservation.new
        r.from_json(res)
        if r.save then
          req2 = Net::HTTP::Get.new(cpath + "?id=#{res["id"]}&confirm=1", initheader = {'Content-Type' =>'application/json'})
          resp2 = Net::HTTP.new(host, 80).start {|http| http.request(req2) }
        end
      end
    end
    redirect_to :action => :index
  end
  private
  def http_get(domain,path,params)
      return Net::HTTP.get(domain, "#{path}?".concat(params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&'))) if not params.nil?
      return Net::HTTP.get(domain, path)
  end

end

