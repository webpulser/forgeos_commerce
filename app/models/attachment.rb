require File.join(Rails.plugins[:forgeos_core].directory, 'app', 'models', 'attachement')

class Attachment < ActiveRecord::Base
  named_scope :linked_to_products, lambda {{:include => :attachment_links, :conditions => {:attachment_links => {:element_type => 'Product'}}}}
end
