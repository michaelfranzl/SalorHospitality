# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Presentation < ActiveRecord::Base
  include Scope
  has_many :partials
  belongs_to :company
  belongs_to :vendor
  validates_presence_of :name

  def secure_expand_markup
    allowed_attributes = ['NAME','PRICE','DESCRIPTION','PREFIX','POSTFIX']
    allowed_iterators = {
      "Category" => [
                     'articles',
                     'options'
                    ],
      "Article" => [
                    'quantities'
                   ]
    }
    modified_lines = Array.new
    self.markup.split("\n").each do |line|
      line.gsub! /<%.*?%>/, 'No dice!'
      if line.include? 'LOOP BEGIN'
        requested_iterator = /LOOP BEGIN (.*?)}}/.match(line)[1].downcase
        if allowed_iterators[self.model].include?(requested_iterator)
          line = "<% record.#{requested_iterator}.existing.active.each do |l| %>"
        else
          line = "<% begin %>"
        end
      end
      line.gsub! '%{{END}}', '<% end %>'
      line.gsub! '%{{BLURB}}', '<%= Kramdown::Document.new(partial.blurb).to_html %>'
      line.gsub!(/%{{LOOP.(.*?)}}/) { "<%= l.#{$1.downcase} %>" }
      line.gsub!(/%{{IF (.*?)}}/) { "<% if record.#{$1.downcase} %>" }
      line.gsub!(/%{{(.*?)}}/) { "<%= record.#{$1.downcase} %>" }
      modified_lines << line
    end
    return modified_lines.join("\n")
  end

  def secure_expand_code
    return ''
  end
end
