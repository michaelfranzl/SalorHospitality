class Partial < ActiveRecord::Base
  include Scope
  has_and_belongs_to_many :pages
  belongs_to :company
  belongs_to :vendor
  belongs_to :presentation
  belongs_to :article
  belongs_to :quantity
  belongs_to :category
  belongs_to :option
end
