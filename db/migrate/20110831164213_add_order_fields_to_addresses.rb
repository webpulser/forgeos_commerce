class AddOrderFieldsToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :order_id, :integer
    add_column :addresses, :civility, :integer
    add_column :addresses, :designation, :string
    add_column :addresses, :firstname, :string
    add_column :addresses, :lastname, :string
  end
end
