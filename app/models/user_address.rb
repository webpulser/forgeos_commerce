class UserAddress < Address
  belongs_to :user, :foreign_key => 'person_id'
  belongs_to :order

  validates_presence_of :civility, :designation
end
