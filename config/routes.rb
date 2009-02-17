# Add your custom routes here.  If in config/routes.rb you would 
# add <tt>map.resources</tt>, here you would add just <tt>resources</tt>

# resources :rails_commerces
resources :addresses
resources :orders

namespace :admin do |admin|
  admin.resources :shipping_methods
  admin.resources :vouchers
  admin.resources :categories
  admin.resources :users
  admin.resources :attributes_groups
  admin.resources :orders
  admin.resources :pictures
  admin.resources :products
  admin.root :controller => 'users'
end

root :controller => 'home'
