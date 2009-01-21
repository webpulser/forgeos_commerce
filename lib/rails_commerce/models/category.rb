module RailsCommerce
  class Category < ActiveRecord::Base
    set_table_name "rails_commerce_categories"
    
    acts_as_tree
    
    has_and_belongs_to_many :products, :class_name => 'RailsCommerce::ProductParent', :association_foreign_key => 'product_id', :join_table => 'rails_commerce_categories_products'
    has_many :sortable_pictures, :class_name => 'RailsCommerce::SortablePicture', :dependent => :destroy
    has_many :pictures, :through => :sortable_pictures, :class_name => 'RailsCommerce::Picture', :readonly => true, :order => 'rails_commerce_sortable_pictures.position'

    # Returns the level of <i>RailsCommerce::Category</i>
    def level
      # TODO - Isn't implement in ActsAsTree... If not else to propose a "patch" in the future
      return self.ancestors.length
    end
  end
end
