Forgeos::Commerce::Engine.routes.draw do

  namespace :admin do

    match '/admin/get_cross_selling_id' => 'admin/products#get_cross_selling_id'
    match '/admin/transporter_categories.:format' => 'admin/transporter_rules#categories'

    resources :transporters, :controller => 'transporter_rules' do
      member do
        post :activate
        get :duplicate
      end
    end

    resources :transporter_rules do
      member do
        get :duplicate
      end
    end

    resources :vouchers do
      member do
        post :activate
      end
    end

    resources :brands

    %w(brand product product_type attribute special_offer).each do |category|
      resources "#{category}_categories", :controller => 'categories', :type => "#{category}_category"
    end


    resources :geo_zones do
      member do
        post :add_element
      end
    end

    resources :countries, :controller => 'geo_zones'

    %w(attributes dynamic_attributes).each do |model|
      resources model, :controller => :attributes do
        collection do
          post :access_method
        end
        member do
          get :duplicate
        end
      end
    end

    %w(checkbox radiobutton picklist text longtext number date url).each do |attribute_type|
      resources "#{attribute_type}_attributes", :controller => :attributes, :type => attribute_type do
        collection do
          post :access_method
        end
        member do
          get :duplicate
        end
      end
    end

    resources :orders do
      member do
        get :bill
        put :total
      end
      resources :details, :controller => 'order_details'
    end


    resources :product_types

    resources :products do
      collection do
        post :url
      end
      member do
        post :activate
        post :update_attributes_list
        get :duplicate
      end
    end

    resources :packs, :controller => :products, :type => 'pack' do
      collection do
        post :url
      end
      member do
        post :activate
        post :update_attributes_list
        get :duplicate
      end
    end

    resources :special_offers do
      member do
        post :activate
      end
    end

    resources :forms
  end
end
