desc 'Clear Logs'
task :clear_logs do
  rm_rf('log/development.log')
  rm_rf('log/test.log')
  rm_rf('log/production.log')
  rm_rf('log/server.log')
  touch('log/development.log')
  touch('log/test.log')
  touch('log/production.log')
  touch('log/server.log')
  touch('tmp/restart.txt')
end


desc 'Convert german Latin 1 umlauts to utf8 and leave already existing german utf8 umlauts untouched'
task :iconv do
  from_to = {
              'ä' => '\xc3\xa4',
              'ö' => '\xc3\xb6',
              'ü' => '\xc3\xbc',
              'ß' => '\xc3\x9f',
              'Ä' => '\xc3\x84',
              'Ö' => '\xc3\x96',
              'Ü' => '\xc3\x9c'
            }
  from_to.each do |c|
     `sed -i 's/#{ c[0] }/#{ c[1] }/' config/locales/*de.yml`
  end
end



desc 'Trim trailing spaces in source files in order to please git'
task :trim do
  `for i in \`find ./{app,config,db,lib,public/stylesheets,test} -type f | xargs\`; do sed -i 's/ *$//' $i; done`
end
