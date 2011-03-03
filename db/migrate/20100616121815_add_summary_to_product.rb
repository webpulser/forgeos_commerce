class AddSummaryToProduct < ActiveRecord::Migration
  def self.up
    add_column :product_translations, :summary, :string
  end

  def self.down
    remove_column :product_translations, :summary
  end
end
