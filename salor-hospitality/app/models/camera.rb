class Camera < ActiveRecord::Base
  include Scope
  
  belongs_to :vendor
  belongs_to :company
  
  attr_accessible :company_id, :enabled, :hidden, :hidden_at, :hidden_by, :name, :url, :vendor_id, :port, :host_internal, :host_external
  
  validates_presence_of :name
  validates_presence_of :url
  validates_presence_of :host_internal
  validates_presence_of :port
  
  def resource(mode=:internal)
    if mode == :internal
     return "http://#{ self.host_internal }:#{ self.port }/#{ url }"
    elsif mode == :external
      return "http://#{ self.host_external }:#{ self.port }/#{ url }"
    else
      return "blank.gif"
    end
  end
end
