class RemoveUserIdFromAddresses < ActiveRecord::Migration
  def self.up
    Address.all.each do |address|
      address.update_attribute(:person_id, address.user_id) if address.respond_to?(:user_id) and address.user_id.present?
    end
    remove_column :addresses, :user_id
  end

  def self.down
    add_column :addresses, :user_id, :integer
    Address.all.each do |address|
      address.update_attribute(:user_id, address.person_id) if address.respond_to?(:user_id) and address.person_id.present?
    end
  end
end
