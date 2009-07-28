# Add your custom routes here.  If in config/routes.rb you would 
# add <tt>map.resources</tt>, here you would add just <tt>resources</tt>
logout '/logout', :controller => 'sessions', :action => 'destroy'
login '/login', :controller => 'sessions', :action => 'new'
register '/register', :controller => 'users', :action => 'create'
signup '/signup', :controller => 'users', :action => 'new'
activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
 
# resources :rails_commerces
resources :users
resource :session
resources :addresses
resources :orders

connect '/product/:url', :controller => 'url_catcher', :action => 'product'

namespace :admin do |admin|
  admin.resources :shipping_methods
  admin.resources :vouchers
  admin.resources :categories
  admin.resources :users, :collection => { :filter => :post, :export_newsletter => :post }
  admin.resources :tattributes do |tattribute|
    tattribute.resources :values, :controller => 'tattribute_values'
  end
  admin.resources :orders
  admin.resources :pictures
  admin.resources :product_types
  admin.resources :products, :member => { :quick_edit => :post }
  admin.resources :tags
  admin.resources :price_cuts
end

root :controller => 'home'
