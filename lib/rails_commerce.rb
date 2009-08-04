module RailsCommerce
  OPTIONS = {
    :text => {
      :are_you_sure_to_empty_your_cart      => 'are you sure to empty your cart ?',
      :name                                 => 'name',
      :product_added                        => 'product added',
      :cart_is_empty                        => 'cart is empty',
      :product_has_been_remove              => 'product has been remove',
      :are_you_sure_to_remove_this_product  => 'are you sure to remove this product ?',
      :your_cart_is_empty                   => 'your cart is empty',
      :add_to_cart                          => 'add to cart',
      :empty_cart                           => 'empty_cart',
      :product_name                         => 'product name',
      :unit_price                           => 'unit price',
      :quantity                             => 'quantity',
      :tax                                  => 'tax',
      :total                                => 'total',
      :na                                   => '--.--',
      :remove_voucher                       => 'remove this voucher'
    },
    :product_in_groups_of => 4
  }
end

# Set administration's menu
Forgeos::AdminMenu << { :title => 'orders',
  :url => { :controller => 'admin/orders' }, :i18n => true,
  :children => [
    { :title => 'shipping_methods', :url => { :controller => 'admin/shipping_methods' } , :i18n => true },
    { :title => 'vouchers', :url => { :controller => 'admin/vouchers' }, :i18n => true },
    { :title => 'price_cuts', :url => { :controller => 'admin/price_cuts'}, :i18n => true},
    { :title => 'geo_zones', :url => { :controller => 'admin/geo_zones'}, :i18n => true}
  ]
}
Forgeos::AdminMenu << { :title => 'products',
  :url => { :controller => 'admin/products' }, :i18n => true,
  :children => [
    { :title => 'product_types', :url => { :controller => 'admin/product_types' }, :i18n => true },
    { :title => 'categories', :url => { :controller => 'admin/categories' }, :i18n => true },
    { :title => 'tattributes', :url => { :controller => 'admin/tattributes' }, :i18n => true },
  ]
}
Forgeos::AdminMenu << { :title => 'users', :url => { :controller => 'admin/users' }, :i18n => true }
Forgeos::AdminMenu << { :title => 'pictures', :url => { :controller => 'admin/pictures' }, :i18n => true } 

# Set site's menu
Forgeos::Menu << { :title => 'home', :url => :root, :i18n => true }
Forgeos::Menu << { :title => 'catalog', :url => { :controller => 'catalog' }, :i18n => true }
Forgeos::Menu << { :title => ['cart', { :count => 1}], 
  :html => { :id => 'rails_commerce_cart_link' },
  :url => { :controller => 'cart' },
  :helper => { :method => 'link_to_cart' },
  :i18n => true
} 
Forgeos::Menu << { :title => ['wishlist',{ :count => 1}],
  :html => { :id => 'rails_commerce_wishlist_link' },
  :url => { :controller => 'wishlist' },
  :helper => { :method => 'link_to_wishlist' },
  :i18n => true 
}

# Set attachable media types
Forgeos::AttachableTypes << 'Product'
Forgeos::AttachableTypes << 'ShippingMethod'
Forgeos::AttachableTypes << 'User'

$currency = Currency.find_by_code('EUR') if Currency.table_exists?
