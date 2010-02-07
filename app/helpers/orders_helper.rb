module OrdersHelper

  def add_item_link(caption, frm, cat, cc)
    link_to_function caption do |body|
      item = render(:partial => 'item', :locals => { :frm => frm, :item => Item.new, :cat => cat, :cc => cc })
      body << %{
        var new_item_id = "new_" + new Date().getTime();
        var itemrow = "#{ escape_javascript item }";
        itemrow = itemrow.replace(/xxx\\d+/g, new_item_id);
        itemrow = itemrow.replace(/yyy/g, new_item_id.substr(-9,9));
        $('items').insert({ bottom: '<tr id="' + new_item_id + '">' + itemrow + '</tr>'});
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
