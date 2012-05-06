module PresentationsHelper

  def get_model_names
    { 'Category' => Category.model_name.human,
      'Article' => Article.model_name.human,
      'Quantity' => Quantity.model_name.human,
      'Option' => Option.model_name.human,
      'Presentation' => Presentation.model_name.human
    }
  end
  
end
