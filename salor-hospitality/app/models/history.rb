# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class History < ActiveRecord::Base
  include Scope
  belongs_to :user
  belongs_to :model, :polymorphic => true
  belongs_to :company
  belongs_to :vendor
  
  before_create :set_fields
  
  def set_fields
    self.user = $User
    self.url = $Request.url if $Request
    self.params = $Params.to_json if $Params
    self.ip = $Request.ip if $Request
    self.vendor = $Vendor
    self.company = $Company
  end
  
  def self.record(action, object)
    return if $User.nil? or $Vendor.nil? or $Company.nil? or ($Request and $Request.url.include?("route")) # Do not record anything when nobody is logged in. History for the route action is done manually in Application Controller.
    
    h = History.new
    h.model = object
    h.action_taken = action
    changes = {}
    if object and object.respond_to? :changes then
      changes = object.changes
      # do not record the following attributes
      changes.delete('updated_at')
      changes.delete('created_at')
      changes.delete('last_active_at')
      changes.delete('resources_cache')
      h.changes_made = changes.to_json[0..200]
    end
    h.save unless changes == {}
  end
end
