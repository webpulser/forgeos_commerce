ActionController::Routing::Routes.draw do |map|

# Add your custom routes here.  If in config/routes.rb you would 
# add <tt>map.resources</tt>, here you would add just <tt>resources</tt>
map.register '/register', :controller => 'users', :action => 'create'
map.signup '/signup', :controller => 'users', :action => 'new'
map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
 
# resources :forgeos_commerce
map.resources :users
map.resources :products
map.resources :packs, :controller => :products
map.with_options(:controller => 'addresses') do |address|
  address.resources :addresses
  address.resources :address_invoices
  address.resources :address_deliveries
end
map.resources :orders
map.cart '/cart', :controller => 'cart'

# catalog routes
map.catalog '/catalog/:category_name/:url', :controller => 'catalog', :action => 'index', :url => nil
map.catalog_selected_category '/catalog/:category_name/:category_choice/:url', :controller => 'catalog', :action => 'index', :url => nil
map.product_type '/catalog/:product_type_url', :controller => 'catalog', :action => 'index'

#resources :catalog
map.selected_product_category '/product/:category_name/:category_choice/:url', :controller => 'url_catcher', :action => 'product'
map.product_category '/product/:category_name/:url', :controller => 'url_catcher', :action => 'product'#
map.product_by_url '/product/:url', :controller => 'url_catcher', :action => 'product'

map.namespace :admin do |admin|
  admin.resources :transporters, :controller => 'transporter_rules', :member => { :activate => :post, :duplicate => :get }
  admin.resources :transporter_rules, :member => { :duplicate => :get }
  admin.resources :vouchers, :member => { :activate => :post }
  %w(product product_type attribute special_offer).each do |category|
    admin.resources "#{category}_categories", :controller => 'categories', :requirements => { :type => "#{category}_category" }
  end
  map.connect "admin/transporter_categories.json", :controller => 'admin/transporter_rules', :action => 'categories'
  admin.resources :geo_zones, :member => { :add_element => :post }
  admin.resources :countries, :controller => 'geo_zones'

  admin.resources :attributes, :collection => { :access_method => :post }, :member => { :duplicate => :get}
  %w(checkbox radiobutton picklist text longtext number date url).each do |attribute_type|
    admin.resources "#{attribute_type}_attributes", :controller => 'attributes', :requirements => { :type => attribute_type }
  end
  
  admin.resources :orders, :member => { :bill => :get, :total => :put } do |order|
    order.resources :details, :controller => 'order_details'
  end

  admin.resources :product_types
  admin.resources :products, :collection => { :url => :post }, :member => { :activate => :post, :update_attributes_list => :post, :duplicate => :get }
  admin.resources :packs, :collection => { :url => :post }, :member => { :activate => :post, :update_attributes_list => :post, :duplicate => :get }, :controller => :products, :requirements => { :type => 'pack' }
  #admin.resources :special_offers, :collection => { :special_offer => [:get, :post] }
  admin.resources :special_offers, :member => { :activate => :post }
end
end
