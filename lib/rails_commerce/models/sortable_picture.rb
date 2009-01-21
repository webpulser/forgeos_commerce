module RailsCommerce
  class SortablePicture < ActiveRecord::Base
    set_table_name 'rails_commerce_sortable_pictures'
    belongs_to :product, :class_name => 'RailsCommerce::Product'
    belongs_to :picture, :class_name => 'RailsCommerce::Picture'
    belongs_to :category, :class_name => 'RailsCommerce::Category'
    belongs_to :attributes_group, :class_name => 'RailsCommerce::AttributesGroup'
    belongs_to :tattribute, :class_name => 'RailsCommerce::Attribute', :foreign_key => :attribute_id
    acts_as_list :scope => "product_id"
  end
end
