module RailsCommerce
  # ==== Inheritance
  # * <tt>RailsCommerce::Product</tt>
  class ProductDetail < Product

    has_and_belongs_to_many :tattributes, :join_table => 'rails_commerce_attributes_product_details', :class_name => 'RailsCommerce::Attribute', :readonly => true
    has_many :dynamic_attributes, :class_name => 'RailsCommerce::DynamicAttribute', :dependent => :destroy
    has_many :dynamic_attributes_groups, :through => :dynamic_attributes, :class_name => 'RailsCommerce::AttributesGroup', :source => 'attributes_group'

    belongs_to :product_parent, :class_name => 'RailsCommerce::ProductParent', :foreign_key => 'product_id'
    before_create :add_product_parent_dynamic_attributes_groups
    before_destroy :product_parent_product_details_size
    
    # Call by <i>before_destroy</i>
    # check if associated RailsCommerce::ProductParent RailsCommerce::ProductDetails size was superior to 1
    def product_parent_product_details_size
      # check presence of product_parent to force return true
      # it solve 'dependent => destroy' conflict ( the last product_detail was not destroyed )
      return product_parent.product_details.count > 1 if product_parent
    end

    # Call by <i>before_create</i>
    # * add RailsCommerce::ProductParent dynamic_attributes_groups in dynamic_attributes_groups list.
    def add_product_parent_dynamic_attributes_groups
      dynamic_attributes_groups << product_parent.dynamic_attributes_groups
    end

    def initialize(options={})
      self.is_instanciable = true
      super(options)
    end

    # Returns month's offers
    def self.get_offer_month
      find_by_offer_month(true)
    end

    # Returns the first page products
    def self.get_on_first_page
      find_all_by_on_first_page(true)
    end

    def attribute_of(attributes_group)
      tattributes.find_by_attributes_group_id(attributes_group.id)
    end

    # Overload the <i>name</i> attribute.
    #
    # Returns the <i>name</i> of <i>RailsCommerce::ProductParent</i> if <i>name</i> is <i>nil</i>
    def name
      (super.nil? || super.blank?) ? product_parent.name : super
    end

    # Overload the <i>description</i> attribute.
    #
    # Returns the <i>description</i> of <i>RailsCommerce::ProductParent</i> if <i>description</i> is <i>nil</i>    
    def description
      (super.nil? || super.blank?) ? product_parent.description : super
    end

    # Overload the <i>reference</i> attribute.
    #
    # Returns the <i>reference</i> of <i>RailsCommerce::ProductParent</i> if <i>reference</i> is <i>nil</i>    
    def reference
      (super.nil? || super.blank?) ? product_parent.reference : super
    end

    # Overload the <i>selling_date</i> attribute.
    #
    # Returns the <i>selling_date</i> of <i>RailsCommerce::ProductParent</i> if <i>selling_date</i> is <i>nil</i>    
    def selling_date
      (super.nil? || super.blank?) ? product_parent.selling_date : super
    end

    # Overload the <i>barcode</i> attribute.
    #
    # Returns the <i>barcode</i> of <i>RailsCommerce::ProductParent</i> if <i>barcode</i> is <i>nil</i>    
    def barcode
      (super.nil? || super.blank?) ? product_parent.barcode : super
    end

    # Overload the <i>keywords</i> attribute.
    #
    # Returns the <i>keywords</i> of <i>RailsCommerce::ProductParent</i> if <i>keywords</i> is <i>nil</i>    
    def keywords
      (super.nil? || super.blank?) ? product_parent.keywords : super
    end
   
    # Overload the <i>stock</i> attribute.
    #
    # Returns the <i>stock</i> of <i>RailsCommerce::ProductParent</i> if <i>stock</i> is <i>nil</i>    
    def stock
      (super.nil? || super.blank?) ? product_parent.stock : super
    end

    # Returns attributes_groups of <i>RailsCommerce::ProductParent</i>
    def attributes_groups
      product_parent.attributes_groups
    end

    # Overload the <i>rate_tax</i> attribute.
    #
    # Returns the <i>rate_tax</i> of <i>RailsCommerce::ProductParent</i> if <i>rate_tax</i> is <i>nil</i>
    def rate_tax
      (super) ? super : product_parent.rate_tax
    rescue
      return 0
    end

    # Returns all <i>RailsCommerce::ProductDetail</i> who <i>name LIKE '%keyword%' OR description LIKE '%keyword%'</i>
    #
    # Inheritance of <i>RailsCommerce::ProductParent</i> is consider
    # when <i>RailsCommerce::ProductDetail.name</i> or if <i>RailsCommerce::ProductDetail.descrition</i> are nil
    #
    # ==== Parameters
    # * <tt>:keyword</tt> - a keyword
    def self.search(keyword)
      results = RailsCommerce::ProductDetail.find(:all, :conditions => ["name LIKE ? OR description LIKE ?", "%#{keyword}%", "%#{keyword}%"])

      # name and description inheritance of ProductParent
      # TODO - rewrite this code
      products = RailsCommerce::ProductDetail.find(:all, :conditions => ["name IS NULL OR description IS NULL", "%#{keyword}%", "%#{keyword}%"])
      products.each do |product|
        results << product if product.product_parent.name.include?(keyword)
      end

      results.uniq
    end

    # Returns a <i>WillPaginate::Collection</i> of <i>RailsCommerce::ProductDetail</i> who <i>name LIKE '%keyword%' OR description LIKE '%keyword%'</i>
    #
    # ==== Parameters
    # * <tt>:keyword</tt> - a keyword
    # ==== paginate_options
    # * <tt>:page</tt> - page number
    # * <tt>:per_page</tt> - product's count by page
    def self.search_paginate(keyword, page=1, per_page=8)
      self.search(keyword).paginate(:page => page, :per_page => per_page)
    end
  end
end
