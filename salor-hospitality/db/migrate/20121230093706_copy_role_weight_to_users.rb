class CopyRoleWeightToUsers < ActiveRecord::Migration
  def up
    User.all.each do |u|
      u.role_weight = u.role.weight
      u.save
    end
  end

  def down
  end
end
