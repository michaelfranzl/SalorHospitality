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


desc 'Trim trailing spaces in source files in order to please git'
task :trim do
  `for i in \`find ./{app,config,db,lib,public/stylesheets,test} -type f | xargs\`; do sed -i 's/ *$//' $i; done`
end
