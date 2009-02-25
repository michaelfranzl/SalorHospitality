require 'active_support'

module MyGlobals
  mattr_accessor :predefined_count, :blackboard_messages, :user_roles, :stock_units

  @@predefined_count = []
  1.upto(15) { |i|
    @@predefined_count << i
  }

  @@blackboard_messages = { :special => '', :title => 'Speisekarte', :date => DateTime.now.strftime( '%d. %B %Y' ) }

  @@user_roles = [ '', 'su', 'Admin', 'Gasthaus', 'Kellner' ]

  @@stock_units = [ '', 'Flaschen', 'Bouteille', 'Magnum', 'Doppler', 'Liter', 'kg', 'Packungen', 'Fässer' ]

end
