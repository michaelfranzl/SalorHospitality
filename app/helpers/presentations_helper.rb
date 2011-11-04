module PresentationsHelper

  def get_model_names
    { 'Category' => Category.human_name,
      'Article' => Article.human_name,
      'Quantity' => Quantity.human_name,
      'Option' => Option.human_name
    }
  end
  
end
