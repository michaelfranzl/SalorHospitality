class UserLogin < ActiveRecord::Base
  include Scope
  
  belongs_to :company
  belongs_to :vendor
  belongs_to :user
  
  before_save :set_duration
  
  def set_duration
    if self.login.nil?
      # this is a logout item
      last_login = self.user.user_logins.where(:logout => nil).last
      return 0 if last_login.nil?
      self.duration = (self.logout - last_login.login).to_i / 60 # duration is in minutes
      return self.duration
    end
  end
  
  def self.duration_formatted(seconds)
    duration_hours = seconds / 60.0
    hours = Integer(duration_hours)
    minutes = (duration_hours - hours) * 60
    return "#{ hours }:#{ "%02i" % minutes }"
  end
      
end
