# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def toggle_admin_interface
    toggle   =  "function toggle_admin_interface() {
                   Effect.toggle('admin', 'slide');
                   setTimeout('window.location.reload()', 1000);
                 }"
    return toggle
  end
  
end
