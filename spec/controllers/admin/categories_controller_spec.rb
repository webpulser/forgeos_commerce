require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::CategoriesController, "GET index" do
  should_require_admin_login :get, :index

  describe "admin client" do
  
    before(:each) do
      login_as_admin
      @categories = []
      Category.stub!(:find_all_by_parent_id).and_return @categories
    end

    it "should load all categories" do
      Category.should_receive(:find_all_by_parent_id).with(nil)
      get :index, :type => 'category'
    end
    
    it "should assign @categories" do
      get :index, :type => 'category', :format => 'json'
      assigns[:categories].should == @categories
    end
    
    it "should render the index template" do
      get :index, :type => 'category', :format => 'json'
      response.should have_text('[]')
    end

    it "should redirect_to admin/ if no type given" do
      get :index, :format => 'json'
      response.should redirect_to(root_path)
    end

    it "should redirect_to admin/ format is not json" do
      get :index, :type => 'category'
      response.should redirect_to(root_path)
    end

  end
end

describe Admin::CategoriesController, "GET new" do
  should_require_admin_login :get, :new

  describe "admin client" do
  
    before(:each) do
      login_as_admin
      @category = mock_model(Category, :null_object => true)
      Category.stub!(:new).and_return @category
    end

    it "should load the required category" do
      Category.should_receive(:new)
      get :new
    end
    
    it "should assign @category" do
      get :new
      assigns[:category].should == @category
    end
    
    it "should render the new template" do
      get :new
      response.should render_template("new")
    end
  end
end

describe Admin::CategoriesController, "GET edit" do
  should_require_admin_login :get, :edit

  describe "admin client" do
  
    before(:each) do
      login_as_admin
      @category = mock_model(Category, :null_object => true)
      Category.stub!(:find_by_id).and_return @category
    end

    it "should load the required category" do
      Category.should_receive(:find_by_id).with("1")
      get :edit, :id => 1
    end
    
    it "should assign @category" do
      get :edit
      assigns[:category].should == @category
    end
    
    it "should render the edit template" do
      get :edit
      response.should render_template("edit")
    end

    context "when category does not exist" do
      before(:each) do
        Category.stub!(:find_by_id).and_return nil
      end

      it "should put a message in flash[:error]" do
        get :edit
        flash[:error].should_not == nil
      end
    end
  end
end

describe Admin::CategoriesController, "POST create" do
  should_require_admin_login :post, :create
  
  describe "admin client" do
  
    before(:each) do
      login_as_admin
      @category = mock_model(Category, :null_object => true)
      Category.stub!(:new).and_return @category
    end

    it "should build a new category" do
      Category.should_receive(:new).with('name' => "webpulser").and_return(@category)
      post :create, :category => {'name' => "webpulser"}
    end
  
    it "should save the category" do
      @category.should_receive(:save)
      post :create
    end
    
    context "when the category saves successfully" do
      before(:each) do
        @category.stub!(:save).and_return true
      end
      
      it "should set a flash[:notice] message" do
        post :create
        flash[:notice].should_not == nil
      end
      
      it "should redirect to the category edit path" do
        post :create
        response.should redirect_to(edit_admin_category_path(@category))
      end
    end
    
    context "when the category fails to save" do
      before(:each) do
        @category.stub!(:save).and_return false
      end

      it "should assign @category" do
        post :create
        assigns[:category].should == @category
      end
      
      it "should put a message in flash[:error]" do
        post :create
        flash[:error].should_not == nil
      end
      
      it "should render the new template" do
        post :create
        response.should render_template("new")
      end
    end
  end
end

describe Admin::CategoriesController, "PUT update" do
  should_require_admin_login :put, :update
  
  describe "admin client" do
    before(:each) do
      login_as_admin
      @category = mock_model(Category, :save => nil, :null_object => true)
      Category.stub!(:find_by_id).and_return @category
    end
    
    context "when the category saves successfully" do
      before(:each) do
        @category.stub!(:update_attributes).and_return true
      end

      it "should load the required category" do
        Category.should_receive(:find_by_id).with("1").and_return @category
        put :update, :id => 1
      end

      it "should save the category" do
        @category.should_receive(:update_attributes).with('url' => 'www.forgeos.com', 'client_id' => '1').and_return(true)
        put :update, :category => { :url => 'www.forgeos.com', :client_id => '1' }
      end
      
      it "should set a flash[:notice] message" do
        put :update
        flash[:notice].should_not == nil
      end
      
      it "should redirect to the category edit path" do
        put :update
        response.should render_template(:edit)
      end
    end

    context "when the category does not exist" do
      before(:each) do
        Category.stub!(:find_by_id).and_return nil
      end

      it "should put a message in flash[:error]" do
        put :update
        flash[:error].should_not == nil
      end

      it "should redirect to the categories index" do
        put :update
        response.should redirect_to(admin_categories_path)
      end
    end
    
    context "when the category fails to save" do
      before(:each) do
        @category.stub!(:update_attributes).and_return false
      end
      
      it "should assign @category" do
        put :update
        assigns[:category].should == @category
      end

      it "should put a message in flash[:error]" do
        put :update
        flash[:error].should_not == nil
      end
      
      it "should render the edit template" do
        put :update
        response.should render_template("edit")
      end
    end
  end
end

describe Admin::CategoriesController, "DELETE destroy" do
  should_require_admin_login :delete, :destroy

  describe "admin client" do
  
    before(:each) do
      login_as_admin
      @category = mock_model(Category, :save => nil, :null_object => true)
      Category.stub!(:find_by_id).and_return @category
    end
    
    context "when the category is successfully deleted" do
      before(:each) do
        @category.stub!(:destroy).and_return true
      end

      it "should load the required category" do
        Category.should_receive(:find_by_id).with("1")
        delete :destroy, :id => 1
      end

      it "should delete the category" do
        @category.should_receive(:destroy)
        delete :destroy
      end
      
      it "should set a flash[:notice] message" do
        delete :destroy
        flash[:notice].should_not == nil
      end
      
#      it "should render the edit template" do
#        delete :destroy
#        response.should render_template 'edit'
#      end
    end

    context "when category does not exist" do
      before(:each) do
        Category.stub!(:find_by_id).and_return nil
      end

      it "should put a message in flash[:error]" do
        delete :destroy
        flash[:error].should_not == nil
      end

#      it "should render the edit template" do
#        delete :destroy
#        response.should render_template 'edit'
#      end
    end
    
    context "when the category fails to delete" do
      before(:each) do
        @category.stub!(:destroy).and_return false
      end
      
      it "should assign @category" do
        delete :destroy
        assigns[:category].should == @category
      end

      it "should put a message in flash[:error]" do
        delete :destroy
        flash[:error].should_not == nil
      end
      
#      it "should render the edit template" do
#        delete :destroy
#        response.should render_template 'edit'
#      end
    end
  end
end
