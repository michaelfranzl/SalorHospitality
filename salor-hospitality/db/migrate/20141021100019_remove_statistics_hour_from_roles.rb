class RemoveStatisticsHourFromRoles < ActiveRecord::Migration
  def up
    Role.all.each do |r|
      r.permissions.delete("statistics_hour")
      result = r.save
      puts "Removing permission statistics_hour from Role ID #{ r.id }. Save result was #{ result }"
    end
  end

  def down
  end
end
