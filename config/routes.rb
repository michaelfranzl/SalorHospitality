Billgastro2::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  resources :articles do
    collection do
      get 'quick_foods'
      get 'remove_all_foods_from_menucard'
      get 'listall'
      post 'update'
    end
  end

  resources :orders do
    collection do
      get 'separate_item'
      get 'print'
      get 'unsettled'
      get 'items'
      post 'toggle_admin_interface'
      post 'login'
      get 'split_invoice_all_at_once'
      get 'split_invoice_all_at_once'
    end
  end

  resources :options
  resources :settlements
  resources :categories
  resources :groups
  resources :stocks
  resources :cost_centers
  resources :taxes
  resources :menucard
  resources :waiterpad
  resources :blackboard

  resources :statistics do
    collection do
      get 'tables'
      get 'weekdays'
      get 'users'
      get 'journal'
      get 'articles'
    end
  end

  resources :users do
    resources :settlements
  end

  resources :tables do
    resources :orders
    collection do
      get :ipod
      get :update
    end
  end

  resource :session do
    collection do
      get :browser_warning
    end
  end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "orders#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
