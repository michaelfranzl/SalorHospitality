module Base

  def log_action(txt="",color=:green)
    from = self.class.to_s
    Base.log_action(from, txt, color)
  end
    
  def self.log_action(from="",txt="",color=:green)
    colors = {
      :black          => "\e[0;30;49m",
      :red            => "\e[0;31;49m",
      :green          => "\e[0;32;49m",
      :yellow         => "\e[0;33;49m",
      :blue           => "\e[0;34;49m",
      :magenta        => "\e[0;35;49m",
      :cyan           => "\e[0;36;49m",
      :white          => "\e[0;37;49m",
      :default        => "\e[0;39;49m",
      :light_black    => "\e[0;40;49m",
      :light_red      => "\e[0;91;49m",
      :light_green    => "\e[0;92;49m",
      :light_yellow   => "\e[0;93;49m",
      :light_blue     => "\e[0;94;49m",
      :light_magenta  => "\e[0;95;49m",
      :light_cyan     => "\e[0;96;49m",
      :light_white    => "\e[0;97;49m",
      :grey_on_red    => "\e[0;39;44m",
    }
    fromcolor = colors[:light_yellow]
    normalcolor = colors[:default]
    txtcolor = colors[color]
    if Rails.env == "development" then
      File.open("#{Rails.root}/log/development-history.log",'a') do |f|
        f.puts "##[#{fromcolor}#{from}] #{txtcolor}#{txt}#{normalcolor}\n"
      end
    end
    output = "#####[#{ fromcolor}#{from}] #{txtcolor}#{txt}#{ normalcolor }"
    ActiveRecord::Base.logger.info output
    puts output
  end
end