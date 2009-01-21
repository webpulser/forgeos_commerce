module RailsCommerce
  class Picture < ActiveRecord::Base
    set_table_name "rails_commerce_pictures"

    acts_as_commentable
    has_attachment :storage => :file_system, :file_system_path => 'public/images/products_pictures', :content_type => 'image', :thumbnails => { :big => '500x500', :normal => '200x200', :small => '100x100', :thumb => '50x50' }

    validates_presence_of :content_type

    has_many :sortable_pictures, :class_name => 'RailsCommerce::SortablePicture', :dependent => :destroy
    has_many :products, :through => :sortable_pictures, :class_name => 'RailsCommerce::Product'
    has_many :tattributes, :through => :sortable_pictures, :class_name => 'RailsCommerce::Attribute'
    has_many :attributes_groups, :through => :sortable_pictures, :class_name => 'RailsCommerce::AttributesGroup'
    has_many :categories, :through => :sortable_pictures, :class_name => 'RailsCommerce::Category'
  end
end
