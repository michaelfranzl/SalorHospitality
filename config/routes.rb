SalorGastro::Application.routes.draw do
  #mount SalorHotel::Engine, :at => "salor_hotel"
  get "reservations/fetch"
  get "orders/attach_coupon"
  get "orders/attach_discount"
  resources :reservations

  resources :discounts

  get "coupons/coupons_list"
  resources :coupons

  resources :roles
  resources :customers

  get "templates/index"
  get "templates/show"
  get "templates/edit"
  get "templates/update"
  get "templates/delete"

  get "partials/delete"
  get "partials/update"

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
      get  :active
      get  :waiterpad
    end
  end

  resources :orders do
    collection do
      post :toggle_admin_interface
      post :login
      get :refund
      get :last_invoices
      post :update_ajax
      get :logout
      post :by_nr
    end
  end

  resources :bookings do
    collection do
      post :by_nr
    end
  end

  match 'orders/refund/:id' => 'orders#refund'
  match 'items/rotate_tax/:id' => 'items#rotate_tax'
  match 'orders/toggle_tax_colors/:id' => 'orders#toggle_tax_colors'
  match 'settlements/print/:id' => 'settlements#print'
  match 'room_prices/generate' => 'room_prices#generate'
  match 'tables/:id/update_coordinates' => 'tables#update_coordinates'


  if Rails.env.test?
    match 'session/request_specs_login' => 'sessions#request_specs_login'
  end

  resources :cost_centers, :taxes, :users, :roles, :presentations, :payment_methods
  resources :surcharges
  resources :rooms
  resources :room_types
  resources :seasons
  resources :guest_types
  resources :room_prices

  resources :reports do
    collection do
      get :backup_database
      get :backup_logfile
      get :update_connection_status
      get :connect_remote_service
    end
  end

  resources :items do
    collection do
      get :list
      get :set_attribute
    end
  end
  
  resources :partials do
    collection do
      post :change_presentation
      post :move
    end
  end
  
  resources :pages do
    collection do
      post :find
      get :iframe
    end
  end

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
      get :detailed_list
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

  resources :vendors do
    collection do
      get :render_resources
    end
  end

  resource :session do
    get :exception_test
    get :permission_denied
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
  root :to => 'orders#index'


  # See how all your routes lay out with "rake routes"


  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

  #match '*path' => 'sessions#catcher'

end
