class Email < ActiveRecord::Base
  include Scope
  include Base
  
  
  belongs_to :company
  belongs_to :vendor
end
