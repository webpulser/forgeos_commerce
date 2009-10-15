require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CartsProduct do
  before :each do
    @cart = Cart.create!
    @product = Product.create!({:url => "product", :name => "product", :sku => "001", :product_type_id => 1})
  end
  
  describe 'one carts_product' do
    before :each do
      @carts_product = @cart.carts_products.create!({:product => @product})
    end
    
    it "should have a cart" do
      @carts_product.cart.should == @cart
    end
    
    it "should have a product" do
      @carts_product.product.should == @product
    end
    
    it "must have a cart_id" do
      @carts_product = CartsProduct.new({:product_id => 1})
      @carts_product.should_not be_valid
      @carts_product.should have(1).errors_on(:cart_id)      
    end
    
    it "must have a product_id" do
      @carts_product = CartsProduct.new({:cart_id => 1})
      @carts_product.should_not be_valid
      @carts_product.should have(1).errors_on(:product_id)
    end
    
    it "should find a carts_product with find_by_id" do
      CartsProduct.find_by_id(@carts_product.id).should == @carts_product
    end  
  end
  
  describe 'all carts_products' do
    it "should list all carts_products" do
      expected_carts_products = []
      3.times do |i|
        expected_carts_products << @cart.carts_products.create!({:product => @product})
      end

      @carts_products = CartsProduct.all
      @carts_products.length.should == 3
      @carts_products.should == expected_carts_products
    end
  end
  
  describe 'new carts_product' do
    before(:each) do
      @carts_product = CartsProduct.new({:product => @product, :cart => @cart})
    end
    
    it "should be valid" do
      @carts_product.valid?.should == true
      @carts_product.cart.should == @cart
      @carts_product.product.should == @product
    end

    it "should save" do
      @carts_product.save
      CartsProduct.last.should == @carts_product
    end
  end
  
  describe 'delete carts_product' do
    before :each do
      @carts_product = @cart.carts_products.create!({:product => @product})
    end
    
    it "should destroy the carts_product" do
      @carts_product.destroy
      CartsProduct.last.should_not == @carts_product
    end
    
  end
  
  
end