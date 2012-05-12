# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

module ImageMethods
  def image
    return self.images.first.image unless Image.where(:imageable_id => self.id).count == 0
    return File.join("/assets", "empty.png")    
  end

  def thumb
    return self.images.first.thumb unless Image.where(:imageable_id => self.id).count == 0
    return File.join("/assets", "empty.png")    
  end
end
