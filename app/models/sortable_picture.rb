class SortablePicture < ActiveRecord::Base
  belongs_to :product
  belongs_to :picture
  belongs_to :category
  belongs_to :attributes_group
  belongs_to :tattribute, :class_name => 'Attribute', :foreign_key => :attribute_id
end
