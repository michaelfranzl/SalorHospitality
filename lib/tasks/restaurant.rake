desc 'Upload and Restart restaurant.datapoint.net'
task :upload_restaurant => [:switch_restaurant, :clear_logs] do
  `ncftpput -u restaurant -p fVTWhSdc -m -R datapoint.at / ./*`
  `ncftpput -u restaurant -p fVTWhSdc -m -R datapoint.at /tmp ./tmp/restart.txt`
end

desc 'Switch to restaurant project'
task :switch_restaurant do
  `sed -i 's/database:.*development/database: restaurant_helper_development/' config/database.yml`
  `sed -i 's/database:.*test/database: restaurant_helper_test/' config/database.yml`
  `sed -i 's/database:.*production/database: restaurant_helper_production/' config/database.yml`
  `sed -i 's/password:.*/password: I8abGNET/' config/database.yml`
  `sed -i 's/username:.*/username: restaurant_hlp/' config/database.yml`
  `sed -i 's/@@project = .*/@@project = "restaurant"/' config/initializers/site_config.rb`
end

desc 'Clear Logs'
task :clear_logs do
  rm('log/development.log')
  rm('log/test.log')
  rm('log/production.log')
  rm('log/server.log')
  touch('log/development.log')
  touch('log/test.log')
  touch('log/production.log')
  touch('log/server.log')
  touch('tmp/restart.txt')
end
