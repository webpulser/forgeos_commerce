class Comment < ActiveRecord::Base
  validates_presence_of :title, :comment
  belongs_to :user, :class_name => 'Person'
end
