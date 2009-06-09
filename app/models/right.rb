class Right < ActiveRecord::Base
  has_and_belongs_to_many :admins
  has_and_belongs_to_many :roles

  #check that fields have data in them
  validates_presence_of :name, :controller_name, :action_name
end
