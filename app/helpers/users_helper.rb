# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.

module UsersHelper

  def get_colors
    { '#80477d' => t(:violet),
      '#ed8b00' => t(:orange),
      '#cd0052' => t(:pink),
      '#75b10d' => t(:green),
      '#136880' => t(:blue),
      '#27343b' => t(:blank),
      '#BBBBBB' => t(:white),
      '#000000' => t(:black),
      '#d9d43d' => t(:yellow),
      '#801212' => t(:winered)
    }
  end
  
  def generate_color_style
    styles = "      
      option[value='#80477d'] { background-color: #80477d }
      option[value='#ed8b00'] { background-color: #ed8b00 }
      option[value='#cd0052'] { background-color: #cd0052 }
      option[value='#75b10d'] { background-color: #75b10d }
      option[value='#136880'] { background-color: #136880 }
      option[value='#27343b'] { background-color: #27343b }
      option[value='#BBBBBB'] { background-color: #BBBBBB }
      option[value='#000000'] { background-color: #000000 }
      option[value='#d9d43d'] { background-color: #d9d43d }
      option[value='#801212'] { background-color: #801212 }
    "
  end

end
