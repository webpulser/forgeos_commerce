module Forgeos
  # Set administration's menu
  AdminMenu << { :title => 'back_office.menu.orders',
    :url => { :controller => 'admin/orders' }, :i18n => true,
    :html => { :class => 'left'}
  }
  AdminMenu << { :title => 'back_office.menu.catalog',
    :url => [
      { :controller => 'admin/products' },
      { :controller => 'admin/packs' }
    ],
    :i18n => true,
    :html => { :class => 'left'}
  }
  AdminMenu << { :title => 'back_office.menu.site_builder',
    :url => [
      { :controller => 'admin/product_types'},
      { :controller => 'admin/attributes' }
    ],
    :i18n => true,
    :html => { :class => 'right' }
  }
  AdminMenu << { :title => 'back_office.menu.marketing', 
    :i18n => true,
    :url => { :controller => 'admin/vouchers'},
    :html => { :class => 'right' }
  }

  # Set site's menu
  Menu << { :title => 'home', :url => :root, :i18n => true }
  Menu << { :title => 'catalog', :url => { :controller => 'catalog' }, :i18n => true }
  Menu << { :title => ['cart', { :count => 1}], 
    :html => { :id => 'forgeos_commerce_cart_link' },
    :url => { :controller => 'cart' },
    :helper => { :method => 'link_to_cart' },
    :i18n => true
  } 
  Menu << { :title => ['wishlist',{ :count => 1}],
    :html => { :id => 'forgeos_commerce_wishlist_link' },
    :url => { :controller => 'wishlist' },
    :helper => { :method => 'link_to_wishlist' },
    :i18n => true 
  }
end
