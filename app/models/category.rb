class Category < ActiveRecord::Base
  belongs_to :tax
  has_many :articles

  validates_presence_of :name, :tax_id

  def articles_in_menucard
    articles.find(:all, :conditions => 'menucard = 1', :order => 'format_sort_id ASC')
  end

  def articles_in_blackboard
    articles.find(:all, :conditions => 'blackboard = 1', :order => 'format_sort_id ASC')
  end

  def articles_in_waiterpad
    articles.find(:all, :conditions => 'waiterpad = 1', :order => 'format_sort_id ASC')
  end
end
