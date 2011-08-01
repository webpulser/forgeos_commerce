require 'ruleby'
class SpecialOfferRule < Rule
  include Ruleby
  has_and_belongs_to_many :special_offer_categories, :readonly => true, :join_table => 'categories_elements', :foreign_key => 'element_id', :association_foreign_key => 'category_id'
  before_save :validate_ruleby_syntax
  def validate_ruleby_syntax
    begin
      engine :special_offer_engine do |e|
        rule_builder = SpecialOffer.new(e)
        rule_builder.selected_products = []
        rule_builder.rule_preview(self)
        Product.actives.all(:limit => 100).each do |product|
          e.assert product
        end
        e.match
      end
    rescue Exception
      return false
    end
  end
end
