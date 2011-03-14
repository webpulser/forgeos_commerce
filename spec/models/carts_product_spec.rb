require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CartsProduct do
  before :each do
    @cart = Cart.create!
    @product = Product.create!({:url => "product", :name => "product", :sku => "001", :product_type_id => 1})
  end
  
  describe 'one cart_item' do
    before :each do
      @cart_item = @cart.cart_items.create!({:product => @product})
    end
    
    it "should have a cart" do
      @cart_item.cart.should == @cart
    end
    
    it "should have a product" do
      @cart_item.product.should == @product
    end
    
    it "must have a cart_id" do
      @cart_item = CartsProduct.new({:product_id => 1})
      @cart_item.should_not be_valid
      @cart_item.should have(1).errors_on(:cart_id)      
    end
    
    it "must have a product_id" do
      @cart_item = CartsProduct.new({:cart_id => 1})
      @cart_item.should_not be_valid
      @cart_item.should have(1).errors_on(:product_id)
    end
    
    it "should find a cart_item with find_by_id" do
      CartsProduct.find_by_id(@cart_item.id).should == @cart_item
    end  
  end
  
  describe 'all cart_items' do
    it "should list all cart_items" do
      expected_cart_items = []
      3.times do |i|
        expected_cart_items << @cart.cart_items.create!({:product => @product})
      end

      @cart_items = CartsProduct.all
      @cart_items.length.should == 3
      @cart_items.should == expected_cart_items
    end
  end
  
  describe 'new cart_item' do
    before(:each) do
      @cart_item = CartsProduct.new({:product => @product, :cart => @cart})
    end
    
    it "should be valid" do
      @cart_item.valid?.should == true
      @cart_item.cart.should == @cart
      @cart_item.product.should == @product
    end

    it "should save" do
      @cart_item.save
      CartsProduct.last.should == @cart_item
    end
  end
  
  describe 'delete cart_item' do
    before :each do
      @cart_item = @cart.cart_items.create!({:product => @product})
    end
    
    it "should destroy the cart_item" do
      @cart_item.destroy
      CartsProduct.last.should_not == @cart_item
    end
    
  end
  
  
end