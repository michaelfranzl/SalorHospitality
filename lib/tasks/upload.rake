desc 'Upload to stempel.railsjet.net and restart server'

task :upload do
  `touch tmp/restart.txt`
  `echo '' > log/development.log`
  `ncftpput -u stempel -p tSNw+EQ1 -m -R railsjet.net / ./*`
end
