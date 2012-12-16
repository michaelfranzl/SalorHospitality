class Camera < ActiveRecord::Base
  include Scope
  
  belongs_to :vendor
  belongs_to :company
  
  attr_accessible :company_id, :enabled, :hidden, :hidden_at, :hidden_by, :name, :url, :vendor_id, :port, :host_internal, :host_external
  
  validates_presence_of :name
  validates_presence_of :url
  validates_presence_of :port
  
  def resource(ip)
    match = /^(.*?)\.(.*?)\..*/.match(ip)
    if match.length == 3
      space = match[0] + '.' + match[1]
    else
      return "blank.gif"
    end
    if match[1] == "192" or match[1] == "10" or match[1] == "127" or (match[1] == "172" and match[2].to_i >= 16)
      mode = :internal
    else
      mode = :external
    end

    if mode == :internal
     return "#{ self.host_internal }:#{ self.port }#{ url }"
    elsif mode == :external
      return "#{ self.host_external }:#{ self.port }#{ url }"
    else
      return "blank.gif"
    end
  end
end
