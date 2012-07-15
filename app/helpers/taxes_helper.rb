# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
