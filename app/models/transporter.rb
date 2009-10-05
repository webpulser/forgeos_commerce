class Transporter < Rule
  
  has_and_belongs_to_many :attachments, :list => true, :order => 'position'
  has_and_belongs_to_many :attachments2, :list => true, :order => 'position', :join_table => 'attachments_elements', :foreign_key => 'element_id', :association_foreign_key => 'attachment_id', :class_name => 'Attachment'
  has_many :shipping_methods
  validates_presence_of :name

end
