# Groups of <i>Attribute</i>
class Attribute < ActiveRecord::Base
  translates :name
  has_and_belongs_to_many :attribute_categories, :readonly => true, :join_table => 'categories_elements', :foreign_key => 'element_id', :association_foreign_key => 'category_id'

  has_many :attribute_values, :dependent => :destroy, :order => 'position'
  accepts_nested_attributes_for :attribute_values, :allow_destroy => true
  has_many :dynamic_attribute_values, :dependent => :destroy

  validates_presence_of :name, :access_method
  validates_uniqueness_of :access_method

  has_and_belongs_to_many :product_types, :readonly => true
  has_many :products, :through => :dynamic_attribute_values, :readonly => true

  before_save :clear_attributes

  define_index do
    indexes access_method, :sortable => true
    indexes type
  end

  define_translated_index :name

  def clone
    attribute = super
    attribute.attribute_values = self.attribute_values.collect(&:clone)
    %w(attribute_category_ids attachment_ids).each do |method|
      attribute.send("#{method}=",self.send(method))
    end
    attribute
  end

private
  def clear_attributes
    self.attribute_values.destroy_all if self.dynamic?
  end
end
