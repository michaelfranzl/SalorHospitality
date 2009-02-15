module ArticlesHelper

  def add_ingredient_link(caption, frm)

    link_to_function caption do |page|
      ingredient = render(:partial => 'ingredient', :locals => { :frm => frm, :ingredient => Ingredient.new })
      page << %{
        var new_ingredient_id = "new_" + new Date().getTime();
        $('ingredients').insert({ bottom: '<div id="' + new_ingredient_id + '">#{ escape_javascript ingredient }</div>'.replace(/new_\\d+/g, new_ingredient_id) });
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
        HighlightEffect($(new_ingredient_id));
      }
    end

  end

end
