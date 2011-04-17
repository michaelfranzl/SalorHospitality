# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class StatisticsController < ApplicationController

  def index
  end

  def tables
    @from, @to = assign_from_to(params)
    @tables = Table.all
  end

  def weekdays
    @from, @to = assign_from_to(params)
    @weekdaysums = []
    0.upto 6 do |day|
      @weekdaysums[day] = Order.sum( 'sum', :conditions => "WEEKDAY(created_at)=#{day} AND created_at BETWEEN '#{@from.strftime('%Y-%m-%d %H:%M:%S')}' AND '#{@to.strftime('%Y-%m-%d %H:%M:%S')}'" )
    end
  end

  def users
    @from, @to = assign_from_to(params)
    @users = User.all
  end

  def journal
    @from, @to = assign_from_to(params)
    if not params[:cost_center_id] or params[:cost_center_id].empty?
      @orders = Order.find(:all, :conditions => { :created_at => @from..@to })
    else
      @orders = Order.find(:all, :conditions => { :created_at => @from..@to, :cost_center_id => params[:cost_center_id] })
    end
    @cost_centers = CostCenter.all
    render '/statistics/journal.csv' if params[:commit] == 'CSV'
  end

  def articles
    @from, @to = assign_from_to(params)
    Article.all.each do |a|
      @items = Item.find(:all, :conditions => { :created_at => @from..@to, :article_id => a.id })
      count = 0
      @items.each { |i| count += i.count }
      a.update_attribute :sort, count
      a.quantities.each do |q|
        @items = Item.find(:all, :conditions => { :created_at => @from..@to, :quantity_id => q.id })
        count = 0
        @items.each { |i| count += i.count }
        q.update_attribute :sort, count
      end
    end
    @articles_by_sort = Article.find(:all, :order => 'id ASC')
    @quantities_by_sort = Quantity.find(:all, :order => 'article_id ASC')
  end

  private

    def assign_from_to(p)
      f = Date.civil( p[:from][:year ].to_i,
                      p[:from][:month].to_i,
                      p[:from][:day  ].to_i) if p[:from]
      t = Date.civil( p[:to  ][:year ].to_i,
                      p[:to  ][:month].to_i,
                      p[:to  ][:day  ].to_i) if p[:to]
      f ||= 1.month.ago
      t ||= 0.day.ago
      return f, t
    end

end
