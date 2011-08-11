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
    :html => { :class => 'left last'}
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
    :url => { :controller => 'admin/special_offers'},
    :html => { :class => 'right' }
  }
end
