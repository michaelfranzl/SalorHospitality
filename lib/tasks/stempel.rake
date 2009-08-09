desc 'Upload and Restart stempel.datapoint.at'
task :upload_stempel => [:switch_stempel, :clear_logs] do
  `ncftpput -u stempel -p tSNw+EQ1 -m -R datapoint.at / ./*`
  touch('tmp/restart.txt')
  `ncftpput -u stempel -p tSNw+EQ1 -m -R datapoint.at /tmp ./tmp/restart.txt`
end

desc 'Switch to Stempel project'
task :switch_stempel do
  `sed -i 's/database:.*development/database: stempel_helper_development/' config/database.yml`
  `sed -i 's/database:.*test/database: stempel_helper_test/' config/database.yml`
  `sed -i 's/database:.*production/database: stempel_helper_production/' config/database.yml`
  `sed -i 's/password:.*/password: 5s7NR6JR/' config/database.yml`
  `sed -i 's/username:.*/username: stempel_helper/' config/database.yml`
  `sed -i 's/@@project = .*/@@project = "stempel"/' config/initializers/site_config.rb`
end
