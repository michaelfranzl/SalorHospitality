desc 'Upload to stempel.railsjet.net and restart server'

task :upload do
  `touch tmp/restart.txt`
  `ncftpput -u stempel -p tSNw+EQ1 -m -R railsjet.net / ./*`
end

task :trim_trailing_spaces do
end
