ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'sessions', :action => 'new'

  # See how all your routes lay out with "rake routes"
  map.resources :articles, :collection => { :new_foods => :get, :remove_all_foods_from_menucard => :get, :listall => :get }
  map.resources :orders, :collection => { :unsettled => :get }
  map.resources :test
  map.resources :settlements
  map.resources :categories
  map.resources :groups
  map.resources :stocks
  map.resources :cost_centers
  map.resources :taxes
  map.resources :statistics, :collection => { :tables => :get, :weekdays => :get, :users => :get, :journal => :get, :articles => :get }
  map.resources :users, :has_many => :settlements
  map.resources :tables, :has_many => :orders
  map.resource :session, :collection => { :browser_warning => :get }


  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
  
  map.connect 'articles.:format/:action', :controller => 'index'
  map.connect 'blackboard.:format/:action', :controller => 'blackboard'

end
