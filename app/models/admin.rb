require 'digest/sha1'

class Admin < ActiveRecord::Base
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :rights
  belongs_to :avatar, :class_name => 'Picture', :dependent => :destroy
  
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 5..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  
  validates_presence_of     :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of   :email,    :case_sensitive => false
  
  attr_protected :id, :salt

  attr_accessor :password, :password_confirmation
  
  def password=(pass)
    @password=pass
    self.salt = Admin.random_string(10) if !self.salt?
    self.hashed_password = Admin.encrypt(@password, self.salt)
  end
  
  protected

  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass+salt)
  end

  def self.random_string(len)
    #generate a random password consisting of strings and digits
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
  
  def password_required?
    !has_id? && (hashed_password.blank? || password.blank?)
  end
  
  def has_id?
    !id.blank?
  end
    
end
