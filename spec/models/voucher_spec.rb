require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Voucher do
  before :each do
    @date = Date.today
  end
  
  describe 'one voucher' do
    before :each do 
      @date = Date.today
      @voucher = Voucher.create!({:name => "Webpulser", :code => "1234", :value => "42", :total_min => "10", :date_start => @date, :date_end => (@date + 1)})
    end

    it "should have name voucher" do
      @voucher.name.should == 'Webpulser'
    end

    it "should find a voucher with find_by_id" do
      Voucher.find_by_id(@voucher.id).should == @voucher
    end

    it "should have a product type" do
      product_type = ProductType.create!({:name => "type"})
      @voucher.product_type = product_type
      @voucher.product_type.should == product_type
    end
    
    it "must not be valid for a total smaller than total min" do
      @voucher.is_valid?(5).should_not == true
    end
    
    it "must be valid for a total greater than total min" do
      @voucher.is_valid?(15).should_not == true
    end
  end
  
  describe 'all vouchers' do
    it "should list all vouchers" do
      expected_vouchers = []
      3.times do |i|
        expected_vouchers << Voucher.create!(:name => "Webpulser", :code => "1234", :value => "42", :total_min => "10", :date_start => @date, :date_end => (@date + 1))
      end

      @vouchers = Voucher.all
      @vouchers.length.should == 3
      @vouchers.should == expected_vouchers
    end
  end
  
  describe 'new voucher' do
    before(:each) do
      @date = Date.today
      @voucher = Voucher.new :name => "Webpulser", :code => "1234", :value => "42", :total_min => "10", :date_start => @date, :date_end => (@date + 1)
    end
    
    it "should be valid" do
      @voucher.valid?.should == true
      @voucher.name.should == "Webpulser"
      @voucher.code.should == "1234"
      @voucher.value.should == 42
      @voucher.total_min.should == 10
      @voucher.date_start.should == @date
      @voucher.date_end.should == @date + 1
    end

    it "should save" do
      @voucher.save
      Voucher.last.should == @voucher
    end
    
    it "must have a name" do
      @voucher = Voucher.new :code => "1234", :value => "42", :total_min => "10", :date_start => @date, :date_end => (@date + 1)
      @voucher.valid?.should_not == true
    end
    
    it "must have a code" do
      @voucher = Voucher.new :name => "Webpulser", :value => "42", :total_min => "10", :date_start => @date, :date_end => (@date + 1)
      @voucher.valid?.should_not == true
    end
    
    it "must have a value" do
      @voucher = Voucher.new :name => "Webpulser", :code => "1234", :total_min => "10", :date_start => @date, :date_end => (@date + 1)
      @voucher.valid?.should_not == true
    end
    
    it "must have a total min" do
      @voucher = Voucher.new :name => "Webpulser", :code => "1234", :value => "42", :date_start => @date, :date_end => (@date + 1)
      @voucher.valid?.should_not == true
    end
    
    it "must have a date start" do
      @voucher = Voucher.new :name => "Webpulser", :code => "1234", :value => "42", :total_min => "10", :date_end => (@date + 1)
      @voucher.valid?.should_not == true
    end
    
    it "must have a date end" do
      @voucher = Voucher.new :name => "Webpulser", :code => "1234", :value => "42", :total_min => "10", :date_start => @date
      @voucher.valid?.should_not == true
    end
    
    it "must have a valid date start and date end" do
      @voucher = Voucher.new :name => "Webpulser", :code => "1234", :value => "42", :total_min => "10", :date_start => @date, :date_end => (@date - 1)
      @voucher.is_valid?.should_not == true
    end
  end

  describe 'edit/delete voucher' do
    before :each do
      @date = Date.today + 1
      @voucher = Voucher.create :name => "Webpulser"
    end
    
    # update
    it 'should update attributes' do
      @voucher.update_attributes(:name => 'new_webpulser', :code => "5678", :value => "90", :total_min => "4", :date_start => @date, :date_end => (@date + 1)).should == true

      @new_voucher = Voucher.find_by_id(@voucher.id)
      @new_voucher.should_not == nil
      @voucher.name.should == "new_webpulser"
      @voucher.code.should == "5678"
      @voucher.value.should == 90
      @voucher.total_min.should == 4
      @voucher.date_start.should == @date
      @voucher.date_end.should == @date + 1
    end

    # delete
    it 'should destroy the voucher' do
      @voucher.destroy
      Voucher.last.should_not == @voucher
    end
  end
end
