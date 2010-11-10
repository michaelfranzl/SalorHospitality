namespace :db do
  desc "Dump the database to db/dump.sql" 
  # Adapted from http://blog.craigambrose.com/articles/2007/03/01/a-rake-task-for-database-backups
  task :dump do
    dbconfig = YAML::load(File.open('config/database.yml'))
    mode = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'
    username = dbconfig[mode]['username']
    password = dbconfig[mode]['password']
    database = dbconfig[mode]['database']
    `mysqldump -u #{username} -p#{password} #{database} > db/dump.sql`
  end
end
