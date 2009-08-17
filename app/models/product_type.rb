class ProductType < ActiveRecord::Base
  has_many :products
  has_many :vouchers
  has_and_belongs_to_many :tattributes, :readonly => true
  has_and_belongs_to_many :dynamic_tattributes, :class_name => 'Tattribute', :readonly => true, :join_table => 'product_types_tattributes', :association_foreign_key => 'tattribute_id',
    :conditions => {:dynamic => true}
  has_and_belongs_to_many :attachments, :list => true, :order => 'position'

  # Destroy all Product associated with this ProductType
  def after_destroy
    Product.destroy_all(['product_type_id = ?', self.id])
  end

  # Set all Products dynamic_tattributes on save
  def before_save
    self.products.each do |product|
      product.dynamic_tattributes = dynamic_tattributes
    end
  end
end
