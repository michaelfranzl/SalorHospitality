class ClientDataController < ApplicationController

  def index
    if File.exist?('config/client_data.yaml')
      @client_data = YAML.load_file( 'config/client_data.yaml' )
    else
      @client_data = {}
    end
  end

  def update
    File.open('config/client_data.yaml', 'w') { |out|  YAML.dump(params[:data], out) }
  end

end
