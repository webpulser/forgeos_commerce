module RailsCommerce
  # ==== Inheritance
  # * <tt>RailsCommerce::Product</tt>
  class ProductParent < Product
    has_many :product_details, :class_name => 'RailsCommerce::ProductDetail', :foreign_key => 'product_id', :dependent => :destroy
    has_and_belongs_to_many :cross_sellings, :class_name => 'RailsCommerce::ProductParent', :foreign_key => 'cross_selling_id', :join_table => 'rails_commerce_cross_sellings_product_parents'

    # TODO : rename product_id to product_parent_id in rails_commerce_attributes_groups_products
    # TODO : rename rails_commerce_attributes_groups_products to rails_commerce_attributes_groups_product_parents
    has_and_belongs_to_many :attributes_groups, :join_table  => 'rails_commerce_attributes_groups_products', :class_name => 'RailsCommerce::AttributesGroup', :readonly => true, :foreign_key => 'product_id'
    has_and_belongs_to_many :dynamic_attributes_groups, :join_table  => 'rails_commerce_attributes_groups_products', :class_name => 'RailsCommerce::AttributesGroup', :readonly => true, :foreign_key => 'product_id',
      :conditions => ['(SELECT COUNT(id) FROM `rails_commerce_attributes` WHERE `rails_commerce_attributes`.`attributes_group_id` = `rails_commerce_attributes_groups_products`.attributes_group_id) = 0']

    # Destroy all RailsCommerce::ProductDetails associated with this RailsCommerce::ProductParent
    def after_destroy
      RailsCommerce::ProductDetail.destroy_all(['product_id = ?', self.id])
    end

    # Create a RailsCommerce::ProductDetail after a RailsCommerce::ProductParent creation
    def after_create
      self.product_details.create
    end

    # Set all RailsCommerce::ProductDetails dynamic_attributes_groups on save
    def before_save
      self.product_details.each do |product_detail|
        product_detail.dynamic_attributes_groups = dynamic_attributes_groups
      end
    end

    def initialize(options={})
      self.is_instanciable = true
      super(options)
    end

    def price(with_tax=false, with_currency=true)
      raise RailsCommerceException.new(:code => 101) if product_details.size > 1
      super(with_tax, with_currency)
    end

    def price_to_s(with_tax=false, with_currency=true)
      return RailsCommerce::OPTIONS[:text][:na] unless product_details.empty?
    end
  end
end
