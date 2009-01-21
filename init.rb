# Load libraries
require File.dirname(__FILE__) + '/lib/rails_commerce'
require File.dirname(__FILE__) + '/lib/rails_commerce/application'

# Load controllers
require File.dirname(__FILE__) + '/lib/rails_commerce/controllers/catalog_controller'
require File.dirname(__FILE__) + '/lib/rails_commerce/controllers/cart_controller'
require File.dirname(__FILE__) + '/lib/rails_commerce/controllers/order_controller'
require File.dirname(__FILE__) + '/lib/rails_commerce/controllers/product_controller'
require File.dirname(__FILE__) + '/lib/rails_commerce/controllers/users_controller'

# Load models
require File.dirname(__FILE__) + '/lib/rails_commerce/models/address'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/address_delivery'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/address_invoice'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/attribute'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/attributes_group'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/cart'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/carts_product'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/category'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/currency'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/currencies_exchanges_rate'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/order'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/orders_detail'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/dynamic_attribute'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/country'

require File.dirname(__FILE__) + '/lib/rails_commerce/models/namable'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/civility'

require File.dirname(__FILE__) + '/lib/rails_commerce/models/picture'

require File.dirname(__FILE__) + '/lib/rails_commerce/models/product'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/product_parent'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/product_detail'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/sortable_picture'

require File.dirname(__FILE__) + '/lib/rails_commerce/models/shipping_method'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/shipping_method_detail'

require File.dirname(__FILE__) + '/lib/rails_commerce/models/schema_info'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/user'
require File.dirname(__FILE__) + '/lib/rails_commerce/models/voucher'

# Load helpers
require File.dirname(__FILE__) + '/lib/rails_commerce/helpers/cart_helper'
require File.dirname(__FILE__) + '/lib/rails_commerce/helpers/category_helper'
require File.dirname(__FILE__) + '/lib/rails_commerce/helpers/order_helper'
require File.dirname(__FILE__) + '/lib/rails_commerce/helpers/product_helper'
require File.dirname(__FILE__) + '/lib/rails_commerce/helpers/rails_commerce_helper'

#ActionView::Helpers::FormHelper.send(:include, RailsCommerce::ProductHelper)
#ActionView::Base.send(:include, RailsCommerce::ProductHelper)

# re-define <i>puralize</i> for french user.
ActionView::Helpers::TextHelper.class_eval <<-EOF
  def pluralize(count, singular, plural = nil)
    count.to_s + " " + ((count.to_i <= 1) ? singular : (plural || singular.pluralize))
  end
EOF

gem 'mislav-will_paginate', '~>2.3'
require 'will_paginate'

$currency = RailsCommerce::Currency.find_by_name('euro') if RailsCommerce::Currency.table_exists?
