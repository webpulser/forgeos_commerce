class Brand < ActiveRecord::Base
  acts_as_commentable

  accepts_nested_attributes_for :comments
  belongs_to :picture

  has_many :products
  belongs_to :product_type

  validates_presence_of :name

  define_index do
    indexes name, :sortable => true
  end
end
