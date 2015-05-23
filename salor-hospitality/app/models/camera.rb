class Camera < ActiveRecord::Base
  include Scope
  
  belongs_to :vendor
  belongs_to :company
  
  validates_presence_of :name
  validates_presence_of :url_stream
  validates_presence_of :url_snapshot
  validates_presence_of :host_internal
  validates_presence_of :port
  
  def resource(ip, mode='stream')
    match = /^(.*?)\.(.*?)\..*/.match(ip)
    if match.length == 3
      space = match[0] + '.' + match[1]
    else
      return "blank.gif"
    end
    if match[1] == "192" or match[1] == "10" or match[1] == "127" or (match[1] == "172" and match[2].to_i >= 16)
      user_location = :internal
    else
      user_location = :external
    end

    url_method = "url_" + mode
    if user_location == :internal
     return "#{ self.host_internal }:#{ self.port }#{ self.send(url_method) }"
    elsif user_location == :external
      return "#{ self.host_external }:#{ self.port }#{ self.send(url_method) }"
    else
      return "blank.gif"
    end
  end
end
