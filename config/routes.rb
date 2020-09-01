Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :vendors do
      collection do
        post :update_positions
      end
    end
    get 'vendor_settings' => 'vendor_settings#edit'
    patch 'vendor_settings' => 'vendor_settings#update'
  end
end


Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      namespace :storefront do
        get '/vendors/:vendor/departments', to: 'vendors#departments', as: :vendor_departments
        resources :vendors, only: %i[index show departments]
      end
    end
  end
end
