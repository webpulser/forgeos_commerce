class CreateProductsSpecialOfferRules < ActiveRecord::Migration
  def self.up
    create_table :products_special_offer_rules, :id => false do |t|
      t.belongs_to :product, :special_offer_rule
    end
  end

  def self.down
    drop_table :products_special_offer_rules
  end
end
