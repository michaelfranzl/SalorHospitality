# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.
class HistoryObserver < ActiveRecord::Observer
  observe :order, :article, :item, :tax, :option, :quantity
  def after_update(object)
    sen = 1
    if [Order,Item,Option].include? object.class then
      send = 5
    end
    object.changes.keys.each do |k|
     if [:finished, :sum, :storno_sum, :price, :active,:hidden,:percent].include? k.to_sym then
       History.record("#{object.class.to_s.downcase}_edit",object,sen)
       return
     end
    end
  end
  def before_destroy(object)
    History.record("#{object.class.to_s.downcase}_destroyed",object,5)
  end
end
