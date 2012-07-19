# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class StatisticsController < ApplicationController

  before_filter :check_permissions

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
