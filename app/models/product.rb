class Product < ActiveRecord::Base
  translates :name, :description, :url
  attr_accessor :voucher_discount, :voucher_discount_price
  attr_accessor :special_offer_discount, :special_offer_discount_price
  
  acts_as_taggable

  has_and_belongs_to_many_attachments
  has_and_belongs_to_many :carts
  has_and_belongs_to_many :cross_sellings, :class_name => 'Product', :association_foreign_key => 'cross_selling_id', :foreign_key => 'product_id', :join_table => 'cross_sellings_products' 
  has_and_belongs_to_many :product_categories, :readonly => true, :join_table => 'categories_elements', :foreign_key => 'element_id', :association_foreign_key => 'category_id'  
  has_and_belongs_to_many :attribute_values, :readonly => true, :uniq => true

  has_many :dynamic_attribute_values, :dependent => :destroy
  has_many :dynamic_attributes, :through => :dynamic_attribute_values, :class_name => 'DynamicAttribute', :source => 'product'
  has_many :product_viewed_counters, :as => :element
  has_many :product_sold_counters, :as => :element

  belongs_to :product_type

  has_one :meta_info, :as => :target
  accepts_nested_attributes_for :meta_info

  validates_presence_of :product_type_id, :sku, :url
  #validates_uniqueness_of :url

  before_save :clean_strings
  after_save :synchronize_stock

  define_index do
    indexes sku, :sortable => true
    indexes name, :sortable => true
    indexes url, :sortable => true
    indexes stock, :sortable => true
    indexes price, :sortable => true
    indexes description, :sortable => true

    has active, deleted
  end

  def public_url
    unless product_categories.empty?
      category = product_categories.first
      if category.ancestors.empty?
        "/product/#{category.name}/#{self.url}"
      else
        "/product/#{category.ancestors.first.name}/#{category.name}/#{self.url}"
      end
    else
      '#'
    end
  end

  # Returns month's offers
  def self.get_offer_month
    find_by_active_and_deleted_and_offer_month(true,false,true)
  end

  # Returns the first page products
  def self.get_on_first_page
    find_all_by_active_and_deleted_and_on_first_page(true,false,true)
  end

  def attribute_of(attribute)
    attribute_values.find_by_attribute_id(attribute.id)
  end


  # Call by <i>before_save</i>
  # convert all blank strings to nil for attribute inheritance save
  def clean_strings
    self.class.columns.find_all{ |column| column.type == :string }.each do |field|
      send("#{field.name}=", nil) if self.attributes[field.name].blank?
    end
  end

  def clone
    product_cloned = super
    product_cloned.meta_info = meta_info.clone if meta_info
    product_cloned.dynamic_attribute_values = dynamic_attribute_values.collect(&:clone)
    %w(attachment_ids picture_ids tag_list product_category_ids attribute_value_ids).each do |assoc|
      product_cloned.send(assoc+'=', self.send(assoc))
    end
    return product_cloned
  end

  def synchronize_stock
    if active && stock.to_i < 1
      self.update_attribute('active', false)
    end
  end

  def cross_sellings
    Product.all(:conditions => { :active => true, :deleted => [false,nil], :id_ne => id}, :limit => 10, :order => 'RAND()')
  end
  
  def activate
    self.update_attribute('active', !self.active )
  end

  def soft_delete
    self.update_attribute('deleted', !self.deleted )
  end

  # Returns product's price without tax by default
  #
  # The currency of user is considered by default
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - false by defaults. Returns price with tax if true
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def price(with_tax=false, with_currency=true)
    price = super || 0
    price += tax(false) if with_tax
    return price if Currency::is_default? || !with_currency
    ("%01.2f" % (price * $currency.to_exchanges_rate(Currency::default).rate)).to_f
  end

  def new_price(with_voucher=false)
    price = self.price
    price -= self.special_offer_discount_price if self.special_offer_discount_price
    price -= self.voucher_discount_price if self.voucher_discount_price && with_voucher
    return price
  end

  # Returns price's string with currency symbol
  #
  # This method is an overload of <i>price</i> attribute.
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - false by defaults. Returns price with tax if true
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def price_to_s(with_tax=false, with_currency=true)
    "#{price(with_tax, with_currency)} #{$currency.html}"
  end

  # Returns total product's tax
  #
  # ==== Parameters
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  #
  # This method use <i>price</i> : <i>price(false, with_currency)</i>
  def tax(with_currency=true)
    return ("%01.2f" % (price(false, with_currency) * self.rate_tax/100)).to_f
  end

  def after_initialize()
    if product_type
      product_type.product_attributes.each do |attribute|
        self.class_eval <<DEF
        def #{attribute.access_method}
          attribute = Attribute.find(#{attribute.id})
          if attribute.dynamic?
            attribute_value = dynamic_attribute_values.find_by_attribute_id(attribute.id)
            attribute_value ? attribute_value.value : nil
          else
            attribute_values.find_all_by_attribute_id(attribute.id).collect(&:name)
          end
        end
DEF
      end
    end
  end
end
