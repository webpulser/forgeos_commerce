class UserAddress < Address
  belongs_to :user
  belongs_to :order

  validates_presence_of :civility, :designation
end
