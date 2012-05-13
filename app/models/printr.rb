# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class Printr

  def initialize(vendor_printers=nil)
    @open_printers = Hash.new
    if vendor_printers.kind_of?(ActiveRecord::Relation) or vendor_printers.kind_of?(Array)
      @vendor_printers = vendor_printers
    elsif vendor_printers.kind_of? VendorPrinter
      @vendor_printers = [vendor_printers]
    else
      paths = ['/dev/ttyUSB0', '/dev/ttyUSB1', '/dev/ttyUSB2', '/dev/usblp0', '/dev/usblp1', '/dev/usblp2', '/dev/billgastro-printer-front', '/dev/billgastro-printer-top', '/dev/billgastro-printer-back-top-right', '/dev/billgastro-printer-back-top-left', '/dev/billgastro-printer-back-bottom-left', '/dev/billgastro-printer-back-bottom-right']
      @vendor_printers = Hash.new
      paths.size.times do |i|
        @vendor_printers['x' + i.to_s] = VendorPrinter.new :name => /\/dev\/(.*)/.match(paths[i])[1], :path => paths[i], :copies => 1
      end
    end
  end

  def self.sanitize(text)
    text.force_encoding 'ISO-8859-15'
    char = ['ä', 'ü', 'ö', 'Ä', 'Ü', 'Ö', 'é', 'è', 'ú', 'ù', 'á', 'à', 'í', 'ì', 'ó', 'ò', 'â', 'ê', 'î', 'ô', 'û', 'ñ', 'ß']
    replacement = ["\x84", "\x81", "\x94", "\x8E", "\x9A", "\x99", "\x82", "\x8A", "\xA3", "\x97", "\xA0", "\x85", "\xA1", "\x8D", "\xA2", "\x95", "\x83", "\x88", "\x8C", "\x93", "\x96", "\xA4", "\xE1"]
    i = 0
    begin
      rx = Regexp.new(char[i].force_encoding('ISO-8859-15'))
      rep = replacement[i].force_encoding('ISO-8859-15')
      text.gsub!(rx, rep)
      i += 1
    end while i < char.length
    return text
  end

  def print(printer_id, text)
    return if @open_printers == {}
    ActiveRecord::Base.logger.info "[PRINTING]============"
    ActiveRecord::Base.logger.info "[PRINTING]PRINTING..."
    printer = @open_printers[printer_id]
    raise 'Mismatch between open_printers and printer_id' if printer.nil?
    ActiveRecord::Base.logger.info "[PRINTING]  Printing on #{ printer[:name] } @ #{ printer[:device].inspect.force_encoding('UTF-8') }."
    text.force_encoding 'ISO-8859-15'
    printer[:copies].times do |i|
      @open_printers[printer_id][:device].write text
    end
    @open_printers[printer_id][:device].flush
  end

  def identify
    ActiveRecord::Base.logger.info "[PRINTING]============"
    ActiveRecord::Base.logger.info "[PRINTING]TESTING Printers..."
    open
    @open_printers.each do |id, value|
      text =
      "\e@"     +  # Initialize Printer
      "\e!\x38" +  # doube tall, double wide, bold
      "#{ I18n.t :printing_test }\r\n" +
      "\e!\x00" +  # Font A
      "#{ value[:name] }\r\n" +
      "#{ value[:device].inspect.force_encoding('UTF-8') }" +
      "\n\n\n\n\n\n" +
      "\x1D\x56\x00" # paper cut at the end of each order/table
      ActiveRecord::Base.logger.info "[PRINTING]  Testing #{ value[:device].inspect }"
      out = "\e@" # Initialize Printer
      #0.upto(255) { |i| out += i.to_s(16) + i.chr }
      print id, Printr.sanitize(text)
    end
    close
  end

  def open
    ActiveRecord::Base.logger.info "[PRINTING]============"
    ActiveRecord::Base.logger.info "[PRINTING]INITIALIZE Printers..."
    @vendor_printers.each do |p|
      ActiveRecord::Base.logger.info "[PRINTING]  Trying to open #{ p.name } @ #{ p.path } ..."

      begin
        printer = SerialPort.new p.path, 9600
        @open_printers.merge! p.id => { :name => p.name, :path => p.path, :copies => p.copies, :device => printer }
        ActiveRecord::Base.logger.info "[PRINTING]    Success for SerialPort: #{ printer.inspect }"
        next
      rescue Exception => e
        ActiveRecord::Base.logger.info "[PRINTING]    Failed to open as SerialPort: #{ e.inspect }"
      end

      begin
        printer = File.open p.path, 'w:ISO-8859-15'
        @open_printers.merge! p.id => { :name => p.name, :path => p.path, :copies => p.copies, :device => printer }
        ActiveRecord::Base.logger.info "[PRINTING]    Success for File: #{ printer.inspect }"
        next
      rescue Errno::EBUSY
        ActiveRecord::Base.logger.info "[PRINTING]    The File #{ p.path } is already open."
        ActiveRecord::Base.logger.info "[PRINTING]      Trying to reuse already opened printers."
        previously_opened_printers = @open_printers.clone
        previously_opened_printers.each do |key, val|
          ActiveRecord::Base.logger.info "[PRINTING]      Trying to reuse already opened File #{ key }: #{ val.inspect }"
          if val[:path] == p[:path] and val[:device].class == File
            ActiveRecord::Base.logger.info "[PRINTING]      Reused."
            @open_printers.merge! p.id => { :name => p.name, :path => p.path, :copies => p.copies, :device => val[:device] }
            break
          end
        end
        unless @open_printers.has_key? p.id
          printer = File.open(Rails.root.join('tmp',"#{ p.id }-#{ p.name }.bill"), 'a:ISO-8859-15')
          @open_printers.merge! p.id => { :name => p.name, :path => p.path, :copies => p.copies, :device => printer }
          ActiveRecord::Base.logger.info "[PRINTING]      Failed to open as either SerialPort or USB File and resource IS busy. This should not have happened. Created #{ printer.inspect } instead."
        end
        next
      rescue Exception => e
        printer = File.open(Rails.root.join('tmp',"#{ p.id }-#{ p.name }.bill"), 'a:ISO-8859-15')
        @open_printers.merge! p.id => { :name => p.name, :path => p.path, :copies => p.copies, :device => printer }
        ActiveRecord::Base.logger.info "[PRINTING]    Failed to open as either SerialPort or USB File and resource is NOT busy. Created #{ printer.inspect } instead."
      end
    end
  end

  def close
    ActiveRecord::Base.logger.info "[PRINTING]============"
    ActiveRecord::Base.logger.info "[PRINTING]CLOSING Printers..."
    @open_printers.each do |key, value|
      begin
        value[:device].close
        ActiveRecord::Base.logger.info "[PRINTING]  Closing  #{ value[:name] } @ #{ value[:device].inspect }"
      rescue Exception => e
        ActiveRecord::Base.logger.info "[PRINTING]  Error during closing of #{ value[:device].inspect.force_encoding('UTF-8') }: #{ e.inspect }"
      end
    end
  end
  
end
