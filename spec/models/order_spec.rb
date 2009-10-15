require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Order do
  before :each do
    @user = User.create!(:email => "test@webpulser.com", :firstname => "test", :lastname => "test", :password => "password", :password_confirmation => "password", :country_id => 1)
    @order_shipping = OrderShipping.create!
    @address_invoice = AddressInvoice.create!(:country_id => 1, :civility => "Mr", :address => "address", :city => 'France', :designation => 'address 1')
    @address_delivery = AddressDelivery.create!(:country_id => 1, :civility => "Mr", :address => "address", :city => 'France', :designation => 'address 1')
    @order = Order.create!(:user => @user, :order_shipping => @order_shipping, :address_delivery => @address_delivery, :address_invoice => @address_invoice)
  end
  describe 'one order' do
    it "should have a user" do
      @order.user.should == @user
    end

    it "should have a order_shipping" do
      @order.order_shipping.should == @order_shipping
    end        
    
    it "should have a address_invoice" do
      @order.address_invoice.should == @address_invoice
    end
    
    it "should have a address_delivery" do
      @order.address_delivery.should == @address_delivery
    end
    
    it "should have a status unpaid" do
      @order.status.should == "unpaid"
    end
    
    it "should find a order with find_by_id" do
      Order.find_by_id(@order.id).should == @order
    end
        
    it "should have order_details" do
      @order_details = []
      product = Product.create!({:url => "product", :name => "product", :sku => "001", :product_type_id => 1})
      (1..5).each do |i|
        order_detail = @order.order_details.create!(:name => "product_#{i}", :price => 20, :sku => i, :product => product)
        @order_details << order_detail
      end
      @order.order_details.all.should == @order_details
    end
      
    it "must have a user" do
      @order = Order.new(:order_shipping => @order_shipping, :address_delivery => @address_delivery, :address_invoice => @address_invoice)
      @order.should_not be_valid
      @order.should have(1).errors_on(:user_id)
    end
    
    it "must have a order_shipping" do
      @order = Order.new(:user => @user, :address_delivery => @address_delivery, :address_invoice => @address_invoice)
      @order.should_not be_valid
      @order.should have(1).errors_on(:order_shipping)
    end
    
    it "must have a address_delivery" do
      @order = Order.new(:user => @user, :order_shipping => @order_shipping, :address_invoice => @address_invoice)
      @order.should_not be_valid
      @order.should have(1).errors_on(:address_delivery)
    end
    
    it "must have a address_invoice" do
      @order = Order.new(:user => @user, :order_shipping => @order_shipping, :address_delivery => @address_delivery)
      @order.should_not be_valid
      @order.should have(1).errors_on(:address_invoice)
    end
  end
  
  describe 'all orders' do
    it "should list all orders" do
      expected_orders = []
      expected_orders << @order      
      3.times do |i|
        expected_orders << Order.create!(:user => @user, :order_shipping => @order_shipping, :address_delivery => @address_delivery, :address_invoice => @address_invoice)
      end
      
      @orders = Order.all
      @orders.length.should == 4
      @orders.should == expected_orders
    end
  end
  
  describe 'new order' do
    before(:each) do
      @order = Order.new(:user => @user, :order_shipping => @order_shipping, :address_delivery => @address_delivery, :address_invoice => @address_invoice)
    end
    
    it "should be valid" do
      @order.valid?.should == true
      @order.user.should == @user
      @order.order_shipping.should == @order_shipping
      @order.address_invoice.should == @address_invoice
      @order.address_delivery.should == @address_delivery      
    end

    it "should save" do
      @order.save
      Order.last.should == @order
    end
  end
  
  describe 'edit/delete attribute' do
  
    it "should update the status to paid" do
      @order.pay!
      @order.status.should == "paid"
    end
    
    it "should update the status to canceled" do
      @order.cancel!
      @order.status.should == "canceled"
    end
    
    it "should update the status to shipped" do
     @order.pay!
     @order.start_shipping!
     @order.status.should == "shipped"
    end
    
    it "should update the status to closed" do
      @order.cancel!
      @order.close!
      @order.status.should == "closed"
    end
    
    #delete
    it 'should destroy the order' do
      @order.destroy
      Order.last.should_not == @order
    end
    
    it "should destroy the order_details" do
      product = Product.create!({:url => "product", :name => "product", :sku => "001", :product_type_id => 1})
      (1..5).each do |i|
        @order.order_details.create!(:name => "product_#{i}", :price => 20, :sku => i, :product => product)
      end
      OrderDetail.all.length.should == 5
      @order.destroy
      OrderDetail.all.length.should == 0
    end
    
    it "should destroy the order_shipping" do
      @order.destroy
      OrderShipping.find_by_id(@order_shipping.id).should == nil
    end
  end
  
end
