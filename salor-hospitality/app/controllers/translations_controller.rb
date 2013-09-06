class TranslationsController < ApplicationController
  
  before_filter :set_up
 
  def index
    render :nothing => true and return unless @origfile and File.exists?(@origfile)
    contents = File.read(@userfile)
    @translation = YAML::load(contents).to_json
  end
  
  def set
    render :nothing => true and return unless @origfile and File.exists?(@origfile)
    contents = File.read(@userfile)
    @translation = YAML::load(contents)
    keys = params['k'].split(',')
    @translation.replace_nested_value_by(keys,params['v'])
    File.open(@userfile,'w'){ |f| f.write @translation.to_yaml }
    render :nothing => true
  end
  
  private
  
  def set_up
    return if params['f'].nil? or params['f'].empty?
    @logdir = File.dirname(SalorHospitality::Application.config.paths['log'].first)
    @userfile = File.join(@logdir, params['f'])
    @localedir = File.dirname(SalorHospitality::Application.config.paths['config/locales'].first)
    @origfile = File.join(@localedir, params['f'])
    
#     puts
#     puts @logdir.inspect
#     puts @userfile
#     puts @localedir
#     puts @origfile
    
    return unless File.exists?(@origfile)
    
    unless File.exists?(@userfile)
      FileUtils.cp(@origfile, @logdir)
    end
  end
end
