# Add your custom routes here.  If in config/routes.rb you would 
# add <tt>map.resources</tt>, here you would add just <tt>resources</tt>
register '/register', :controller => 'users', :action => 'create'
signup '/signup', :controller => 'users', :action => 'new'
activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
 
# resources :forgeos_commerce
resources :users
resources :products
resources :packs, :controller => :products
resources :addresses
resources :orders
catalog '/catalog/:category_name/:url', :controller => 'catalog', :action => 'index', :url => nil
resources :catalog
connect '/product/:url', :controller => 'url_catcher', :action => 'product'

namespace :admin do |admin|
  admin.resources :transporters, :controller => 'transporter_rules', :member => { :activate => :post }
  admin.resources :transporter_rules
  admin.resources :vouchers
  %w(product product_type attribute special_offer).each do |category|
    admin.resources "#{category}_categories", :controller => 'categories', :requirements => { :type => "#{category}_category" }
  end
  admin.resources :geo_zones
  admin.resources :countries, :controller => 'geo_zones'

  admin.resources :attributes, :collection => { :access_method => :post }, :member => { :duplicate => :get} do |attribute|
    attribute.resources :attribute_values, :controller => 'attribute_values'
  end

  %w(checkbox radio picklist text longtext number date url).each do |attribute_type|
    admin.resources "#{attribute_type}_attributes", :controller => 'attributes', :requirements => { :type => attribute_type }
  end
  
  admin.resources :orders, :member => { :bill => :get, :total => :put } do |order|
    order.resources :details, :controller => 'order_details'
  end

  admin.resources :product_types
  admin.resources :products, :collection => { :url => :post }, :member => { :activate => :post, :update_attributes_list => :post, :duplicate => :get }
  admin.resources :packs, :collection => { :url => :post }, :member => { :activate => :post, :update_attributes_list => :post, :duplicate => :get }, :controller => :products
  #admin.resources :special_offers, :collection => { :special_offer => [:get, :post] }
  admin.resources :special_offers
end
