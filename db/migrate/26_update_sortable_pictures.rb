class UpdateSortablePictures < ActiveRecord::Migration
  def self.up
    # Save Elements associated with sortable_pictures in memory
    tempobjects = []
    SortablePicture.all.each do |pic|
      tempobject = TempObject.new
      if pic.product
        tempobject.id=pic.product.id
        tempobject.type='Product'
      elsif pic.tattribute
        tempobject.id=pic.tattribute.id
        tempobject.type=pic.tattribute.class.to_s
      elsif pic.attributes_group
        tempobject.id=pic.attributes_group.id
        tempobject.type=pic.attributes_group.class.to_s
      elsif pic.category
        tempobject.id=pic.category.id
        tempobject.type=pic.category.class.to_s
      end
      tempobject.picture_id=pic.picture.id
      tempobject.sort_id=pic.id
      
      tempobjects << tempobject
    end
    # Update database to assume polymorphic associations
    remove_column :sortable_pictures, :product_id, :category_id, :attribute_id, :attributes_group_id
    
    change_table :sortable_pictures do |t|
      t.belongs_to :picturable, :polymorphic => true
    end

    # Inject polymorphic Elements association
    tempobjects.each do |object|
      pic = SortablePicture.find_by_id(object.sort_id)
      pic.update_attribute(:picturable_id,object.id)
      pic.update_attribute(:picturable_type,object.type)
    end
  end

  def self.down
    # Add belongs_to columns
    change_table :sortable_pictures do |t|
      t.belongs_to :product, :category, :attribute, :attributes_group
    end

    # Associate elements with sortable_pictures
    SortablePicture.all.each do |pic|
      case pic.picturable_type
      when 'Product'
        pic.product_id = pic.picturable_id
      when 'Attribute'
        pic.attribute_id = pic.picturable_id
      when 'AttributesGroup'
        pic.attributes_group_id = pic.picturable_id
      when 'Category'
        pic.category_id = pic.picturable_id
      end
      pic.save
    end

    # Remove polymorphic association
    change_table :sortable_pictures do |t|
      t.remove_references :picturable, :polymorphic => true
    end
  end
end

class TempObject
  attr_accessor :id, :type, :picture_id, :sort_id
end
