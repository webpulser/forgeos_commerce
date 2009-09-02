class TattributeCategory < Category
  has_and_belongs_to_many :tattributes
  has_and_belongs_to_many :options, :class_name => 'Tattribute'
end
