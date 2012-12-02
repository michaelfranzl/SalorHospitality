class AddRolesAndPermissions < ActiveRecord::Migration
  def up
#     role_names = {
#       'superuser' =>
#         {:weight => 0, :permissions => ['take_orders','decrement_items','delete_items','cancel_all_items_in_active_order','finish_orders','split_items','move_tables','refund','assign_cost_center','assign_order_to_booking','move_order','manage_articles','manage_categories','manage_options','finish_all_settlements','finish_own_settlement','view_all_settlements','manage_business_invoice','manage_statistics','manage_users','manage_taxes','manage_cost_centers','manage_payment_methods','manage_tables','manage_vendors','counter_mode','see_item_notifications_user_preparation','see_item_notifications_user_delivery','see_item_notifications_vendor_preparation','see_item_notifications_vendor_delivery','see_item_notifications_static','manage_pages','manage_customers','see_debug','manage_hotel','manage_roles','item_scribe','assign_tables','download_database','remote_support']},
#       'owner' =>
#         {:weight => 1, :permissions => ['take_orders','decrement_items','delete_items','cancel_all_items_in_active_order','finish_orders','split_items','move_tables','refund','move_order','manage_articles','manage_categories','manage_users','manage_taxes','manage_tables','manage_vendors'] },
#       'host' =>
#         {:weight => 2, :permissions => ['take_orders','decrement_items','delete_items','cancel_all_items_in_active_order','finish_orders','split_items','move_tables','refund','move_order','manage_articles','manage_categories','manage_users','manage_taxes','manage_tables'] },
#       'chief_waiter' =>
#         {:weight => 3, :permissions => ['take_orders','decrement_items','delete_items','cancel_all_items_in_active_order','finish_orders','split_items','move_tables','refund','move_order','manage_articles','manage_tables'] },
#       'waiter' =>
#         {:weight => 4, :permissions => ['take_orders','decrement_items','finish_orders','split_items','move_order']},
#       'auxiliary_waiter' =>
#         {:weight => 5, :permissions => ['take_orders','finish_orders']},
#       'terminal' =>
#         {:weight => 6, :permissions => ['take_orders'] },
#       'customer' =>
#         {:weight => 10, :permissions => [] }
#     }
#     
#     Role.reset_column_information
#     Company.all.each do |company|
#       c = company.id
#       company.vendors.all.each do |vendor|
#         v = vendor.id
#         role_objects = Array.new
#         role_names.to_a.size.times do |i|
#           role = vendor.roles.find_by_name(role_names.to_a[i][0])
#           unless role
#             role = Role.new :name => role_names.to_a[i][0], :permissions => role_names.to_a[i][1][:permissions], :weight => role_names.to_a[i][1][:weight]
#             role.company = company
#             role.vendor = vendor
#             r = role.save
#             role_objects << role
#             puts "Role #{ role_names.to_a[i][0] } #{ c } #{ v } #{ i } created" if r == true
#           end
#         end
#       end
#     end
  end

  def down
  end
end
