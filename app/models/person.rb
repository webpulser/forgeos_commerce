require 'digest/sha1'
class Person < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  belongs_to :avatar, :class_name => 'Picture', :dependent => :destroy
  
  validates_presence_of     :lastname, :firstname, :email
  validates_length_of       :email,    :within => 3..100, :too_long => "is too long", :too_short => "is too short"
  validates_uniqueness_of   :email, :case_sensitive => false, :message => "is invalid"
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  before_create :make_activation_code 
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :lastname, :firstname, :email, :password, :password_confirmation

  def fullname
    "#{lastname} #{firstname}"
  end

  # Disactivates the user in the database.
  def disactivate
    self.activated_at = nil
    make_activation_code
    save(false) unless self.new_record?
  end

  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false) unless self.new_record?
  end

  # return the user status
  # the existence of an activation code means they have not activated
  def active?
    activation_code.nil?
  end

  # Authenticates a user by their email name and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

protected
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

end
