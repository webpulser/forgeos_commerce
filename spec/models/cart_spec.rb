require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cart do
  
  describe 'one cart' do
    before :each do
      @cart = Cart.create!
    end

    it "should have a user" do
      user = User.create!(:email => "test@webpulser.com", :firstname => "test", :lastname => "test", :password => "password", :password_confirmation => "password")
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
          product = product_type.products.create!({:url => "url_#{i}", :name => "test", :weight => "10"})
          cart_product = @cart.carts_products.create!({:quantity => "2", :product => product})
          @cart.carts_products << cart_product
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
        @cart.count_products.should == @products.size
      end
      
      it "should have a weight" do
        @cart.weight.should == 400
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
        @cart.remove_product(product)
        @cart.products.find_by_id(product.id).should == nil
      end
      
      it "should remove a product" do
        product = @products.first
        @cart.remove_product_id(product.id)
        @cart.products.first.should_not == product
      end
      
      it "should change the quantity" do
        product = @products.first
        @cart.set_quantity(product, 5)
        @cart.carts_products.find_by_product_id(product.id).quantity.should == 5
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
      @cart = Cart.create
    end
    
    # update
#    it 'should update attributes' do
#      @cart.update_attributes.should == true

#      @new_cart = Cart.find_by_id(@cart.id)
#      @new_cart.should_not == nil
#      @cart.title.should == "new_webpulser"
#      @cart.cart.should == "hello"
#    end

    # delete
    it 'should destroy the cart' do
      @cart.destroy
      Cart.last.should_not == @cart
    end
  end
end
