# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

module TaxesHelper

  def get_tax_colors
    { '#e3bde1' => t(:violet),
      '#f3d5ab' => t(:orange),
      '#ffafcf' => t(:pink),
      '#d2f694' => t(:green),
      '#c2e8f3' => t(:blue),
      '#c6c6c6' => t(:blank),
    }
  end
  
  def generate_tax_color_style
    styles = "
      option[value='#e3bde1'] { background-color: #e3bde1 }
      option[value='#f3d5ab'] { background-color: #f3d5ab }
      option[value='#ffafcf'] { background-color: #ffafcf }
      option[value='#d2f694'] { background-color: #d2f694 }
      option[value='#c2e8f3'] { background-color: #c2e8f3 }
      option[value='#c6c6c6'] { background-color: #c6c6c6 }
    "
  end

end
