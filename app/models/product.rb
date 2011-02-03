class Product < ActiveRecord::Base
  translates :name, :description, :summary, :url
  attr_accessor :voucher_discount, :voucher_discount_price,
    :special_offer_discount, :special_offer_discount_price,
    :price_variation_id, :price_variation

  acts_as_taggable

  has_and_belongs_to_many_attachments
  has_many :sizes, :dependent => :destroy
  has_and_belongs_to_many :carts

  has_many :cross_sellings_products, :dependent => :destroy
  has_many :cross_sellings, :through => :cross_sellings_products, :class_name => 'Product'
  accepts_nested_attributes_for :cross_sellings
  accepts_nested_attributes_for :cross_sellings_products

  has_many :price_variations, :dependent => :destroy, :class_name => 'ProductPriceVariation'
  accepts_nested_attributes_for :price_variations

  has_and_belongs_to_many :product_categories, :readonly => true, :join_table => 'categories_elements', :foreign_key => 'element_id', :association_foreign_key => 'category_id'
  has_and_belongs_to_many :categories, :readonly => true, :join_table => 'categories_elements', :foreign_key => 'element_id', :association_foreign_key => 'category_id', :class_name => 'ProductCategory'
  has_and_belongs_to_many :attribute_values, :readonly => true, :uniq => true

  has_many :dynamic_attribute_values, :dependent => :destroy
  has_many :dynamic_attributes, :through => :dynamic_attribute_values, :class_name => 'DynamicAttribute', :source => 'product'
  accepts_nested_attributes_for :dynamic_attribute_values
  has_many :viewed_counters, :as => :element, :class_name => 'ProductViewedCounter', :dependent => :destroy
  has_many :sold_counters, :as => :element, :class_name => 'ProductSoldCounter', :dependent => :destroy

  belongs_to :product_type
  belongs_to :brand

  has_one :meta_info, :as => :target
  accepts_nested_attributes_for :meta_info
  accepts_nested_attributes_for :sizes, :allow_destroy => true

  validates_presence_of :product_type_id, :sku, :url
  #validates_uniqueness_of :url

  before_save :clean_strings, :force_url_format, :generate_url
  after_save :synchronize_stock

  belongs_to :redirection_product, :class_name => 'Product'

  belongs_to :brand

  named_scope :actives, lambda { {:conditions => {:active => true, :deleted => [false, nil]}} }
  named_scope :deleted, lambda { {:conditions => {:deleted => true}} }
  named_scope :hiddens, lambda { {:conditions => {:active => [false, nil], :deleted => [false, nil]}} }
  named_scope :out_of_stock, lambda { {:conditions => {:stock_lte => 0}} }

  define_index do
    indexes sku, :sortable => true
    indexes stock, :sortable => true
    indexes price, :sortable => true
    indexes brand(:name), :as => :brand
    indexes product_type.translations(:name), :as => :product_type_name

    indexes attachments(:name), :as => :firstnames
    indexes categories.translations(:name), :as => :category_names

    has active, deleted
    has categories(:id), :as => :category_ids
    set_property :min_prefix_len => 1
    set_property :enable_star => 1
  end

  define_translated_index :name, :description, :url

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

  def redirection_product_with_deleted
    return (redirection_product_without_deleted && redirection_product_without_deleted.deleted? ? redirection_product_without_deleted.redirection_product : redirection_product_without_deleted)
  end
  alias_method_chain :redirection_product, :deleted

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

  def clone
    product_cloned = super
    product_cloned.meta_info = meta_info.clone if meta_info
    product_cloned.translations = translations.clone unless translations.empty?
    product_cloned.dynamic_attribute_values = dynamic_attribute_values.collect(&:clone)
    %w(attachment_ids picture_ids tag_list product_category_ids attribute_value_ids).each do |assoc|
      product_cloned.send(assoc+'=', self.send(assoc))
    end
    return product_cloned
  end

  def synchronize_stock
    if stop_sales? && active? && stock.to_i < 1
      self.update_attribute('active', false)
    end
  end

  def activate
    self.update_attribute('active', !self.active? )
  end

  def soft_delete
    self.update_attribute('deleted', !self.deleted? )
  end

  # Returns product's price without tax by default
  #
  # The currency of user is considered by default
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - false by defaults. Returns price with tax if true
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def price(with_tax=false, with_currency=true, with_voucher=false,with_special_offer=false)
    price = read_attribute(:price) || 0
    price += tax(with_currency) if with_tax
    price -= self.special_offer_discount_price if with_special_offer and self.special_offer_discount_price
    price -= self.voucher_discount_price if with_voucher and self.voucher_discount_price
    price -= (price * price_variation.discount) / 100 if price_variation
    price
  end

  def new_price(with_voucher=false)
    price(false,true,with_voucher,true)
  end

  # Returns price's string with currency symbol
  #
  # This method is an overload of <i>price</i> attribute.
  #
  # ==== Parameters
  # * <tt>:with_tax</tt> - false by defaults. Returns price with tax if true
  # * <tt>:with_currency</tt> - true by defaults. The currency of user is considered if true
  def price_to_s(*args)
    price(args).to_s
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

  def has_special_offers?
    if self.new_price != self.price
      return true
    else
      selected_products = []
      engine :special_offer_engine do |e|
        begin
          rule_builder = SpecialOffer.new(e)
          rule_builder.selected_products = selected_products
          rule_builder.rules
        rescue Exception
        end
        e.assert self
        e.match
      end
      return !selected_products.blank?
    end
  end

  def method_missing(method_id,*args,&block)
    method_name = method_id.to_s
    if cat_id = method_name.match(/has_category_(\d+)/)
      return product_category_ids.include?(cat_id[1].to_i)
    elsif access_method = method_name.match(/^(\w|\d|_|-)*$/) and product_type and
      custom_attribute = product_type.product_attributes.find_by_access_method(access_method[0])
      read_custom_attribute(custom_attribute, args.first)
    elsif access_method = method_name.match(/^(\w|\d|_|-)*_value$/) and product_type and
      custom_attribute = product_type.product_attributes.find_by_access_method(access_method[0].gsub('_value',''))
      read_custom_attribute(custom_attribute, :value)
    elsif access_method = method_name.match(/^(\w|\d|_|-)*=$/) and product_type and
      custom_attribute = product_type.product_attributes.find_by_access_method(access_method[0].gsub('=',''))
      write_custom_attribute(custom_attribute, args.first)
    else
      super
    end
  end

  def respond_to?(method, include_priv = false)
    method_name = method.to_s
    if access_method = method_name.match(/^(\w|\d|_|-)*$/) and product_type and
      custom_attribute = product_type.product_attributes.find_by_access_method(access_method[0])
      return true
    elsif access_method = method_name.match(/^(\w|\d|_|-)*_value$/) and product_type and
      custom_attribute = product_type.product_attributes.find_by_access_method(access_method[0].gsub('_value',''))
      return true
    elsif access_method = method_name.match(/^(\w|\d|_|-)*=$/) and product_type and
      custom_attribute = product_type.product_attributes.find_by_access_method(access_method[0].gsub('=',''))
      return true
    else
      super
    end
  end
  private

  def read_custom_attribute(attribute, method)
    if attribute.dynamic?
      if attribute_value = dynamic_attribute_values.find_by_attribute_id(attribute.id)
        method ? attribute_value.send(method.to_sym) : attribute_value
      else
        nil
      end
    else
      values = attribute_values.find_all_by_attribute_id(attribute.id)
      value = method ? values.map(&method.to_sym) : values
      return case attribute
      when RadiobuttonAttribute, PicklistAttribute
        value.first
      else
        value
      end
    end
  end

  def write_custom_attribute(attribute, new_value)
    if attribute.dynamic?
      if attribute_value = dynamic_attribute_values.find_by_attribute_id(attribute.id)
        self.dynamic_attribute_values_attributes= { attribute_value.id => { :id => attribute_value.id, :value => new_value } }
      else
        self.dynamic_attribute_values_attributes= { '-1' => { :value => new_value, :attribute_id => attribute.id} }
      end
    else
      other_attributes = self.attribute_values.all(:conditions => {:attribute_id_not => attribute.id})
      if new_value.nil?
        new_attributes = []
      elsif new_value.kind_of?(AttributeValue)
        new_attributes = [new_value]
      elsif new_value.kind_of?(Array) && new_value.first.kind_of?(AttributeValue)
        new_attributes = new_value.flatten
      else
        new_attributes = AttributeValue.find_all_by_attribute_id(
          attribute.id,
          :include => [:translations],
          :conditions => { :attribute_value_translations => { :name => [new_value].flatten } }
        )
      end
      self.attribute_values = new_attributes + other_attributes
    end

  end

  # Call by <i>before_save</i>
  # convert all blank strings to nil for attribute inheritance save
  def clean_strings
    self.class.columns.find_all{ |column| column.type == :string }.each do |field|
      send("#{field.name}=", nil) if self.attributes[field.name].blank?
    end
  end

  def force_url_format
    self.url= Forgeos::url_generator(self.url)
  end

  def generate_url
    return true if url.present?
    self.url = name.parameterize if name.present?
  end
end
