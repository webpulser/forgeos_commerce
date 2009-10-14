require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cart do
  
  describe 'one cart' do
    before :each do
      @cart = Cart.create!
    end

    it "should have a user" do
      user = User.create!(:email => "test@webpulser.com", :firstname => "test", :lastname => "test", :password => "password", :password_confirmation => "password", :country_id => 1)
      @cart.user = user
      @cart.user.should == user
    end
    
    it "should say it is empty when there are no products" do
      @cart.is_empty?.should == true
    end
    
    context "there are products" do
      before :each do
        product_type = ProductType.create!({:name => "type"})
        @products = []
        @carts_products = []
        (1..20).each do |i|
          product = product_type.products.create!({:url => "url_#{i}", :name => "test", :sku => i})
          cart_product = @cart.carts_products.create!({:product => product})
          @products << product
          @carts_products << cart_product
        end
      end
      
      it "should have cart products" do
        @cart.carts_products.all.should == @carts_products
      end

      it "should have products" do
        @cart.products.all.should == @products
      end
      
      it "should count products" do
        @cart.products.count.should == @products.size
      end
            
      it "should say it is not empty when there are products" do
        @cart.is_empty?.should == false
      end

      it "should empty the product list" do
        @cart.to_empty
        @cart.is_empty?.should == true
      end
      
      it "should remove a product" do
        product = @products.first
        @cart.remove_product(product.id)
        @cart.products.find_by_id(product.id).should == nil
      end
    end
  end
  
  describe 'all carts' do
    it "should list all carts" do
      expected_carts = []
      3.times do |i|
        expected_carts << Cart.create!
      end

      @carts = Cart.all
      @carts.length.should == 3
      @carts.should == expected_carts
    end
  end
  
  describe 'new cart' do
    before(:each) do
      @cart = Cart.new
    end
    
    it "should be valid" do
      @cart.valid?.should == true
    end

    it "should save" do
      @cart.save
      Cart.last.should == @cart
    end
  end

  describe 'edit/delete cart' do
    before :each do
      @cart = Cart.create!
      product_type = ProductType.create!({:name => "type"})
      (1..5).each do |i|
        product = product_type.products.create!({:url => "url_#{i}", :name => "test", :sku => i})
        cart_product = @cart.carts_products.create!({:product => product})
      end  
    end
    
    # delete
    it 'should destroy the cart' do
      @cart.destroy
      Cart.last.should_not == @cart
    end
    
    it 'should destroy the carts_product' do
      CartsProduct.all.length.should == 5
      @cart.destroy
      CartsProduct.all.length.should == 0
    end
    
  end
end
