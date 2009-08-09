desc 'restart server'

task :restart do
  `touch tmp/restart.txt`
  `ncftpput -u fragebogen -p VeioIRBK -m -R corporateenergy.at /tmp tmp/restart.txt`
end
