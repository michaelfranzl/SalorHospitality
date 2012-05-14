# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class Presentation < ActiveRecord::Base
  include Scope
  has_many :partials
  belongs_to :company
  belongs_to :vendor

  def secure_expand_markup
    allowed_attributes = ['NAME','PRICE','DESCRIPTION','PREFIX','POSTFIX']
    allowed_iterators = { "Category" => ['articles','options'], "Article" => ['quantities'] }
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
