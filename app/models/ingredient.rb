class Ingredient < ActiveRecord::Base
  belongs_to :commodity
  belongs_to :stock
end
