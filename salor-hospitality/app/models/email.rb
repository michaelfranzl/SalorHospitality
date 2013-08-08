class Email < ActiveRecord::Base
  include Scope
  
  belongs_to :company
  belongs_to :vendor
end
