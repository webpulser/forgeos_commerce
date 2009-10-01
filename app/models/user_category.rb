class UserCategory < Category
  has_and_belongs_to_many :users
  has_and_belongs_to_many :elements, :class_name => 'User'
end
