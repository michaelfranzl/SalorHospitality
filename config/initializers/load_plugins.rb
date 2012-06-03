require 'yaml'

$config = YAML.load_file('/etc/salor.yml')
$config['plugins']['gems'].each do |plugin|
  require File.join($config['plugins']['path'], plugin, 'lib', "#{plugin}.rb")
end
