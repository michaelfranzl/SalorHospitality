# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def toggle_admin_interface
    toggle   =  "function toggle_admin_interface() {
                   Effect.toggle('admin', 'slide');
                 }"
    return toggle
  end

  def onload_functions
    function = 'function onload_function() {}'
    function = 'function onload_function() { document.getElementById("order_sum").value = "33"; }'
    return function
  end
end
