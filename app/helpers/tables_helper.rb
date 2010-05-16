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
