class Discount < ActiveRecord::Base
  has_and_belongs_to_many :orders
  belongs_to :category
  belongs_to :article
  include Scope
  include Base
  before_create :set_model_owner
  DTYPES = [
    [0,I18n.t("discounts.dtypes.fixed")],
    [1,I18n.t("discounts.dtypes.percent")],
  ]
  def dtype_name
    DTYPES.each do |ct|
      return ct[1] if ct[0] == self.dtype
    end
    return "Unknown"
  end
end
