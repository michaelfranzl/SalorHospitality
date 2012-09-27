# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class HistoryObserver < ActiveRecord::Observer
  #observe :order, :article, :item, :tax, :option, :quantity
  def after_update(object)
    sen = 1
    if [Order,Item,Option].include? object.class then
      send = 5
    end
    object.changes.keys.each do |k|
     if [:finished, :sum, :refund_sum, :price, :active,:hidden,:percent].include? k.to_sym then
       History.record("#{object.class.to_s.downcase}_edit",object,sen)
       return
     end
    end
  end
  def before_destroy(object)
    History.record("#{object.class.to_s.downcase}_destroyed",object,5)
  end
end
