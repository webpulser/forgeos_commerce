class FormAttribute < Attribute
  has_and_belongs_to_many :forms, :readonly => true
end