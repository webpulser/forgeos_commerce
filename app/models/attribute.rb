# Groups of <i>Attribute</i>
class Attribute < ActiveRecord::Base
  
  has_and_belongs_to_many :attachments, :list => true, :order => 'position', :join_table => 'attachments_elements', :foreign_key => 'element_id'
  has_and_belongs_to_many :attribute_categories, :readonly => true, :join_table => 'categories_elements', :foreign_key => 'element_id', :association_foreign_key => 'category_id'
  
  has_many :attribute_values, :dependent => :destroy
  has_many :dynamic_attribute_values, :dependent => :destroy

  validates_presence_of :name, :access_method
  validates_uniqueness_of :access_method
  
  before_save :clear_attributes

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
