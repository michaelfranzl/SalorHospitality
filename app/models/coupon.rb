class Coupon < ActiveRecord::Base
  include Scope
  belongs_to :company
  belongs_to :vendor
  has_and_belongs_to_many :orders
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
