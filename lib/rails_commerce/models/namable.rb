module RailsCommerce
  # ==== Subclasses
  # * <tt>RailsCommerce::Civility</tt>
  class Namable < ActiveRecord::Base
    set_table_name "rails_commerce_namables"
  end
end
