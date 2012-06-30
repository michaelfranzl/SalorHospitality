# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class ReportsController < ApplicationController

  before_filter :check_permissions

  def index
    @from, @to = assign_from_to(params)
    @from = @from ? @from.beginning_of_day : DateTime.now.beginning_of_day
    @to = @to ? @to.end_of_day : @from.end_of_day
    if params[:usb_device] and not params[:usb_device].empty? and File.exists? params[:usb_device] then
      @report = Report.new
      @report.dump_all(@from,@to,params[:usb_device])
      flash[:notice] = "Complete"
    end
  end

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
  
  def update_connection_status
    @status_ssh = not(`netstat -pna | grep :26`.empty?)
    @status_vnc = not(`netstat -pna | grep :28`.empty?)
    #@status_ssh = false
    #@status_vnc = true
    render :js => "connection_status = {ssh:#{@status_ssh}, vnc:#{@status_vnc}};"
  end

  def connect_remote_service
    if params[:type] == 'ssh'
      @status_ssh = `netstat -pna | grep :26`
      if @status_ssh.empty? # don't create more process than one
        connection_thread_ssh = fork do
          exec "expect #{ File.join('/', 'usr', 'share', 'red-e_ssh_reverse_connect.expect').to_s } #{ params[:host] } #{ params[:user] } #{ params[:pw] }"
        end
        Process.detach(connection_thread_ssh)
      end
    end
    render :nothing => true
  end
end
