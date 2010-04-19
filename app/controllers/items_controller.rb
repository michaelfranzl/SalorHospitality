class ItemsController < ApplicationController

  def print
    respond_to do |wants|
      wants.html
      wants.bon {
        render :text => generate_escpos_items
      }
    end
  end


  private
    def generate_escpos_items

      output = ''
      Order.find_all_by_finished(false).each do |order|

        output +=
        "\e@"     +  # Initialize Printer

        "\e!\x00" +  # Font A
        "\e!\x08" +  # Font A, emphasized
        "%-25.25s %15s\n" % [order.user.title, order.table.name] +
        "\n\n\n"

        unprinted_items = Item.find(:all, :conditions => { :order_id => order.id, :printed => false } )
        next if unprinted_items.size.zero?
        unprinted_items.each do |ui|
          ui.update_attribute(:printed, true)
          next if ui.article.category.tax.percent != 10  # This is ugly but works for now

          output +=

          "\e!\x38" +  # doube tall, double wide, bold
          "%u %-17.17s\n" % [ui.count, ui.article.name] +

          "\e!\x08" +  # Font A, emphasized
          "%-42.42s\n" % [ui.article.description] +

          "\n\n\n"
        end

        output +=
        "\n\n\n\n\n\n" +
        "\x1DV\x00" # paper cut

      end

      output = Iconv.conv('ISO-8859-15','UTF-8',output)

      output.gsub!(/\xE4/,"\x84") #ä
      output.gsub!(/\xFC/,"\x81") #ü
      output.gsub!(/\xF6/,"\x94") #ö
      output.gsub!(/\xC4/,"\x8E") #Ä
      output.gsub!(/\xDC/,"\x9A") #Ü
      output.gsub!(/\xD6/,"\x99") #Ö
      output.gsub!(/\xDF/,"\xE1") #ß
      output.gsub!(/\xE9/,"\x82") #é
      output.gsub!(/\xE8/,"\x7A") #è
      output.gsub!(/\xFA/,"\xA3") #ú
      output.gsub!(/\xF9/,"\x97") #ù
      output.gsub!(/\xC9/,"\x90") #É

      return output
    end

end
