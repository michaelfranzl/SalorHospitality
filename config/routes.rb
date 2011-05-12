BillGastro::Application.routes.draw do
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
      get :listall
      post :find
      post :change_scope
    end
  end

  resources :orders do
    collection do
      get :print
      get :unsettled
      post :toggle_admin_interface
      post :login
      get :storno
      get :last_invoices
      post :receive_order_attributes_ajax
      get :logout
    end
  end

  match 'orders/print_and_finish/:id/:port' => 'orders#print_and_finish'
  match "orders/storno/:id" => "orders#storno"
  match "items/rotate_tax/:id" => "items#rotate_tax"
  match "orders/toggle_tax_colors/:id" => "orders#toggle_tax_colors"

 resources :items, :companies, :options, :settlements, :categories, :groups, :stocks, :cost_centers, :taxes, :menucard, :waiterpad, :blackboard

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

  resources :users do
    resources :settlements
  end

  resources :tables do
    resources :orders
    collection do
      get :mobile
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

  match '*path' => 'sessions#catcher'

end
