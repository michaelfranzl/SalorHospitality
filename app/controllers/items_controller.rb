class ItemsController < ApplicationController

  def print
    @unprinted_items = Item.find_all_by_printed(false)
    respond_to do |wants|
      wants.html
      wants.bon {
        @unprinted_items.each do |ui|
          ui.update_attribute(:printed, true)
        end
        from = @unprinted_items.size - 21
        from = 0 if from < 0
        to = @unprinted_items.size - 1
        @print_items = @unprinted_items[from..to]
        render :text => generate_escpos_items(@print_items)
      }
    end
  end


  private
    def generate_escpos_items(unprinted_items)

      output = ''
      unprinted_items.each do |ui|
        next if ui.article.category.tax.percent != 10  # This is ugly but works for now

        output +=
        "\e@"     +  # Initialize Printer

        "\e!\x00" +  # Font A
        "\e!\x08" +  # Font A, emphasized
        "%-25.25s %15s\n" % [ui.order.user.title, ui.order.table.name] +

        "\e!\x38" +  # doube tall, double wide, bold
        "%u %-17.17s\n" % [ui.count, ui.article.name] +

        "\e!\x08" +  # Font A, emphasized
        "%-42.42s\n" % [ui.article.description] +

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
