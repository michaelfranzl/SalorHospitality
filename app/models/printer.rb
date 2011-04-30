# coding: utf-8
require 'yaml'
require 'erb'
class Printer
  attr_accessor :printers,:codes
  def initialize(company,saas=false)
    @printers = {}
    # You can access these within the views by calling @printer.codes, or whatever
    # you named the instance variable, as it will be snagged by the Binding
    @codes = {
      :init => "\e@",
      :dbltall => "\e!",
      :dblwde => "\x38",
      :hr => "=====================\n",
      :header => "\e@\e!\x38",
      :footer => "\n\n\n\n\x1DV\x00\x16\x20105"
    }
    @sanitize_tokens = [/ä/,"ae",/ü/,"ue",/ö/,"oe",/Ä/,"Ae",/Ü/,"Ue",/Ö/,"Oe",/É/,"E",/ß/,"sz",/é|è/,"e",/ú|ù/,"u"]
    @conf = YAML::load(File.open("#{RAILS_ROOT}/config/printers.yml")) 
    # You can override the above codes in the printers.yml, to add
    # say an ASCII header or some nonsense, or if they are using a
    # standard printer etc etc.
    if @conf[:codes] then
      @conf[:codes].each do |key,value|
        @codes[key.to_sym] = value
      end
    end
    init
  end
  def init
    @conf.each do |key,value|
      key = key.to_sym
      puts "[PRINTING]  Trying to open #{key}..."
       begin
         @printers[key] =  SerialPort.new(path,9600)
         puts "[PRINTING] Success for SerialPort: #{ BillGastro::Application::printers[i].inspect }"
       rescue Exception => e
         puts "[PRINTING]    Failed to open as SerialPort: #{ e.inspect }"
         @printers[key] = nil
       end
       next if @printers[key]
       # Try to open it as USB
       begin 
         @printers[key] = File.open(path,'w:ISO8859-15')
       rescue Errno::EBUSY
         @conf.each do |k,v|
           if @printers[k] and @printers[k].class == File then
             @printers[key] = @printers[k] 
             puts "[PRINTING]      Reused."
           end
         end
       rescue Exception => e
         @printers[key] = BillGastro::DummyPrinter.new(key)
         puts "[PRINTING]    Failed to open as either SerialPort or USB File. Created #{ @printers[key].inspect } instead."
       end 
     end
  end
  def test(key)
    
  end
  def close
    puts "[PRINTING]============"
    puts "[PRINTING]CLOSING Printers..."
    @printers.map do |p| 
      begin
        p.close
      rescue
      end
      p = nil
    end
  end
  def logger
    ActiveRecord::Base.logger
  end
  def print_to(key,text)
    begin
      text = sanitize(text)
      case @printers[key].class
        when File
          @printers[key].write text
          @printers[key].flush
        when SerialPort
          @printers[key].write text
        else
          @printers[key].write text
        end
    rescue
      close
    end
  end
  def method_missing(sym, *args, &block)
    if @printers[sym] then
      if args[1].class == Binding then
        print_to(sym,template(args[0],args[1])) #i.e. you call @printer.kitchen('item',binding)
      else
        print_to(sym,args[0])
      end
    end
  end
  def sanitize(text)
    i = 0
    begin
      text.gsub!(@sanitize_tokens[i],@sanitize_tokens[i+1])
      i += 2
    end while i < @sanitize_tokens.length
    text
  end
  def template(name,bndng)
    begin
      erb = ERB.new(File.new("#{RAILS_ROOT}/app/views/printer/#{name}.prnt.erb",'r').read)
    rescue Exception => e
      puts e.inspect
    end
    text = erb.result(bndng)
    return text
  end
end
