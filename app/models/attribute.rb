# Groups of <i>Attribute</i>
class Attribute < ActiveRecord::Base
  
  has_and_belongs_to_many :attachments, :list => true, :order => 'position'
  has_and_belongs_to_many :attribute_categories, :readonly => true, :join_table => 'attribute_categories_attributes', :foreign_key => 'attribute_id'
  
  has_many :attribute_values, :dependent => :destroy
  has_many :dynamic_attribute_values, :dependent => :destroy

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
