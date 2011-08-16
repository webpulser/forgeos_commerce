class Form < ActiveRecord::Base
  validates_presence_of :name, :model
  has_and_belongs_to_many :form_attributes, :class_name => 'Attribute', :readonly => true, :order => 'position'
  has_and_belongs_to_many :dynamic_attributes, :class_name => 'Attribute', :readonly => true,
    :join_table => 'attributes_forms', :association_foreign_key => 'attribute_id',
    :conditions => {:dynamic => true}
end
