# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Page < ActiveRecord::Base
  include ImageMethods
  include Scope
  belongs_to :vendor
  belongs_to :company
  belongs_to :customer
  has_and_belongs_to_many :partials
  has_many :images, :as => :imageable

  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank
  
  def evaluate_partial_htmls
    partials = self.partials
    partial_htmls = []
    partials.each do |partial|
      # the following 3 class varibles are needed for rendering the _partial partial
      record = partial.presentation.model.constantize.find_by_id partial.model_id
      begin
        eval partial.presentation.secure_expand_code
        partial_htmls[partial.id] = ERB.new(partial.presentation.secure_expand_markup).result binding
      rescue Exception => e
        partial_htmls[partial.id] = I18n.t('partials.error_during_evaluation') + e.message
      end
      partial_htmls[partial.id].force_encoding('UTF-8')
    end
    return partial_htmls
  end
end
