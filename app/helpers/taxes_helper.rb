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
