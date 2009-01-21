module RailsCommerce
  # Attributes of <i>RailsCommerce::Product</i>
  class Attribute < ActiveRecord::Base
    set_table_name "rails_commerce_attributes"
    
    belongs_to :attributes_group, :class_name => 'RailsCommerce::AttributesGroup', :readonly => true
    has_many :sortable_pictures, :class_name => 'RailsCommerce::SortablePicture', :dependent => :destroy
    has_many :pictures, :through => :sortable_pictures, :class_name => 'RailsCommerce::Picture', :dependent => :destroy, :readonly => true, :order => 'rails_commerce_sortable_pictures.position'
  end
end
