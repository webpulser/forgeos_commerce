class UserAddress < Address
  belongs_to :user, :foreign_key => 'person_id'
  belongs_to :order

  validates :civility, :designation, :presence => true
end
