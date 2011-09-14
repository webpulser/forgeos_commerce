class Brand < ActiveRecord::Base
  acts_as_commentable

  accepts_nested_attributes_for :comments
  belongs_to :picture

  has_many :products
  belongs_to :product_type

  has_and_belongs_to_many :categories, :readonly => true, :join_table => 'categories_elements', :foreign_key => 'element_id', :association_foreign_key => 'category_id'

  validates :name, :presence => true

  define_index do
    indexes name, :sortable => true
  end

  def self.modify_import_attributes(attributes)
    attributes[:category_ids] = attributes.delete(:categories) unless attributes[:categories].blank?
    attributes
  end
end
