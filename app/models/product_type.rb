class ProductType < ActiveRecord::Base
  include Forgeos::Urlified

  translates :name, :url, :description
  define_translated_index :name, :url, :description

  has_many :products, :dependent => :destroy
  has_and_belongs_to_many_attachments

  has_and_belongs_to_many :product_attributes, :class_name => 'Attribute', :readonly => true
  has_and_belongs_to_many :dynamic_attributes, :class_name => 'Attribute', :readonly => true,
    :join_table => 'attributes_product_types', :association_foreign_key => 'attribute_id',
    :conditions => {:dynamic => true}

  has_and_belongs_to_many :categories, :readonly => true,
    :join_table => 'categories_elements', :foreign_key => 'element_id',
    :association_foreign_key => 'category_id', :class_name => 'ProductTypeCategory'

  validates :name, :presence => true

  has_many :brands, :through => :products, :uniq => true

  def self.modify_import_attributes(attributes)
    attributes[:url] = attributes[:name].parameterize if attributes[:url].blank? and attributes[:name].present?
    attributes
  end
end
