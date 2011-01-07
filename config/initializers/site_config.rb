require 'active_support'

module MyGlobals
  mattr_accessor :predefined_count, :blackboard_messages, :user_roles, :stock_units, :client
  mattr_accessor :last_js_change, :last_order_number, :unused_order_numbers, :credits_left

  @@last_js_change = Time.now.strftime('%Y%m%dT%H%M%S')

  @@last_order_number = nil
  @@unused_order_numbers = Array.new
  @@credits_left = nil

  @@predefined_count = []
  0.upto(15) { |i|
    @@predefined_count << i
  }

  @@user_roles = [ ['',''], ['Restaurant',0], ['Kellner',1], ['Admin',2], ['Superuser',3] ]

  
  @@blackboard_messages = { :special => '', :title => 'Speisekarte', :date => '' }
  @@stock_units = [ '', 'Flaschen', 'Bouteille', 'Magnum', 'Doppler', 'Liter', 'ml', 'kg', 'dag', 'g', 'ml', 'Packungen', 'Fässer', 'Stueck' ]    
  @@client = "local"

end
