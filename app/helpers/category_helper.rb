module CategoryHelper

  def generate_item_styles

    styles = "
      option[value='aperitif']:before { content:url('/images/category_aperitif.png'); }
      option[value='sidedish']:before { content:url('/images/category_sidedish.png'); }
      option[value='starter']:before { content:url('/images/category_starter.png'); }
      option[value='maindish']:before { content:url('/images/category_maindish.png'); }
      option[value='childrendish']:before { content:url('/images/category_childrendish.png'); }
      option[value='dessert']:before { content:url('/images/category_dessert.png'); }
      option[value='digestif']:before { content:url('/images/category_digestif.png'); }
      option[value='beer']:before { content:url('/images/category_beer.png'); }
      option[value='nonalcoholics']:before { content:url('/images/category_nonalcoholics.png'); }
      option[value='cigarette']:before { content:url('/images/category_cigarette.png'); }
      option[value='rosewineglass']:before { content:url('/images/category_rosewineglass.png'); }
      option[value='redwineglass']:before { content:url('/images/category_redwineglass.png'); }
      option[value='whitewineglass']:before { content:url('/images/category_whitewineglass.png'); }
      option[value='rosewinebottle']:before { content:url('/images/category_rosewinebottle.png'); }
      option[value='redwinebottle']:before { content:url('/images/category_redwinebottle.png'); }
      option[value='whitewinebottle']:before { content:url('/images/category_whitewinebottle.png'); }
      option[value='sparkling']:before { content:url('/images/category_sparkling.png'); }
      option[value='coffee']:before { content:url('/images/category_coffee.png'); }
      option[value='teapot']:before { content:url('/images/category_teapot.png'); }
      option[value='tea']:before { content:url('/images/category_tea.png'); }
      option[value='blank']:before { content:url('/images/category_blank.png'); }
      
      option[value='#80477d']:before { content:url('/images/color_violet.png'); }
      option[value='#ed8b00']:before { content:url('/images/color_orange.png'); }
      option[value='#cd0052']:before { content:url('/images/color_pink.png'); }
      option[value='#75b10d']:before { content:url('/images/color_green.png'); }
      option[value='#136880']:before { content:url('/images/color_blue.png'); }
      option[value='#27343b']:before { content:url('/images/color_blank.png'); }
    "
  end
  
end
