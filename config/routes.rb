# Add your custom routes here.  If in config/routes.rb you would 
# add <tt>map.resources</tt>, here you would add just <tt>resources</tt>

# resources :rails_commerces
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
