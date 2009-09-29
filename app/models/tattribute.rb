# Groups of <i>Attribute</i>
class Tattribute < ActiveRecord::Base
  
  has_and_belongs_to_many :attachments, :list => true, :order => 'position'
  has_and_belongs_to_many :option_categories, :readonly => true, :join_table => 'option_categories_options', :foreign_key => 'option_id'
  has_and_belongs_to_many :product_types, :readonly => true
  
  has_many :tattribute_values, :dependent => :destroy
  has_many :dynamic_tattribute_values, :dependent => :destroy
  # TODO rename all tattribute_value to option_value
  has_many :option_values, :class_name => 'TattributeValue', :dependent => :destroy
  accepts_nested_attributes_for :option_values, :allow_destroy => true
  has_many :dynamic_option_values, :class_name => 'DynamicTattributeValue', :dependent => :destroy
  has_many :products, :through => :dynamic_tattribute_values, :readonly => true

#  validates_uniqueness_of :access_method
  
  before_save :clear_attributes

  def clone
    option = super
    option.option_values = self.option_values.collect(&:clone)
    %w(option_category_ids attachment_ids).each do |method|
      option.send("#{method}=",self.send(method))
    end
    option
  end

private
  def clear_attributes
    self.tattribute_values.destroy_all if self.dynamic?
  end
end
