Escper.setup do |config|
  config.codepage_file = File.join(Rails.root, 'config', 'codepages.yml')
  
  if @mode != 'local' and SalorHospitality::Application::SH_DEBIAN_SITEID != 'none'
    config.use_safe_device_path = true
    config.safe_device_path = File.join('/', 'var', 'lib', 'salor-hospitality', SalorHospitality::Application::SH_DEBIAN_SITEID, 'public', 'uploads')
    #config.safe_device_path = File.join('/', 'tmp')
  end
end