Escper.setup do |config|
  if SalorHospitality::Application::SH_DEBIAN_SITEID != 'none'
    config.codepage_file = File.join('/', 'etc', 'salor-hospitality', SalorHospitality::Application::SH_DEBIAN_SITEID, 'codepages.yml')
  else
    config.codepage_file = File.join(Rails.root, 'config', 'codepages.yml')
  end
  
  config.use_safe_device_path = SalorHospitality::Application::CONFIGURATION[:use_safe_device_path] == true ? true : false
  
  if SalorHospitality::Application::SH_DEBIAN_SITEID != 'none'
    config.safe_device_path = File.join('/', 'var', 'lib', 'salor-hospitality', SalorHospitality::Application::SH_DEBIAN_SITEID, 'public', 'uploads')
  end
end