module Forgeos
  # Set administration's menu
  AdminMenu << { :title => 'back_office.menu.orders',
    :url => '/admin/orders', :i18n => true,
    :html => { :class => 'left'}
  }
  AdminMenu << { :title => 'back_office.menu.catalog',
    :url => [
      '/admin/products',
      '/admin/packs'
    ],
    :i18n => true,
    :html => { :class => 'left last'}
  }
  AdminMenu << { :title => 'back_office.menu.site_builder',
    :url => [
      '/admin/product_types',
      '/admin/attributes'
    ],
    :i18n => true,
    :html => { :class => 'right' }
  }
  AdminMenu << { :title => 'back_office.menu.marketing',
    :i18n => true,
    :url => '/admin/special_offers',
    :html => { :class => 'right' }
  }
end
