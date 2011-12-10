class Partial < ActiveRecord::Base
  has_and_belongs_to_many :pages
  belongs_to :presentation
  belongs_to :article
  belongs_to :quantity
  belongs_to :category
  belongs_to :option
end
