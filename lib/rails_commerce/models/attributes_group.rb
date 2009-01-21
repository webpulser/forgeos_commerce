module RailsCommerce
  # Groups of <i>RailsCommerce::Attribute</i>
  class AttributesGroup < ActiveRecord::Base
    set_table_name "rails_commerce_attributes_groups"

    has_many :tattributes, :class_name => 'RailsCommerce::Attribute', :dependent => :destroy
    has_and_belongs_to_many :products, :class_name => 'RailsCommerce::ProductParent', :join_table => 'rails_commerce_attributes_groups_products', :readonly => true, :association_foreign_key => 'product_id'
    has_many :dynamic_attributes, :class_name => 'RailsCommerce::DynamicAttribute', :dependent => :destroy
    has_many :product_details, :through => :dynamic_attributes, :class_name => 'RailsCommerce::ProductDetail', :readonly => true
    has_many :sortable_pictures, :class_name => 'RailsCommerce::SortablePicture', :dependent => :destroy
    has_many :pictures, :through => :sortable_pictures, :class_name => 'RailsCommerce::Picture', :readonly => true, :order => 'rails_commerce_sortable_pictures.position'

    before_save :clear_attributes

  private
    def clear_attributes
      self.tattributes.destroy_all if self.dynamic?
    end
  end
end
