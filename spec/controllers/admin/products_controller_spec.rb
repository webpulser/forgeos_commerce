require File.dirname(__FILE__) + '/../../spec_helper'
describe Admin::ProductsController do

  before(:each) do
    login_as_admin
    @products = []
    @product = mock_model(Product, :name => 'Wash Machine', :price => 100)
    Product.stub!(:all).and_return @products
    Product.stub!(:new).and_return @product
    Product.stub!(:find_by_id).and_return @product
    @product.stub!(:destroy).and_return @product
    @product.stub!(:save).and_return false
  end
 
  describe 'index' do

    it "should load all Products" do
      Product.should_receive(:all)
      get :index
    end
    
    it "should assign @products" do
      get :index
      assigns[:products].should == @products
    end
    
    it "should render the index template" do
      get :index
      response.should render_template :index
    end
  end

  describe 'new' do
 
    it "should load the required product" do
      Product.should_receive(:new)
      get :new
    end
    
    it "should assign @product" do
      get :new
      assigns[:product].should == @product
    end
    
    it "should render the new template" do
      get :new
      response.should render_template :new
    end
  end

  describe 'edit' do
  
    it "should load the required product" do
      Product.should_receive(:find_by_id).with('1')
      get :edit, :id => 1
    end
    
    it "should assign @product" do
      get :edit, :id => 1
      assigns[:product].should == @product
    end
    
    it "should render the edit template" do
      get :edit, :id => 1
      response.should render_template :edit
    end

    context "when product does not exist" do
      before(:each) do
        Product.stub!(:find_by_id).and_return nil
      end

      it "should put a message in flash[:error]" do
        get :edit
        flash[:error].should_not == nil
      end
    end
  end
  
  describe 'create' do
  
    it "should build a new product" do
      Product.should_receive(:new).with('name' => 'Wash Machine', 'price' => 100).and_return(@product)
      post :create, :product => {:name => 'Wash Machine', :price => 100}
    end
  
    it "should save the product" do
      @product.should_receive(:save)
      post :create
    end
    
    context "when the product saves successfully" do
      before(:each) do
        @product.stub!(:save).and_return true
      end
      
      it "should set a flash[:notice] message" do
        post :create
        flash[:notice].should_not == nil
      end
      
      it "should redirect to the products index" do
        post :create
        response.should redirect_to(admin_products_path)
      end
    end
    
    context "when the product fails to save" do
      before(:each) do
        @product.stub!(:save).and_return false
      end

      it "should assign @product" do
        post :create
        assigns[:product].should == @product
      end
      
      it "should put a message in flash[:error]" do
        post :create
        flash[:error].should_not == nil
      end
      
      it "should render the new template" do
        post :create
        response.should render_template :new
      end
    end
  end
  
  describe 'update' do
    
    context "when the product saves successfully" do
      before(:each) do
        @product.stub!(:update_attributes).and_return true
      end

      it "should load the required product" do
        Product.should_receive(:find_by_id).with("1").and_return @product
        put :update, :id => 1
      end

      it "should save the product" do
        @product.should_receive(:update_attributes).with('name' => 'Wash Machine', 'price' => 100).and_return(true)
        put :update, :product => {:name => 'Wash Machine', :price => 100}
      end
      
      it "should set a flash[:notice] message" do
        put :update
        flash[:notice].should_not == nil
      end
      
      it "should redirect to the products index" do
        put :update
        response.should redirect_to(admin_products_path)
      end
    end

    context "when the product does not exist" do
      before(:each) do
        Product.stub!(:find_by_id).and_return nil
      end

      it "should put a message in flash[:error]" do
        put :update
        flash[:error].should_not == nil
      end

      it "should redirect to the products index" do
        put :update
        response.should redirect_to(admin_products_path)
      end
    end
    
    context "when the product fails to save" do
      before(:each) do
        @product.stub!(:update_attributes).and_return false
      end
      
      it "should assign @product" do
        put :update
        assigns[:product].should == @product
      end
      
      it "should put a message in flash[:error]" do
        put :update
        flash[:error].should_not == nil
      end
      
      it "should render the edit template" do
        put :update
        response.should render_template :edit
      end
    end
  end

  describe 'destroy' do
  
    context "when product does not exist" do
      before(:each) do
        Product.stub!(:find_by_id).and_return nil
      end

      it "should put a message in flash[:error]" do
        delete :destroy
        flash[:error].should_not == nil
      end

      it "should redirect to the products index" do
        delete :destroy
        response.should redirect_to(admin_products_path)
      end
    end

    
    shared_examples_for 'the product is successfully destroyed' do
      it "should set a flash[:notice] message" do
        delete :destroy, :id => 1
        flash[:notice].should_not == nil
      end
      
      it "should render products list" do
        delete :destroy, :id => 1
        response.should render_template '_list'
      end
    end

    shared_examples_for 'the product fails to destroy' do
      it "should assign @product" do
        delete :destroy, :id => 1
        assigns[:product].should == @product
      end

      it "should put a message in flash[:error]" do
        delete :destroy, :id => 1
        flash[:error].should_not == nil
      end
      
      it "should render products list" do
        delete :destroy, :id => 1
        response.should render_template '_list'
      end
    end

    context "when the product is not marked as deleted" do
      before(:each) do
        @product.stub!(:deleted?).and_return false
      end

      context 'and the product is successfully destroyed' do
        before(:each) do
          @product.stub!(:update_attribute).and_return true
        end
        it "should delete the product" do
          @product.should_receive(:update_attribute).with(:deleted,true).and_return(true)
          delete :destroy
        end
        it_should_behave_like 'the product is successfully destroyed'
      end
      context 'and the product fails to destroy' do
        before(:each) do
          @product.stub!(:update_attribute).and_return false
        end
        
        it_should_behave_like 'the product fails to destroy'
      end
    end

    context "when the product is marked as deleted" do
      before(:each) do
        @product.stub!(:deleted?).and_return true
      end

      context 'and the product is successfully destroyed' do
        before(:each) do
          @product.stub!(:destroy).and_return true
        end
        it "should delete the product" do
          @product.should_receive(:destroy).and_return(true)
          delete :destroy
        end
        it_should_behave_like 'the product is successfully destroyed'
      end
      context 'and the product fails to destroy' do
        before(:each) do
          @product.stub!(:destroy).and_return false
        end
        
        it_should_behave_like 'the product fails to destroy'
      end
    end
  end
end
