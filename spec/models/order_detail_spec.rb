require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrderDetail do
  before :each do
    @address_invoice = AddressInvoice.create!(:country_id => 1, :civility => "Mr", :address => "address", :city => 'France', :designation => 'address 1')
    @address_delivery = AddressDelivery.create!(:country_id => 1, :civility => "Mr", :address => "address", :city => 'France', :designation => 'address 1')
    @order = Order.create!(:user_id => 1, :order_shipping => OrderShipping.create!, :address_invoice => @address_invoice, :address_delivery => @address_delivery)
    @product = Product.create!(:url => "product", :name => "product", :sku => "001", :product_type_id => 1)
    @order_detail = OrderDetail.create!(:order => @order, :product => @product, :name => 'order_detail_name', :price => 10, :sku => '001')
  end

  describe 'one order_detail' do
    it "should have a order" do
      @order_detail.order.should == @order
    end
    
    it "should have a product" do
      @order_detail.product.should == @product
    end
    
    it "should find a order_detail with find_by_id" do
      OrderDetail.find_by_id(@order_detail.id).should == @order_detail
    end
    
    it "must have a name" do
      @order_detail = OrderDetail.new(:order => @order, :product => @product, :price => 10, :sku => '001')
      @order_detail.should_not be_valid
      @order_detail.should have(1).errors_on(:name)
    end
    
    it "must have a price" do
      @order_detail = OrderDetail.new(:order => @order, :product => @product, :name => "order_detail_name", :sku => '001')
      @order_detail.should_not be_valid
      @order_detail.should have(1).errors_on(:price)
    end
    
    it "must have a sku" do
      @order_detail = OrderDetail.new(:order => @order, :product => @product, :name => "order_detail_name", :price => 10)
      @order_detail.should_not be_valid
      @order_detail.should have(1).errors_on(:sku)
    end
  end

  describe 'all order details' do
    it "should list all order details" do
      expected_order_details = []
      expected_order_details << @order_detail     
      3.times do |i|
        expected_order_details << OrderDetail.create!(:order => @order, :product => @product, :name => 'order_detail_name', :price => 10, :sku => '001')
      end
      
      @order_details = OrderDetail.all
      @order_details.length.should == 4
      @order_details.should == expected_order_details
    end
  end

  describe 'new order detail' do
    before(:each) do
      @order_detail = OrderDetail.new(:order => @order, :product => @product, :name => 'order_detail_name', :price => 10, :sku => '001')
    end
    
    it "should be valid" do
      @order_detail.valid?.should == true
      @order_detail.order.should == @order
      @order_detail.product.should == @product
    end

    it "should save" do
      @order_detail.save
      OrderDetail.last.should == @order_detail
    end
  end
  

end
