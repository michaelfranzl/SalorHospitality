# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
