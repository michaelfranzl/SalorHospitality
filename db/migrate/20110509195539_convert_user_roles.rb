class ConvertUserRoles < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      case u.role
      when 0
        u.update_attribute :role, 10
      when 1
        u.update_attribute :role, 20
      when 2
        u.update_attribute :role, 50
      when 3
        u.update_attribute :role, 60
      end
    end     
  end

  def self.down
    User.all.each do |u|
      case u.role
      when 10
        u.update_attribute :role, 0
      when 20
        u.update_attribute :role, 1
      when 50
        u.update_attribute :role, 2
      when 60
        u.update_attribute :role, 3
      end
    end   
  end
end
