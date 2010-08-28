class Item < ActiveRecord::Base
  belongs_to :order
  belongs_to :article
  belongs_to :cost_center
  belongs_to :quantity
  has_many :item_options
  validates_presence_of :count, :article_id

  default_scope :order => 'sort DESC'
  
  def add_option(o)
    self.options << ItemOption.new {:value => o.value}
  end
  def remove_option(o)
    nos = []
    self.options.each do |io|
      unless io.value == o.value then
        nos << io
      end
    end
    self.connection.execute("delete from item_options where item_id = '#{self.id}'")
    self.options = nos
  end

end
