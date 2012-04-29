# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class CompaniesController < ApplicationController

  def index
    render :edit
  end

  def update
    @current_company.update_attributes params[:company]
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

  def logo
    send_data @current_company.image, :type => @current_company.content_type, :filename => 'abc', :disposition => 'inline'
  end

end
