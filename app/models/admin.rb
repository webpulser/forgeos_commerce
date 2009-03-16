class Admin < Person
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :rights  
end 
