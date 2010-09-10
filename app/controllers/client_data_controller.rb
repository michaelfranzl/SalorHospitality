class ClientDataController < ApplicationController

  def index
    if File.exist?('client_data.yaml')
      @client_data = YAML.load_file( 'client_data.yaml' )
    else
      @client_data = {}
    end
  end

  def update
    File.open( 'client_data.yaml', 'w' ) do |out|
      YAML.dump( params[:data], out )
    end
  end

end
