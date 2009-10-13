class SpecialOfferRule < Rule
  has_and_belongs_to_many :special_offer_categories, :readonly => true, :join_table => 'categories_elements', :foreign_key => 'element_id', :association_foreign_key => 'category_id'
end
