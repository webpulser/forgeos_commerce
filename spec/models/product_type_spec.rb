require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProductType do
  describe 'one product_type' do
    before :each do 
      @product_type = ProductType.create!({:name => 'product_type'})
    end

    it "should have name product_type" do
      @product_type.name.should == 'product_type'
    end

    it "should find a product_type with find_by_id" do
      ProductType.find_by_id(@product_type.id).should == @product_type
    end

    it "should have products" do
      @products = []
      product_type = ProductType.create!({:name => "type"})
      (1..20).each do |i|
        product = product_type.products.create!({:url => "url_#{i}", :name => "test"})
        @product_type.products << product
        @products << product
      end
      @product_type.products.all.should == @products
    end
    
    it "should have vouchers" do
      @vouchers = []
      product_type = ProductType.create!({:name => "type"})
      (1..20).each do |i|
        voucher = product_type.vouchers.create!({:code => i, :name => "voucher#{i}", :value => "10", :total_min => "10", :date_start => Date.today, :date_end => Date.today + 1})
        @product_type.vouchers << voucher
        @vouchers << voucher
      end
      @product_type.vouchers.all.should == @vouchers
    end
    
    it "should have tattributes" do
      @tattributes = []
      product_type = ProductType.create!({:name => "type"})
      (1..20).each do |i|
        tattribute = product_type.tattributes.create!({:name => "test#{i}"})
        @product_type.tattributes << tattribute
        @tattributes << tattribute
      end
      @product_type.tattributes.all.should == @tattributes
    end
    
    it "should have dynamic tattributes" do
      @dynamic_tattributes = []
      product_type = ProductType.create!({:name => "type"})
      (1..20).each do |i|
        dynamic_tattribute = product_type.dynamic_tattributes.create!({:name => "test"})
        @product_type.dynamic_tattributes << dynamic_tattribute
        @dynamic_tattributes << dynamic_tattribute
      end
      @product_type.dynamic_tattributes.all.should == @dynamic_tattributes
    end
    
    it "should add the attributes for the products" do
      @products = []
      @products << @product_type.products.create!({:url => "the_sphere", :name => "The sphere"})
      @products << @product_type.products.create!({:url => "rails_social", :name => "Rails social"})
      @products << @product_type.products.create!({:url => "forgeos_cms", :name => "Rails content"})
      @products << @product_type.products.create!({:url => "forgeos_commerce", :name => "ForgeosCommerce"})
      @products << @product_type.products.create!({:url => "webpulser", :name => "Webpulser"})
      @products << @product_type.products.create!({:url => "forgeos", :name => "Forgeos"})
      
      @products.each do |product|
        product.dynamic_tattributes.should == @product_type.dynamic_tattributes
      end
    end
  end
  
  describe 'all product_types' do
    it "should list all product_types" do
      expected_product_types = []
      3.times do |i|
        expected_product_types << ProductType.create!(:name => "product_type ")
      end

      @product_types = ProductType.all
      @product_types.length.should == 3
      @product_types.should == expected_product_types
    end
  end
  
  describe 'new product_type' do
    before(:each) do
      @product_type = ProductType.new :name => "Webpulser"
    end
    
    it "should be valid" do
      @product_type.valid?.should == true
      @product_type.name.should == "Webpulser"
    end

    it "should save" do
      @product_type.save
      ProductType.last.should == @product_type
    end
  end

  describe 'edit/delete product_type' do
    before :each do
      @product_type = ProductType.create :name => "Webpulser"
      product_type2 = ProductType.create :name => "Test"
      @products = []
      @products << product_type2.products.create!({:url => "the_sphere", :name => "The sphere"})
      @products << @product_type.products.create!({:url => "rails_social", :name => "Rails social"})
      @products << @product_type.products.create!({:url => "forgeos_cms", :name => "ForgeosCMS"})
      @products << @product_type.products.create!({:url => "forgeos_commerce", :name => "ForgeosCommerce"})
      @products << product_type2.products.create!({:url => "webpulser", :name => "Webpulser"})
      @products << @product_type.products.create!({:url => "forgeos", :name => "Forgeos"})
    end
    
    # update
    it 'should update attributes' do
      @product_type.update_attributes(:name => 'new_webpulser').should == true

      @new_product_type = ProductType.find_by_id(@product_type.id)
      @new_product_type.should_not == nil
      @new_product_type.name.should == 'new_webpulser'
    end

    # delete
    it 'should destroy the product_type' do
      @product_type.destroy
      ProductType.last.should_not == @product_type
    end
    
    it 'should destroy the linked products' do
      product1 = @products[0]
      product2 = @products[4]
      @product_type.destroy
      Product.all.should == [product1, product2]
    end
  end
end
