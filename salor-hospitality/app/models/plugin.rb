# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'zip/zipfilesystem'
require 'json'

class Plugin < ActiveRecord::Base
  #attr_accessible :base_path, :company_id, :filename, :files, :hidden, :hidden_at, :hidden_by, :meta, :name, :user_id, :vendor_id
  
  include Scope
  include Base
  
  belongs_to :vendor
  belongs_to :company
  belongs_to :user
  
  serialize :meta
  
  validates_presence_of :vendor_id
  validates_presence_of :company_id
  #validates_presence_of :filename
  
  #validates_uniqueness_of :name
  
  DIRECTORY = File.join("public", "uploads", SalorHospitality::Application::SH_DEBIAN_SITEID)
  
  def base_path
    return File.join(DIRECTORY, self.vendor.hash_id, "plugins")
  end
  
  def full_path_zip
    return File.join(self.base_path, self.filename)
  end
  
  def full_path
    return full_path_zip.gsub(".zip", "")
  end
  
  def full_url
    return "/uploads/#{ SalorHospitality::Application::SH_DEBIAN_SITEID }/#{ self.vendor.hash_id }/plugins/#{ self.name }"
  end
  
  def filename=(data)
    FileUtils.mkdir_p(self.base_path)
    write_attribute :filename, data.original_filename   
    f = File.open(self.full_path_zip, "wb")
    f.write(data.read)
    f.close
  end
  
  def icon
    return "#{ self.full_url }/icon.svg"
  end
  
  def files
    _list = read_attribute(:files)
    log_action("I read: " + _list.inspect)
    if _list then
      return JSON.parse(_list)
    else
      return []
    end
  end
  
  def hide(by_id)
    self.hidden = true
    self.hidden_by = by_id
    self.hidden_at = Time.now
    self.save!
    if self.filename
      FileUtils.rm_rf(self.full_path)
      FileUtils.rm_rf(self.full_path_zip)
    end
  end
  
  def unzip
    _files = []
    
    FileUtils.rm_rf(self.full_path)
    FileUtils.mkdir(self.full_path)
    
    if self.filename.match(/\.zip$/) then
      Zip::ZipFile.foreach(self.full_path_zip) do |file|
        
        #log_action("creating dir " + self.full_path)
        #FileUtils.mkdir_p(self.full_path)
        
        basename = File.basename(file.name)
        target_filepath = File.join(self.full_path, basename)
        
        if basename.match(/\.svg$/) then
          log_action("It's an svg! " + target_filepath)
          write_file(file, target_filepath)
          _files << basename
          
        elsif file.name.match(/\.pl\.js$/) then
          log_action("It's the main plugin file " + target_filepath)
          write_file(file, target_filepath)
          write_attribute :name, File.basename(file.name).gsub(".pl.js",'')
          _files << basename
          
        elsif file.name.match(/\.js$/) then
          log_action("It's a js file" + target_filepath)
          write_file(file, target_filepath)
          _files << basename
          
        elsif file.name.match(/\.css$/) then
          log_action("It's a css file" + target_filepath)
          write_file(file, target_filepath)
          _files << basename
          
        elsif file.name.match(/\.html$/) then
          log_action("It's a html file" + target_filepath)
          write_file(file, target_filepath)
          _files << basename
        end
      end
    end
    log_action("Setting files to " + _files.inspect)
    self.files = _files
    self.save
  end
  
  private
  
  def files=(list)
    _list = list.to_json
    log_action("About to save: " + _list)
    write_attribute(:files, _list)
  end
  
  def write_file(zf,path)
    log_action("Writing file: " + path)
    File.open(path,"wb") do |f|
      f.write zf.get_input_stream.read
    end
    if not File.exists? path then
      log_action( "File: " + path + " could not be created!")
      raise "File: " + path + " could not be created!"
    else
      log_action(" Ruby says the file exists!!")
    end
  end
  
  
  
 
  

  
  
end
