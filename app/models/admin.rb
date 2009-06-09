class Admin < Person
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :rights  
  attr_accessible :right_ids, :role_ids
  before_create :activate
end 
