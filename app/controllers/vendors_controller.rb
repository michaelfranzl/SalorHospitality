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

  def index
    render :edit
  end

  def update
    unless @current_company.update_attributes params[:company]
      @current_company.images.reload
      render(:edit) and return 
    end
    test_printers :all
    test_printers :existing
    flash[:notice] = t 'companies.update.config_successfully_updated'
    redirect_to companies_path
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
