# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
class Company < ActiveRecord::Base
  include Scope
  include ImageMethods
  has_many :vendors
  has_many :users
  has_many :articles
  has_many :categories
  has_many :cost_centers
  has_many :customers
  has_many :groups
  has_many :images, :as => :imageable
  has_many :ingredients
  has_many :items
  has_many :options
  has_many :orders
  has_many :pages
  has_many :partials
  has_many :presentations
  has_many :quantities
  has_many :roles
  has_many :settlements
  has_many :tables
  has_many :roles
  has_many :taxes
  has_many :vendor_printers
  has_many :rooms
  has_many :room_types
  has_many :guest_types
  has_many :seasons
  has_many :surcharges
  has_many :room_prices
  has_many :bookings
  has_many :booking_items
  has_many :payment_methods
end
