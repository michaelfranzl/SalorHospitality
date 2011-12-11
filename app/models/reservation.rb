class Reservation < ActiveRecord::Base
  include Scope
  belongs_to :table
  belongs_to :company
  belongs_to :vendor
  def from_json(json)
    self.fb_res_id = json["id"]
    self.fb_user_id = json["fb_user_id"]
    self.res_datetime = json["res_datetime"]
    self.party_size = json["res_num"]
    self.name = json["res_name"]
    self.email = json["res_email"]
    self.phone = json["res_phone"]
    t = Table.find_by_id(json["res_table"])
    self.table = t
    self.diet_restrictions = json["res_diet"]
    self.occasion = json["res_occasion"]
    self.honor = json["res_honor"]
    self.allergies = json["res_allergies"]
    self.other = json["res_other"]
    self.menu_selection = json["menu_selection"].to_json
  end
end
