class OptionCategory < Category
  has_and_belongs_to_many :elements, :class_name => 'Tattribute', :join_table => 'option_categories_options', :association_foreign_key => 'option_id'
end
