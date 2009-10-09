class Transporter < ActiveRecord::Base

  has_and_belongs_to_many :attachments, :list => true, :order => 'position', :join_table => 'attachments_elements', :foreign_key => 'element_id'
  has_many :shipping_methods, :dependent => :destroy


  validates_presence_of :name

end
