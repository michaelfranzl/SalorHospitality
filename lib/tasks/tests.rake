desc "Load seeds for multistore testing" 
namespace :testing do
  task :multistore => [:environment] do
    require "#{RAILS_ROOT}/db/multistore.rb"
  end
end
