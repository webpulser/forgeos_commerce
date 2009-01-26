class Picture < ActiveRecord::Base

  acts_as_commentable
  has_attachment :storage => :file_system, :file_system_path => 'public/images/products_pictures', :content_type => 'image', :thumbnails => { :big => '500x500', :normal => '200x200', :small => '100x100', :thumb => '50x50' }

  validates_presence_of :content_type

  has_many :sortable_pictures, :dependent => :destroy
  has_many :products, :through => :sortable_pictures
  has_many :tattributes, :through => :sortable_pictures
  has_many :attributes_groups, :through => :sortable_pictures
  has_many :categories, :through => :sortable_pictures
end
