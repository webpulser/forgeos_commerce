require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Category do
  describe 'one category' do
    before :each do 
      @category = Category.create!({:name => 'category'})
    end

    it "should have name category" do
      @category.name.should == 'category'
    end

    it "should find a category with find_by_id" do
      Category.find_by_id(@category.id).should == @category
    end

    it "should have products" do
      @products = []
      product_type = ProductType.create!({:name => "type"})
      (1..20).each do |i|
        product = product_type.products.create!({:url => "url_#{i}", :name => "test"})
        @category.products << product
        @products << product
      end
      @category.products.all.should == @products
    end
    
  end
  
  describe 'all categories' do
    it "should list all categories" do
      expected_categories = []
      3.times do |i|
        expected_categories << Category.create!(:name => "category ")
      end

      @categories = Category.all
      @categories.length.should == 3
      @categories.should == expected_categories
    end
  end
  
  describe 'new category' do
    before(:each) do
      @category = Category.new :name => "Webpulser"
    end
    
    it "should be valid" do
      @category.valid?.should == true
      @category.name.should == "Webpulser"
    end

    it "should save" do
      @category.save
      Category.last.should == @category
    end
    
    it "must have a name" do
      @category = Category.new
      @category.valid?.should_not == true
    end
  end

  describe 'edit/delete category' do
    before :each do
      @category = Category.create :name => "Webpulser"
    end
    
    # update
    it 'should update attributes' do
      @category.update_attributes(:name => 'new_webpulser').should == true

      @new_category = Category.find_by_id(@category.id)
      @new_category.should_not == nil
      @new_category.name.should == 'new_webpulser'
    end

    it 'should not update attributes if name is missing' do
      @category.update_attributes(:name => '').should_not == true

      @new_category = Category.find_by_id(@category.id)
      @new_category.should_not == nil
      @new_category.name.should == 'Webpulser'
    end

    # delete
    it 'should destroy the category' do
      @category.destroy
      Category.last.should_not == @category
    end
  end
end
