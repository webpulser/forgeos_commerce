# Add your custom routes here.  If in config/routes.rb you would 
# add <tt>map.resources</tt>, here you would add just <tt>resources</tt>
logout '/logout', :controller => 'sessions', :action => 'destroy'
login '/login', :controller => 'sessions', :action => 'new'
register '/register', :controller => 'users', :action => 'create'
signup '/signup', :controller => 'users', :action => 'new'
activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
 
# resources :rails_commerces
resource :session
resources :users
resources :products
resources :packs, :controller => :products
resources :addresses
resources :orders
catalog '/catalog/:category_name/:url', :controller => 'catalog', :action => 'index', :url => nil

connect '/product/:url', :controller => 'url_catcher', :action => 'product'

namespace :admin do |admin|
  admin.resources :shipping_methods
  admin.resources :vouchers
  admin.resources :categories, :member => { :add_element => :post }
  %w(product product_type option).each do |category|
    admin.resources "#{category}_categories", :controller => 'categories', :requirements => { :type => "#{category}_category" }
  end
  admin.resources :geo_zones
  admin.resources :countries, :controller => 'geo_zones'
  admin.resources :users, :collection => { :filter => [:post, :get] }, :member => { :activate => :post }

  admin.resources :options, :collection => { :access_method => :post }, :member => { :duplicate => :get} do |option|
    option.resources :option_values, :controller => 'tattribute_values'
  end
  admin.resources :tattributes, :controller => 'options', :collection => { :access_method => :post } do |tattribute|
    tattribute.resources :values, :controller => 'tattribute_values'
  end


  %w(checkbox radiobutton picklist text longtext number date url).each do |option_type|
    admin.resources "#{option_type}_options", :controller => 'options', :requirements => { :type => option_type }
  end
  
  admin.resources :orders, :member => { :bill => :get, :total => :put } do |order|
    order.resources :details, :controller => 'order_details'
  end

  admin.resources :pictures
  admin.resources :product_types
  admin.resources :products, :collection => { :url => :post }, :member => { :activate => :post, :update_tattributes_list => :post, :duplicate => :get }
  admin.resources :packs, :collection => { :url => :post }, :member => { :activate => :post, :update_tattributes_list => :post, :duplicate => :get }, :controller => :products
  admin.resources :tags
  #admin.resources :special_offers, :collection => { :special_offer => [:get, :post] }
  admin.resources :special_offers
  admin.resources :shipping_rules

  admin.statistics_visitors_graph '/statistics/visitors_graph', :controller => 'statistics', :action => 'visitors_graph'
  admin.statistics_sales_graph '/statistics/sales_graph', :controller => 'statistics', :action => 'sales_graph'
end

root :controller => 'home'
