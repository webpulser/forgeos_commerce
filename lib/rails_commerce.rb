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

Forgeos::AdminMenu['orders'] = { 'shipping_methods' => {'new' => { 'class' => 'add' } }, 'vouchers' => {'new'=>{'class'=>'add'} } }
Forgeos::AdminMenu['product_parents'] = {'attributes_groups'=>{'new'=>{'class'=>'add'}}, 'categories'=>{'new'=>{'class'=>'add'}}}
Forgeos::AdminMenu['users'] = {'new'=>{'class'=>'add'}, 'export_newsletter'=>{'class'=>'report_seo', 'id'=>0}}
Forgeos::AdminMenu['pictures'] = {'new'=>{'class'=>'add'}}
Forgeos::AdminMenu['admins'] = {'rights'=>{}, 'roles'=>{}}

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

$currency = Currency.find_by_name('euro') if Currency.table_exists?
