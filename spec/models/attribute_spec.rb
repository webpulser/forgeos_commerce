require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Attribute do
  
  describe 'one attribute' do
    before :each do
      @attribute = Attribute.create!({:name => "Color", :access_method => 'color'})
    end
   
    it "should have name Color" do
      @attribute.name.should == 'Color'
    end
    
    it "should have access_method color" do
      @attribute.access_method.should == 'color'
    end
    
    it "should have a unique access_method" do
      @second_attribute = Attribute.new({:name => "Color", :access_method => 'color'})
      @second_attribute.should_not be_valid
      @second_attribute.should have(1).errors_on(:access_method)
    end
    
    it "must have a name" do
      @attribute = Attribute.new({:access_method => 'access'})
      @attribute.should_not be_valid
      @attribute.should have(1).errors_on(:name)
    end
    
    it "must have a access_method" do
      @attribute = Attribute.new({:name => 'color'})
      @attribute.should_not be_valid
      @attribute.should have(1).errors_on(:access_method)
    end
    
    it "should find a attribute with find_by_id" do
      Attribute.find_by_id(@attribute.id).should == @attribute
    end
    
    it "should have attribute_values" do
      @attribute_values = []
      (1..20).each do |i|
        attribute_value = @attribute.attribute_values.create!({:name => "test#{i}"})
        @attribute_values << attribute_value
      end
      @attribute.attribute_values.all.should == @attribute_values
    end
    
    it "should have dynamic_attribute_values" do
      @dynamic_attribute_values = []
      (1..20).each do |i|
        dynamic_attribute_value = @attribute.dynamic_attribute_values.create!({:value => "test#{i}", :product_id => 1})
        @dynamic_attribute_values << dynamic_attribute_value
      end
      @attribute.dynamic_attribute_values.all.should == @dynamic_attribute_values
    end
    
    it "should have attachments" do
      @attachments = []
      (1..20).each do |i|
        attachment = @attribute.attachments.create!
        @attachments << attachment
      end
      @attribute.attachments.all.should == @attachments
    end
    
    it "should have attribute_categories" do
      @attribute_categories = []
      (1..20).each do |i|
        attribute_category = @attribute.attribute_categories.create!({:name => "test#{i}"})
        @attribute_categories << attribute_category
      end
      @attribute.attribute_categories.all.should == @attribute_categories
    end
    
  end
  
  describe 'all attributes' do
    it "should list all attributes" do
      expected_attributes = []
      3.times do |i|
        expected_attributes << Attribute.create!({:name => "attribute_#{i}", :access_method => "attribute_#{i}"})
      end

      @attributes = Attribute.all
      @attributes.length.should == 3
      @attributes.should == expected_attributes
    end
  end
  
  describe 'new attribute' do
    before(:each) do
      @attribute = Attribute.new({:name => "Color", :access_method => 'color'})
    end
    
    it "should be valid" do
      @attribute.valid?.should == true
      @attribute.name.should == "Color"
      @attribute.access_method.should == "color"
    end

    it "should save" do
      @attribute.save
      Attribute.last.should == @attribute
    end
  end
  
  describe 'edit/delete attribute' do
    before :each do
      @attribute = Attribute.create!({:name => "Color", :access_method => 'color'})
    end
    
    # update
    it 'should update attributes' do
      @attribute.update_attributes(:name => "new_color", :access_method => 'new_color').should == true

      @new_attribute = Attribute.find_by_id(@attribute.id)
      @new_attribute.should_not == nil
      @attribute.name.should == 'new_color'
      @attribute.access_method.should == 'new_color'
    end

    # delete
    it 'should destroy the attribute' do
      @attribute.destroy
      Attribute.last.should_not == @attribute
    end

  end
  
  
  
end