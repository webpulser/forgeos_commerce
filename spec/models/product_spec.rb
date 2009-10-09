require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Product do
  
  describe 'one product' do
    before :each do
      @product_type = ProductType.create!({:name => 'product_type'})
      @product = Product.create!({:url => "product", :name => "product", :sku => "001", :product_type_id => @product_type.id})
    end
    
    it "should have name product" do
      @product.name.should == 'product'
    end
    
    it "should have url product" do
      @product.url.should == 'product'
    end
    
    it "should have sku 001" do
      @product.sku.should == '001'
    end
    
    it "should have a unique url" do
      @second_product = Product.new({:url => "product", :name => "product", :sku => "001", :product_type_id => @product_type.id})
      @second_product.should_not be_valid
      @second_product.should have(1).errors_on(:url)
    end
    
    it "should find a product with find_by_id" do
      Product.find_by_id(@product.id).should == @product
    end
    
    it "should have product_categories" do
      @product_categories = []
      (1..20).each do |i|
        product_category = @product.product_categories.create!({:name => "test#{i}"})
        @product_categories << product_category
      end
      @product.product_categories.all.should == @product_categories
    end
    
    it "should have attachments" do
      @attachments = []
      (1..20).each do |i|
        attachment = @product.attachments.create!
        @attachments << attachment
      end
      @product.attachments.all.should == @attachments
    end
    
    it "should have attribute_values" do
      @attribute = Attribute.create!({:name => "attribute", :access_method => 'attribute'})
      @attribute_values = []
      (1..20).each do |i|
        attribute_value = @product.attribute_values.create!({:name => "test#{i}", :attribute_id => @attribute.id})
        @attribute_values << attribute_value
      end
      @product.attribute_values.all.should == @attribute_values
    end
    
    it "should have dynamic_attribute_values" do
      @attribute = Attribute.create!({:name => "attribute", :access_method => 'attribute'})
      @dynamic_attribute_values = []
      (1..20).each do |i|
        dynamic_attribute_value = @product.dynamic_attribute_values.create!({:value=> "test#{i}", :attribute_id => @attribute.id})
        @dynamic_attribute_values << dynamic_attribute_value
      end
      @product.dynamic_attribute_values.all.should == @dynamic_attribute_values
    end
    
  end
  
  describe 'all products' do
    it "should list all products" do
      expected_products = []
      3.times do |i|
        expected_products << Product.create!({:url => "product_#{i}", :name => "product", :sku => "001", :product_type_id => 1})
      end

      @products = Product.all
      @products.length.should == 3
      @products.should == expected_products
    end
  end
  
  describe 'new product' do
    before(:each) do
      @product_type = ProductType.create!({:name => 'product_type'})
      @product = Product.new({:url => "product", :name => "product", :sku => "001", :product_type_id => @product_type.id})
    end
    
    it "should be valid" do
      @product.valid?.should == true
      @product.name.should == "product"
      @product.url.should == "product"
      @product.sku.should == "001"
      @product.product_type.id.should == @product_type.id
    end

    it "should save" do
      @product.save
      Product.last.should == @product
    end
  end
  
  describe 'edit/delete product' do
    before :each do
      @product_type = ProductType.create!({:name => 'product_type'})
      @product = Product.create!({:url => "product", :name => "product", :sku => "001", :product_type_id => @product_type.id})
    end
    
    # update
    it 'should update attributes' do
      @product.update_attributes(:name => 'new_product', :url => "new_product", :sku => "new_sku", :product_type_id => 2).should == true

      @new_product = ProductType.find_by_id(@product_type.id)
      @new_product.should_not == nil
      @product.name.should == 'new_product'
      @product.url.should == 'new_product'
      @product.sku.should == 'new_sku'
    end

    # delete
    it 'should destroy the product' do
      @product.destroy
      Product.last.should_not == @product
    end

  end
  
  
end