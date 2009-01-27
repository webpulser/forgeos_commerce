# Add your custom routes here.  If in config/routes.rb you would 
# add <tt>map.resources</tt>, here you would add just <tt>resources</tt>

# resources :rails_commerces
root :controller => 'home'

namespace :admin do |admin|
  admin.root :controller => 'users'
  admin.resources :products
end
