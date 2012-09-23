# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module TablesHelper

  def get_color_array
    color_array = [
      [t(:violet), '#80477d'],
      [t(:orange), '#ed8b00'],
      [t(:pink), '#cd0052'],
      [t(:green), '#75b10d'],
      [t(:blue), '#136880'],
      [t(:blank), '#27343b']
    ]
  end
  
  def generate_color_style
    styles = "      
      option[value='#80477d'] { background-color: #80477d }
      option[value='#ed8b00'] { background-color: #ed8b00 }
      option[value='#cd0052'] { background-color: #cd0052 }
      option[value='#75b10d'] { background-color: #75b10d }
      option[value='#136880'] { background-color: #136880 }
      option[value='#27343b'] { background-color: #27343b }
    "
  end
  
end
