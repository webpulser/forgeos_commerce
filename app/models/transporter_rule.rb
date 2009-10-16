class TransporterRule < Rule

  has_and_belongs_to_many :attachments, :list => true, :order => 'position', :join_table => 'attachments_elements', :foreign_key => 'element_id'

end
