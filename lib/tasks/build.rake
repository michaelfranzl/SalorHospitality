desc "Build Debian package" 
task :build do
  `config/packages/makepackage.sh config/packages/billgastro`
end
