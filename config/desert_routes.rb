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

connect '/product/:url', :controller => 'url_catcher', :action => 'product'

namespace :admin do |admin|
  admin.resources :shipping_methods
  admin.resources :vouchers
  admin.resources :categories
  admin.resources :geo_zones
  admin.resources :countries, :controller => 'geo_zones'
  admin.resources :users, :collection => { :filter => [:post, :get] }, :member => { :activate => :post }
  admin.resources :tattributes, :collection => { :access_method => :post } do |tattribute|
    tattribute.resources :values, :controller => 'tattribute_values'
  end

  admin.resources :orders do |order|
    order.resources :details, :controller => 'order_details'
  end

  admin.resources :pictures
  admin.resources :product_types
  admin.resources :products, :collection => { :url => :post }, :member => { :activate => :post, :update_tattributes_list => :post, :duplicate => :get }
  admin.resources :packs, :controller => :products,  :collection => { :url => :post }, :member => { :activate => :post, :duplicate => :get }
  admin.resources :tags
  admin.resources :special_offers, :collection => { :special_offer => [:get, :post] }
  admin.resources :shipping_rules
end

root :controller => 'home'
