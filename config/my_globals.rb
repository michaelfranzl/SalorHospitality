require 'active_support'

module MyGlobals
  mattr_accessor :predefined_count

  @@predefined_count = Array.new
  1.upto(15) { |i|
    @@predefined_count << i
  }
end
