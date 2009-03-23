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

namespace :admin do |admin|
  admin.logout '/logout', :controller => 'sessions', :action => 'destroy'
  admin.login '/login', :controller => 'sessions', :action => 'new'
  admin.resources :shipping_methods
  admin.resources :vouchers
  admin.resources :categories
  admin.resources :users
  admin.resources :attributes_groups
  admin.resources :orders
  admin.resources :pictures
  admin.resources :products
  admin.resources :admins
  admin.resources :roles
  admin.resources :rights
  admin.resource :session
  admin.resources :account
  admin.root :controller => 'account'
end

root :controller => 'home'
