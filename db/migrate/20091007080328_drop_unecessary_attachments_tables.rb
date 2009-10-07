class DropUnecessaryAttachmentsTables < ActiveRecord::Migration
  def self.up
    drop_table :attachments_attribute_values
    drop_table :attachments_attributes
    drop_table :attachments_categories
    drop_table :attachments_product_types
    drop_table :attachments_products
    drop_table :attachments_shipping_methods
    drop_table :attachments_users
  end

  def self.down
  end
end
