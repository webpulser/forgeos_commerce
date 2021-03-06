ActionController::Routing::Routes.draw do |map|

  map.namespace :admin do |admin|
    admin.resources :transporters, :controller => 'transporter_rules', :member => { :activate => :post, :duplicate => :get }
    admin.resources :transporter_rules, :member => { :duplicate => :get }
    admin.resources :vouchers, :member => { :activate => :post }
    admin.resources :brands
    %w(brand product product_type attribute special_offer).each do |category|
      admin.resources "#{category}_categories", :controller => 'categories', :requirements => { :type => "#{category}_category" }
    end
    map.connect "admin/transporter_categories.json", :controller => 'admin/transporter_rules', :action => 'categories'
    admin.resources :geo_zones, :member => { :add_element => :post }
    admin.resources :countries, :controller => 'geo_zones'

    admin.resources :attributes, :collection => { :access_method => :post }, :member => { :duplicate => :get}
    admin.resources :dynamic_attributes, :collection => { :access_method => :post }, :member => { :duplicate => :get}, :controller => 'attributes'
    %w(checkbox radiobutton picklist text longtext number date url).each do |attribute_type|
      admin.resources "#{attribute_type}_attributes", :controller => 'attributes', :requirements => { :type => attribute_type }
    end

    admin.resources :orders, :member => { :bill => :get, :total => :put } do |order|
      order.resources :details, :controller => 'order_details'
    end

    map.connect '/admin/get_cross_selling_id', :controller => 'admin/products', :action => 'get_cross_selling_id'

    admin.resources :product_types
    admin.resources :products, :collection => { :url => :post }, :member => { :activate => :post, :update_attributes_list => :post, :duplicate => :get }
    admin.resources :packs, :collection => { :url => :post }, :member => { :activate => :post, :update_attributes_list => :post, :duplicate => :get }, :controller => :products, :requirements => { :type => 'pack' }
    #admin.resources :special_offers, :collection => { :special_offer => [:get, :post] }
    admin.resources :special_offers, :member => { :activate => :post }
    admin.resources :forms
  end

end
