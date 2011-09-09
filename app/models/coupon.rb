class Coupon < ActiveRecord::Base
  has_and_belongs_to_many :orders
  include Scope
  include Base
  before_create :set_model_owner
  CTYPES = [
    [0,I18n.t("coupons.ctypes.fixed")],
    [1,I18n.t("coupons.ctypes.percent")],
    [2,I18n.t("coupons.ctypes.b1g1")]
  ]
  def ctype_name
    CTYPES.each do |ct|
      return ct[1] if ct[0] == self.ctype
    end
    return "Unknown"
  end
end
