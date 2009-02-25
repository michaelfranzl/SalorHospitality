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
     `sed -i 's/#{ c[0] }/#{ c[1] }/' config/locales/de.yml`
  end

end
