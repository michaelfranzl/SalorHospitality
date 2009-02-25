desc 'Trim trailing spaces in source files to please git'

task :trim do
  `for i in \`find ./{app,config,lib,public/stylesheets} -type f | xargs\`; do sed -i 's/ *$//' $i; done`
end
