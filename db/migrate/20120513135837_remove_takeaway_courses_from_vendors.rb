class RemoveTakeawayCoursesFromVendors < ActiveRecord::Migration
  def change
    remove_column :vendors, :use_courses
    remove_column :vendors, :use_takeaway
  end
end
