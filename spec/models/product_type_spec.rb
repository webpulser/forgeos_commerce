require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProductType do
  describe 'one product_type' do
    before :each do 
      @product_type = ProductType.create!({:name => 'product_type'})
    end

    it "should have name product_type" do
      @product_type.name.should == 'product_type'
    end
 
    it "must have a name" do
      @product_type = ProductType.new
      @product_type.should_not be_valid
      @product_type.should have(1).errors_on(:name)
    end

    it "should find a product_type with find_by_id" do
      ProductType.find_by_id(@product_type.id).should == @product_type
    end

    it "should have products" do
      @products = []
      product_type = ProductType.create!({:name => "type"})
      (1..20).each do |i|
        product = product_type.products.create!({:url => "url_#{i}", :name => "test",:sku => "00#{i}"})
        @product_type.products << product
        @products << product
      end
      @product_type.products.all.should == @products
    end
    
    it "should have product_attributes" do
      @product_attributes = []
      (1..20).each do |i|
        product_attribute = @product_type.product_attributes.create!({:name => "product_attribute#{i}", :access_method => "access_#{i}"})
        @product_attributes << product_attribute
      end
      @product_type.product_attributes.should == @product_attributes
    end
    
    it "should have dynamic_attributes" do
      @dynamic_attributes = []
      (1..20).each do |i|
        dynamic_attribute = @product_type.dynamic_attributes.create!({:name => "dynamic_attribute#{i}", :access_method => "access_#{i}"})
        @dynamic_attributes << dynamic_attribute
      end
      @product_type.dynamic_attributes.all.should == @dynamic_attributes
    end
    
    it "should have attachments" do
      @attachments = []
      (1..20).each do |i|
        attachment = @product_type.attachments.create!
        @attachments << attachment
      end
      @product_type.attachments.all.should == @attachments
    end
    
    it "should have product_type_categories" do
      @product_type_categories = []
      (1..20).each do |i|
        product_type_category = @product_type.product_type_categories.create!({:name => "test#{i}"})
        @product_type_categories << product_type_category
      end
      @product_type.product_type_categories.all.should == @product_type_categories
    end
    
  end
  
  describe 'all product_types' do
    it "should list all product_types" do
      expected_product_types = []
      3.times do |i|
        expected_product_types << ProductType.create!(:name => "product_type_#{i}")
      end

      @product_types = ProductType.all
      @product_types.length.should == 3
      @product_types.should == expected_product_types
    end
  end
  
  describe 'new product_type' do
    before(:each) do
      @product_type = ProductType.new :name => "product_type"
    end
    
    it "should be valid" do
      @product_type.valid?.should == true
      @product_type.name.should == "product_type"
    end

    it "should save" do
      @product_type.save
      ProductType.last.should == @product_type
    end
  end

  describe 'edit/delete product_type' do
    before :each do
      @product_type = ProductType.create!(:name => "product_type")
      
      (1..20).each do |i|
        @product_type.products.create!({:url => "url_#{i}", :name => "test",:sku => "00#{i}"})
      end
      
    end
    
    # update
    it 'should update attributes' do
      @product_type.update_attributes(:name => 'new_product_type').should == true

      @new_product_type = ProductType.find_by_id(@product_type.id)
      @new_product_type.should_not == nil
      @new_product_type.name.should == 'new_product_type'
    end

    # delete
    it 'should destroy the product_type' do
      @product_type.destroy
      ProductType.last.should_not == @product_type
    end
    
    it "should destroy the linked products" do
      Product.all.length.should == 20
      @product_type.destroy
      Product.all.length.should == 0
    end
    
    #it 'should destroy the linked products' do
    #  product1 = @products[0]
    #  product2 = @products[4]
    #  @product_type.destroy
    #  Product.all.should == [product1, product2]
    #end
  end
end
