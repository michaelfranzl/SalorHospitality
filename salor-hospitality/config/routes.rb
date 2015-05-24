# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

SalorHospitality::Application.routes.draw do
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
    end
  end

  resources :orders do
    collection do
      post :login
      get :last_invoices
      get :logout
      post :by_nr
      get :last
      post :last
    end
  end

  resources :bookings do
    collection do
      post :by_nr
    end
  end

  get 'orders/reactivate/:id' => 'orders#reactivate'
  get 'orders/toggle_tax_colors/:id' => 'orders#toggle_tax_colors'
  get 'settlements/print/:id' => 'settlements#print'
  get 'room_prices/generate' => 'room_prices#generate'
  put 'tables/:id/update_coordinates' => 'tables#update_coordinates'
  get 'vendors/report' => 'vendors#report'
  get 'vendors/identify_printers' => 'vendors#identify_printers'
  get 'vendors/test_printers' => 'vendors#test_printers'
  get 'users/unlock_ip' => 'users#unlock_ip'
  post 'route' => 'application#route'
  get 'route' => 'application#route'
  get 'translations' => 'translations#index'
  get 'translations/set' => 'translations#set'
  

  resources :cost_centers, :taxes, :roles, :presentations, :payment_methods
  resources :users
  resources :surcharges
  resources :rooms
  resources :room_types
  resources :seasons
  resources :guest_types
  resources :room_prices
  resources :statistic_categories
  resources :cameras
  resources :roles
  resources :customers

  resources :reports do
    collection do
      get :update_connection_status
      get :connect_remote_service
    end
  end

  resources :items do
    collection do
      get :list
      put :split
      put :rotate_tax
      post :set_attribute
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

  resources :statistics

  resources :tables do
    resources :orders
    collection do
      get :mobile
    end
  end

  resources :vendors do
    collection do
      get :render_resources
      get :online_status
    end
  end

  resource :session do
    get :test_exception
    post :email
    get :test_email
    get :permission_denied
    get :new_customer
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


  # See how all your routes lay out with "rake routes"


  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
  

  if defined?(ShSaas) == 'constant'
    mount ShSaas::Engine => "/saas"
    get '/login' => 'sh_saas/sessions#new_customer'
    get '/signin' => 'sh_saas/sessions#new'
    get '/printers' => 'sh_saas/sessions#printer_info'
    root :to => 'sh_saas/pages#iframe'
    get '*path' => 'sh_saas/pages#iframe'
  else
    get '/printers' => 'sessions#printer_info'
    get '*path' => 'sessions#new'
    root :to => 'orders#index'
  end

end
