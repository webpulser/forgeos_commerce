class Product < ActiveRecord::Base

  acts_as_taggable_on :tags

  has_and_belongs_to_many :carts
  has_and_belongs_to_many :product_categories, :readonly => true
  
  has_and_belongs_to_many :attachments, :list => true, :order => 'position'
  has_and_belongs_to_many :pictures, :association_foreign_key => 'attachment_id', :join_table => 'attachments_products', :class_name => 'Picture', :order => 'position'
  has_and_belongs_to_many :pdfs, :association_foreign_key => 'attachment_id', :join_table => 'attachments_products', :class_name => 'Pdf', :order => 'position'

  has_and_belongs_to_many :tattribute_values, :readonly => true
  has_many :dynamic_tattribute_values, :dependent => :destroy
  has_many :dynamic_tattributes, :through => :dynamic_tattribute_values, :class_name => 'Tattribute', :source => 'tattribute'

  # TODO rename all tattribute to option
  has_and_belongs_to_many :option_values, :class_name => 'TattributeValue', :readonly => true
  has_many :dynamic_option_values, :class_name => 'DynamicTattributeValue', :dependent => :destroy
  has_many :dynamic_options, :through => :dynamic_option_values, :class_name => 'Tattribute', :source => 'tattribute'

  has_and_belongs_to_many :cross_sellings, :class_name => 'Product', :association_foreign_key => 'cross_selling_id', :foreign_key => 'product_id', :join_table => 'cross_sellings_products'
  belongs_to :product_type
  has_many :product_viewed_counters, :as => :element
  has_many :product_sold_counters, :as => :element

  before_save :clean_strings
  after_save :synchronize_stock

  validates_presence_of :product_type_id
  validates_presence_of :url
  validates_uniqueness_of :url
  has_one :meta_info, :as => :target
  accepts_nested_attributes_for :meta_info


  define_index do
    indexes sku, :sortable => true
    indexes name, :sortable => true
    indexes url, :sortable => true
    indexes stock, :sortable => true
    indexes price, :sortable => true
    indexes description, :sortable => true

    has active, deleted
  end
  #acts_as_ferret YAML.load_file(File.join(RAILS_ROOT, 'config', 'search.yml'))['product'].symbolize_keys


  # Returns month's offers
  def self.get_offer_month
    find_by_active_and_deleted_and_offer_month(true,false,true)
  end

  # Returns the first page products
  def self.get_on_first_page
    find_all_by_active_and_deleted_and_on_first_page(true,false,true)
  end

  def attribute_of(tattribute)
    tattribute_values.find_by_tattribute_id(tattribute.id)
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
    product_cloned.meta_info = meta_info.clone
    product_cloned.dynamic_option_values = dynamic_option_values.collect(&:clone)
    %w(attachment_ids picture_ids tag_list product_category_ids option_value_ids).each do |assoc|
      product_cloned.send(assoc+'=', self.send(assoc))
    end
    return product_cloned
  end

  def synchronize_stock
    if active && stock.to_i < 1
      self.update_attribute('active', false)
    end
  end
  
  def activate
    self.update_attribute('active', !self.active )
  end

  def soft_delete
    self.update_attribute('deleted', !self.deleted )
  end

  # Overload the description attribute.
  #
  # Returns a empty string if <i>description</i> is <i>nil</i>
  def description
    (super.nil?) ? "" : super
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

  # Returns an <i>Array</i> of <i>Product</i> who match gived keyword
  # ==== Parameters
  # * <tt>:keyword</tt> - a keyword
#  def self.search(keyword, options = { :limit => :all })
#    Product.find_with_ferret("%#{keyword}%",options)
#  end

  # Returns a <i>WillPaginate::Collection</i> of <i>Product</i> who match gived keyword
  #
  # ==== Parameters
  # * <tt>:keyword</tt> - a keyword
  # ==== paginate_options
  # * <tt>:page</tt> - page number
  # * <tt>:per_page</tt> - product's count by page
#  def self.search_paginate(keyword, page=1, per_page=8)
#    self.search(keyword).paginate(:page => page, :per_page => per_page)
#  end

  def method_missing_with_attribute(method, *args, &block)
    unless self.product_type && tattribute = self.product_type.tattributes.find_by_access_method(method.to_s)
      method_missing_without_attribute(method, *args, &block)
    else
      if tattribute.dynamic
        if attr_value = self.dynamic_tattribute_values.find_by_tattribute_id(tattribute.id)
          return attr_value.value
        else
          method_missing_without_attribute(method, *args, &block)
        end
      else
        self.tattribute_values.find_all_by_tattribute_id(tattribute.id).collect(&:name)
      end
    end
  end

  alias_method_chain :method_missing, :attribute
  
end
