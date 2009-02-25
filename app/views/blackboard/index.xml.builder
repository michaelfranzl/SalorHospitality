xml.instruct! :xml, :version=>"1.0"
xml.menucard{
  xml.special(MyGlobals::blackboard_messages[:special])
  xml.date(MyGlobals::blackboard_messages[:date])
  xml.title(MyGlobals::blackboard_messages[:title])
  1.upto(3) do |category_id|
    xml << " <category#{category_id}>\n"
      for dish in Category.find(category_id).articles_in_blackboard
        xml.dish do
          xml << "  <name><![CDATA[#{html_escape_umlauts dish.format_name}]]></name>\n"
          xml << "  <price>#{'%.2f' % dish.price}</price>\n"
          xml << "  <division>#{dish.format_division}</division>\n"
        end
      end
    xml << " </category#{category_id}>\n"
  end
}
