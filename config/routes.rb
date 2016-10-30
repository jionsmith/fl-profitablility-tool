Rails.application.routes.draw do
  devise_for :users

  namespace :v1, defaults: { format: :json } do
    resources :projects do
      resources :resources do
        resources :resource_timelines do
        end
      end
      resources :timelines do

      end
      resources :project_timelines, :only => [:update] do
      end

      resources :expenses do
      end
    end

    resources :resource_timelines do
    end

    resource :users do
      post 'update_organisation' => 'users#update_organisation'
      get 'project_tags' => 'users#project_tags'
      resources :clients do
        get 'all' => 'clients#all'
        resources :projects do
        end
      end
      post 'signin'
      get 'team_member'
      get 'make_admin'
      post 'update_profile'
      post 'member_invite'
      # post ''
      get 'member_signup'
      get 'remove_member'
      post 'get_member_by_token'
      post 'complete_member'

      post 'send_forgot_email'
      get 'forgot_pass'
    end

    resource :resources do
      post 'update_order'
    end

  end

  root 'home#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
