module OrdersHelper

  def add_item_link(caption, frm, cat)
    link_to_function caption do |body|
      "abc"
      item = render(:partial => 'item', :locals => { :frm => frm, :item => Item.new, :cat => cat })
      body << %{
        var new_item_id = "new_" + new Date().getTime();
        $('items').insert({ bottom: '<tr id="' + new_item_id + '">#{ escape_javascript item }</tr>'.replace(/new_\\d+/g, new_item_id) });
        function HighlightEffect(element){
          new Effect.Highlight(element,
            {
              startcolor: "#ffff99",
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
