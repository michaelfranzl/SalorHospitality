# coding: utf-8
require 'active_support'

module MyGlobals
  mattr_accessor :predefined_count, :blackboard_messages, :user_roles, :stock_units, :client, :language_hash, :language_array
  mattr_accessor :last_js_change, :last_order_number, :unused_order_numbers, :credits_left

  @@last_js_change = Time.now.strftime('%Y%m%dT%H%M%S')

  @@last_order_number = 0 #initial value if no orders yet present
  @@unused_order_numbers = Array.new
  @@credits_left = 0

  @@predefined_count = []
  0.upto(15) { |i|
    @@predefined_count << i
  }

  @@user_roles = [ ['',''], ['Restaurant',0], ['Kellner',1], ['Admin',2], ['Superuser',3] ]

  @@language_array = [ ['English','en'], ['Deutsch','de'], ['Türkçe','tr'] ]
  @@language_hash = { 'en' => 'English', 'de' => 'Deutsch', 'tr' => 'Türkçe' }

  
  @@blackboard_messages = { :special => '', :title => 'Speisekarte', :date => '' }
  @@stock_units = [ '', 'Flaschen', 'Bouteille', 'Magnum', 'Doppler', 'Liter', 'ml', 'kg', 'dag', 'g', 'ml', 'Packungen', 'Faesser', 'Stueck' ]    
  @@client = "local"

end
