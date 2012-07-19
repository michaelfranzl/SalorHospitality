# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
