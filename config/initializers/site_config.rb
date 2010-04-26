require 'active_support'

module MyGlobals
  mattr_accessor :predefined_count, :blackboard_messages, :user_roles, :stock_units, :client, :last_js_change

  @@predefined_count = []
  0.upto(15) { |i|
    @@predefined_count << i
  }

  @@last_js_change = Time.now.strftime('%Y%m%dT%H%M%S')
  
  @@blackboard_messages = { :special => '', :title => 'Speisekarte', :date => '' }

  @@user_roles = [ ['',''], ['Restaurant',0], ['Kellner',1], ['Admin',2], ['Superuser',3] ]

  @@stock_units = [ '', 'Flaschen', 'Bouteille', 'Magnum', 'Doppler', 'Liter', 'ml', 'kg', 'dag', 'g', 'ml', 'Packungen', 'Fässer', 'Stueck' ]    

  @@client = "local"

end
