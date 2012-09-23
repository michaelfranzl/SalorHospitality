desc "Load seeds for multistore testing" 
namespace :testing do
  task :multistore => [:environment] do
    require "#{::Rails.root.to_s}/db/multistore.rb"
  end
end
