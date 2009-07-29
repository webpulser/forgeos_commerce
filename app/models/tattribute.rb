# Groups of <i>Attribute</i>
class Tattribute < ActiveRecord::Base
  sortable_attachments
  has_many :tattribute_values, :dependent => :destroy
  has_and_belongs_to_many :product_types, :readonly => true
  has_many :dynamic_tattribute_values, :dependent => :destroy
  has_many :product_details, :through => :dynamic_tattribute_values, :readonly => true
  
  before_save :clear_attributes

private
  def clear_attributes
    self.tattribute_values.destroy_all if self.dynamic?
  end
end
