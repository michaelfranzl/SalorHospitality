class ClientDataController < ApplicationController

  def show
    @client_data = File.exist?('config/client_data.yaml') ? YAML.load_file( 'config/client_data.yaml' ) : {}
  end

  def create
    File.open('config/client_data.yaml', 'w') { |out|  YAML.dump(params[:data], out) } if params[:data]
  end
end
