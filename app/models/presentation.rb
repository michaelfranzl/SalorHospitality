class Presentation < ActiveRecord::Base
  has_many :partials
  
  scope :active, where(:active => true, :hidden => false)
  scope :existing, where('hidden=false or hidden is NULL')
  
  def markup=(txt)
    [["%LPER%","<%"],["%RPER%","%>"],["%LPEREQ%","<%="]].each do |rep|
      txt.gsub!(rep[0],rep[1])
    end 
    write_attribute(:markup,txt)
  end
  def markup
    txt = read_attribute(:markup)
    [["%LPER%","<%"],["%RPER%","%>"],["%LPEREQ%","<%="]].each do |rep|
      txt.gsub!(rep[0],rep[1])
    end 
    return txt
  end
end
