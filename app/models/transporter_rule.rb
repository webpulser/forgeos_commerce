class TransporterRule < Rule

  validates_presence_of :name
  has_and_belongs_to_many :attachments, :list => true, :order => 'position', :join_table => 'attachments_elements', :foreign_key => 'element_id'

end
