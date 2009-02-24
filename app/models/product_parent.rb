# ==== Inheritance
# * <tt>Product</tt>
class ProductParent < Product
  has_many :product_details, :foreign_key => 'product_id', :dependent => :destroy, :order => 'active DESC'
  has_and_belongs_to_many :cross_sellings, :class_name => 'ProductParent', :join_table => 'cross_sellings_product_parents'

  has_and_belongs_to_many :attributes_groups, :readonly => true
  has_and_belongs_to_many :dynamic_attributes_groups, :class_name => 'AttributesGroup', :readonly => true, :join_table => 'attributes_groups_product_parents', :association_foreign_key => 'attributes_group_id',
    :conditions => ['attributes_groups.dynamic IS TRUE']

  def activate
    product_details.each do |product_detail|
      product_detail.update_attribute('active', !self.active )
    end
    super
  end

  def soft_delete
    product_details.each do |product_detail|
      product_detail.update_attribute('deleted', !self.deleted )
    end
    super
  end

  def stock
    product_details.sum('stock')
  end

  # Destroy all ProductDetails associated with this ProductParent
  def after_destroy
    ProductDetail.destroy_all(['product_id = ?', self.id])
  end

  # Create a ProductDetail after a ProductParent creation
  def after_create
    self.product_details.create
  end

  # Set all ProductDetails dynamic_attributes_groups on save
  def before_save
    self.product_details.each do |product_detail|
      product_detail.dynamic_attributes_groups = dynamic_attributes_groups
    end
  end

  def initialize(options={})
    self.is_instanciable = true
    super(options)
  end

  def price(with_tax=false, with_currency=true)
    #raise RailsCommerceException.new(:code => 101) if product_details.size > 1
    super(with_tax, with_currency)
  end

  def price_to_s(with_tax=false, with_currency=true)
    return RailsCommerce::OPTIONS[:text][:na] unless product_details.empty?
  end
end
