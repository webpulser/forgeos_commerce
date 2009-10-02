class Transporter < Rule
  
  has_and_belongs_to_many :attachments, :list => true, :order => 'position'
  has_many :shipping_methods
  validates_presence_of :name

end
