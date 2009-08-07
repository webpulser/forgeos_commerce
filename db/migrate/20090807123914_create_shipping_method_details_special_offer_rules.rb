class CreateShippingMethodDetailsSpecialOfferRules < ActiveRecord::Migration
  def self.up
    create_table :shipping_method_details_special_offer_rules, :id => false do |t|
      t.belongs_to :shipping_method_detail, :special_offer_rule
    end
  end

  def self.down
    drop_table :shipping_method_details_special_offer_rules
  end
end
