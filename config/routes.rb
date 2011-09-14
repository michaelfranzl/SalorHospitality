BillGastro::Application.routes.draw do
  get "reservations/fetch"
  get "orders/attach_coupon"
  get "orders/attach_discount"
  resources :reservations

  resources :discounts

  get "coupons/coupons_list"
  resources :coupons

  resources :roles

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
      get  :listall
      post :find
      post :sort
      get  :sort_index
      get  :update_cache
      post :change_scope
    end
  end

  resources :orders do
    collection do
      post :toggle_admin_interface
      post :login
      get :storno
      get :last_invoices
      post :receive_order_attributes_ajax
      get :logout
    end
  end

  match 'orders/print_and_finish/:id/:port' => 'orders#print_and_finish'
  match 'orders/storno/:id' => 'orders#storno'
  match 'items/rotate_tax/:id' => 'items#rotate_tax'
  match 'orders/toggle_tax_colors/:id' => 'orders#toggle_tax_colors'
  match 'settlements/detailed_list' => 'settlements#detailed_list'
  match 'settlements/print/:id' => 'settlements#print'
  match 'sessions/exception_test' => 'sessions#exception_test'
  match 'companies/backup_database' => 'companies#backup_database'
  match 'companies/backup_logfile' => 'companies#backup_logfile'
  match 'company/logo' => 'companies#logo'

  resources :items, :companies, :cost_centers, :taxes, :users, :menucard, :waiterpad

  resources :categories do
    collection do
      post :sort
    end
  end

  resources :options do
    collection do
      post :sort
    end
  end

  resources :quantities do
    collection do
      post :sort
    end
  end

  resources :settlements do
    collection do
      get :open
    end
  end

  resources :statistics do
    collection do
      get 'tables'
      post 'tables'
      get 'weekdays'
      post 'weekdays'
      get 'users'
      post 'users'
      get 'journal'
      post 'journal'
      get 'articles'
      post 'articles'
    end
  end

  resources :tables do
    resources :orders
    collection do
      get :mobile
    end
  end

  resource :session

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
  root :to => 'sessions#new'

  # See how all your routes lay out with "rake routes"


  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

  match '*path' => 'sessions#catcher'

end
