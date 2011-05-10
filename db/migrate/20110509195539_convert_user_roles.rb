class ConvertUserRoles < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      case u.role
      when 0
        u.update_attribute :role, 10
      when 1
        u.update_attribute :role, 30
      when 2
        u.update_attribute :role, 60
      when 3
        u.update_attribute :role, 70
      end
    end     
  end

  def self.down
    User.all.each do |u|
      case u.role
      when 10
        u.update_attribute :role, 0
      when 30
        u.update_attribute :role, 1
      when 60
        u.update_attribute :role, 2
      when 70
        u.update_attribute :role, 3
      end
    end   
  end
end
