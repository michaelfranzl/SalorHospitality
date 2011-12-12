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

class VendorsController < ApplicationController

  before_filter :check_permission

  def index
    @vendors = Vendor.accessible_by @current_user
  end

  # Switches the current vendor and redirects to somewhere else
  def show
    @current_vendor = Vendor.accessible_by(@current_user).find_by_id(params[:id])
    session[:vendor_id] = params[:id]
    redirect_to vendors_path
  end

  # Edits the vendor if permitted, otherwise redirects to somewhere else
  def edit
    @vendor = Vendor.accessible_by(@current_user).find_by_id(params[:id])
    if @vendor
      @current_vendor = @vendor
      session[:vendor_id] = params[:id]
    else
      redirect_to vendors_path
    end
  end

  def update
    @vendor = Vendor.accessible_by(@current_user).find_by_id(params[:id])
    unless @vendor.update_attributes params[:vendor]
      @vendor.images.reload
      render(:edit) and return 
    end
    #test_printers :all
    #test_printers :existing
    @current_vendor = @vendor
    session[:vendor_id] = params[:id]
    redirect_to vendors_path
  end

  def backup_database
    dbconfig = YAML::load(File.open('config/database.yml'))
    mode = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'
    username = dbconfig[mode]['username']
    password = dbconfig[mode]['password']
    database = dbconfig[mode]['database']
    `mysqldump -u #{username} -p#{password} #{database} > public/backup.sql`
    send_file 'public/backup.sql', :filename => "billgastro-backup-#{ l Time.now, :format => :datetime_iso2 }.sql"
  end

  def backup_logfile
    send_file 'log/production.log', :filename => "billgastro-logfile-#{ l Time.now, :format => :datetime_iso2 }.log"
  end

end
