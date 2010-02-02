module OrdersHelper

  def add_item_link(caption, frm, cat, cc)
    link_to_function caption do |body|
      "abc"
      item = render(:partial => 'item', :locals => { :frm => frm, :item => Item.new, :cat => cat, :cc => cc })
      body << %{
        var new_item_id = "new_" + new Date().getTime();
        $('items').insert({ bottom: '<tr id="' + new_item_id + '">#{ escape_javascript item }'.replace(/xxx\\d+/g, new_item_id) + '</tr>'});
        function HighlightEffect(element){
          new Effect.Highlight(element,
            {
              startcolor: "#ffff44",
              endcolor: "#ffffff",
              restorecolor: "#ffffff",
              duration: 3
            }
          )
        }
        HighlightEffect($(new_item_id));
      }
    end
  end
end
