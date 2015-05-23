desc 'This rake task compares the raw print data from SalorHospitality with the actual database. A second host must be set up to read raw data sent via RS232 and save it in a text file. This rake task downloads the raw printing data from this second host, parses it, and compares it with the database. This helper is escpecially useful when the user interface is automated with the excellent testing tool ichabod.'
task :ticketworker, [:url] => :environment do |t, args|
  
  all_article_names = Article.existing.collect {|a| a.name }

  loop {
    `wget -q -O tmp/ticketworker.txt 192.168.0.151/ticketworker.txt`
    #all_article_names = ["Article0000", "Article0010"]
    puts "\e[H\e[2J"
    all_article_names.each do |article|
      `grep #{ article } tmp/ticketworker.txt > tmp/grep.txt`
      lines = File.readlines "tmp/grep.txt"
      counts = lines.collect do |l|
        match = /(\d*?) .*/.match(l)[1].to_i
      end
      real_article = Article.find_by_name(article)
      item_count = Item.existing.where(:article_id => real_article.id).sum(:count)
      if counts.sum == item_count
        puts "\033[32m#{ article }: #{ counts.sum } == #{ item_count }"
      else
        puts "\033[31m#{ article }: #{ counts.sum } == #{ item_count }"
      end
    end
    puts "-----------------"
    puts "TOTAL: #{ Item.existing.sum(:count) }"
    sleep 5
  }
end