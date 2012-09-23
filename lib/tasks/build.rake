desc "Build Debian package" 
task :build do
  `config/packages/makepackage.sh`
end
