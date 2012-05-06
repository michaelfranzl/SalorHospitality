# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class CompaniesController < ApplicationController

  def backup_database
    dbconfig = YAML::load(File.open('config/database.yml'))
    mode = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'
    username = dbconfig[mode]['username']
    password = dbconfig[mode]['password']
    database = dbconfig[mode]['database']
    `mysqldump -u #{username} -p#{password} #{database} > tmp/backup.sql`
    send_file 'tmp/backup.sql', :filename => "billgastro-backup-#{ l Time.now, :format => :datetime_iso2 }.sql"
  end

  def backup_logfile
    redirect_to reports_path and return if not File.exists? File.join(Rails.root, 'log', 'production.log')
    send_file File.join(Rails.root, 'log', 'production.log'), :filename => "billgastro-logfile-#{ l Time.now, :format => :datetime_iso2 }.log"
  end

end
