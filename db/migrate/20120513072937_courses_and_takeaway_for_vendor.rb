class CoursesAndTakeawayForVendor < ActiveRecord::Migration
  def up
    add_column :vendors, :use_courses, :boolean, :default => true
    add_column :vendors, :use_takeaway, :boolean, :default => true
  end

  def down
    remove_column :vendors, :use_courses
    remove_column :vendors, :use_takeaway
  end
end
