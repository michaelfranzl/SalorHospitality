# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class ReportsController < ApplicationController

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
    dbconfig = YAML::load(File.open(SalorHospitality::Application.config.paths['config/database'].first))
    mode = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'
    username = dbconfig[mode]['username']
    password = dbconfig[mode]['password']
    database = dbconfig[mode]['database']
    `mysqldump -u #{username} -p#{password} #{database} > tmp/backup.sql`
    send_file 'tmp/backup.sql', :filename => "salor-hospitality-backup-#{ l Time.now, :format => :datetime_iso2 }.sql"
  end

  def backup_logfile
    redirect_to reports_path and return if not File.exists? File.join(Rails.root, 'log', 'production.log')
    send_file File.join(Rails.root, 'log', 'production.log'), :filename => "billgastro-logfile-#{ l Time.now, :format => :datetime_iso2 }.log"
  end
  
  def update_connection_status
    @status_ssh = not(`netstat -pna | grep :26`.empty?)
    @status_vnc = not(`netstat -pna | grep :28`.empty?)
    #@status_ssh = false
    #@status_vnc = false
    render :js => "connection_status = {ssh:#{@status_ssh}, vnc:#{@status_vnc}};"
  end

  def connect_remote_service
    if params[:type] == 'ssh'
      @status_ssh = `netstat -pna | grep :26`
      if @status_ssh.empty? # don't create more process than one
        connection_thread_ssh = fork do
          exec "expect #{ File.join('/', 'usr', 'share', 'remotesupport', 'remotesupportssh.expect').to_s } #{ params[:host] } #{ params[:user] } #{ params[:pw] }"
        end
        Process.detach(connection_thread_ssh)
      end
    end
    if params[:type] == 'vnc'
      @status_vnc = `netstat -pna | grep :28`
      if @status_vnc.empty? # don't create more process than one
        spawn "expect /usr/share/remotesupport/remotesupportvnc.expect #{ params[:host] } #{ params[:user] } #{ params[:pw] }", :out => "/tmp/salor-hospitality-x11vnc-stdout.log", :err => "/tmp/salor-hospitality-x11vnc-stderr.log"
      end
    end
    render :nothing => true
  end
end
