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
    redirect_to '/' and return unless permit('download_database') or permit('download_csv') or permit('remote_support')
    
    @locations = Dir['/media/*']
    @locations << Dir['/home/*']
    @locations.flatten!
    @from, @to = assign_from_to(params)
    @models_for_csv = [Item]
    
    if params.has_key?(:fisc_save)
      return unless permit('download_database')
      zip_outfile = @current_vendor.fisc_dump(@from, @to, params[:location])
      redirect_to reports_path
      flash[:notice] = "Complete"
    elsif params.has_key?(:fisc_download)
      return unless permit('download_database')
      zip_outfile = @current_vendor.fisc_dump(@from, @to, '/tmp')
      send_file zip_outfile
    elsif params.has_key?(:csv_download)
      return unless permit('download_csv')
      csv_outfile = @current_vendor.csv_dump(params[:csv_type], @from, @to)
      send_data csv_outfile, :filename => "#{ params[:csv_type] }.csv" if csv_outfile
    end
  end
  
  def update_connection_status
    redirect_to '/' and return unless permit('remote_support')
    @status_ssh = not(`netstat -pna | grep :26`.empty?)
    @status_vnc = not(`netstat -pna | grep :28`.empty?)
    #@status_ssh = false
    #@status_vnc = false
    render :js => "connection_status = {ssh:#{@status_ssh}, vnc:#{@status_vnc}};"
  end

  def connect_remote_service
    redirect_to '/' and return unless permit('remote_support')
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
