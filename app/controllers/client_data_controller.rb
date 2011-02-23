class ClientDataController < ApplicationController

  def show
    File.open('config/client_data.yaml', 'w') { |out|  YAML.dump(params[:data], out) } if params[:data]

    if File.exist?('config/client_data.yaml')
      @client_data = YAML.load_file( 'config/client_data.yaml' )
    else
      @client_data = {}
    end

  end

end
