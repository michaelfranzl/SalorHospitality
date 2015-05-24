# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Surcharge < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  belongs_to :season
  belongs_to :guest_type
  has_many :surcharge_items
  has_many :taxes, :through => :tax_amounts
  has_many :tax_amounts

  serialize :taxes

  accepts_nested_attributes_for :tax_amounts, :allow_destroy => true, :reject_if => proc { |attrs| attrs['amount'] == '' }

  validates_presence_of :name

  def calculate_totals
    amount = 0.0
    self.tax_amounts.existing.each do |ta|
      amount += ta.amount
    end
    self.amount = amount
    self.save
  end

  def self.create_including_all_relations(vendor, params)
    guest_types = vendor.guest_types.existing
    seasons = vendor.seasons.existing
    surcharge = nil
    seasons.each do |s|
      if params['common_surcharge'] == '1'
        # this matches one single surcharge
        surcharge = vendor.surcharges.where(
          :season_id => s.id,
          :guest_type_id => nil,
          :name => params[:surcharge][:name],
          :hidden => nil).first
        unless surcharge
          # create if not yet existing
          surcharge = Surcharge.create(
            :season_id => s.id,
            :guest_type_id => nil,
            :name => params[:surcharge][:name],
            :vendor_id => vendor.id,
            :company_id => vendor.company.id
          )
        end
      else
        guest_types.each do |gt|
          gt_id = params[:common_surcharge] ? nil : gt.id 
          # this matches one single surcharge
          surcharge = vendor.surcharges.where(
            :season_id => s.id,
            :guest_type_id => gt_id,
            :name => params[:surcharge][:name],
            :hidden => nil).first
          unless surcharge
            # create if not yet existing
            surcharge = Surcharge.create(
              :season_id => s.id,
              :guest_type_id => gt_id,
              :name => params[:surcharge][:name],
              :vendor_id => vendor.id,
              :company_id => vendor.company.id
            )
          end
        end
      end
    end
    return surcharge
  end

  def update_all_relations(params, old_name)
    vendor = self.vendor
    seasons = vendor.seasons.existing
    guest_types = vendor.guest_types.existing
    guest_types << nil
    seasons.each do |s|
      guest_types.each do |gt|
        gt_id = gt ? gt.id : nil
        # this should match only one surcharge at a time
        surcharge = vendor.surcharges.where(
          :guest_type_id => gt_id,
          :season_id => s.id,
          :name => old_name)
        surcharge.update_all(
          :name => params[:surcharge][:name],
          :radio_select => self.radio_select,
          :selected => self.selected,
          :visible => self.visible
        )
      end
    end
  end

  def delete_including_all_relations(vendor)
    vendor = self.vendor
    seasons = vendor.seasons.existing
    guest_types = vendor.guest_types.existing
    guest_types << nil
    seasons.each do |s|
      guest_types.each do |gt|
        gt_id = gt ? gt.id : nil
        # this should match only one surcharge at a time
        surcharges = vendor.surcharges.where(
          :guest_type_id => gt_id,
          :season_id => s.id,
          :name => self.name)
        surcharges.update_all :hidden => true
      end
    end
  end
end
