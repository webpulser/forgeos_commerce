require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Admin::UsersController, "Get Index" do
  should_require_admin_login :get, :index
  
  describe "Admin" do
    
    before(:each) do
      login_as_admin
      @users = mock_model(User, :null_object => true)
      User.stub!(:all).and_return @users
    end
    
    it "should get all users" do
      User.should_receive(:all)
      get :index
    end
    
    it "should assign @users" do
      get :index
      assigns[:users].should == @users
    end 
    
    it "should render the index template" do
      get :index
      response.should render_template("index")
    end
    
  end
end

describe Admin::UsersController, "GET show" do
  should_require_admin_login :get, :show
  
  describe "Admin" do
    
    before(:each) do
      login_as_admin
      @user = mock_model(User, :null_object => true)
      User.stub!(:find_by_id).and_return @user
    end
    
    it "should load the required user" do
      User.should_receive(:find_by_id).with("1")
      get :show, :id => 1
    end
    
    it "should assign @user" do
      get :show
      assigns[:user].should == @user
    end
    
    it "should render the show template" do
      get :show
      response.should render_template("show")
    end
    
  end
  
end

describe Admin::UsersController, "Get new" do
  should_require_admin_login :get, :new
  
  describe "Admin" do
    
    before(:each) do
      login_as_admin
      @user = mock_model(User, :null_object => true)
      User.stub!(:new).and_return @user
    end
    
    it "should load a new user" do
      User.should_receive(:new)
      get :new
    end
    
    it "should assign @user" do
      get :new
      assigns[:user].should == @user
    end
    
    it "should render the create template" do 
      get :new
      response.should render_template("create")
    end
    
  end
  
end

describe Admin::UsersController, "Post Create" do
  should_require_admin_login :post, :create
  
  describe "Admin" do
    
    before(:each) do
      login_as_admin
      @user = mock_model(User, :save => nil)
      @address_delivery = mock_model(AddressDelivery, :null_object => true)
      @address_invoice = mock_model(AddressInvoice, :null_object => true)
      User.stub!(:build_address_invoice).and_return @address_invoice
      User.stub!(:build_address_delivery).and_return @address_delivery
      User.stub!(:new).and_return @user
    end
    
    it "should build a new user" do
      User.should_receive(:build_address_invoice)
      User.should_receive(:new).and_return @user
      post :create
    end
    
    it "should save the user" do
      @user.should_receive(:save)
      post :create
    end
        
  end
end

describe Admin::UsersController, "DELETE destroy" do
  should_require_admin_login :delete, :destroy
  
  describe "admin" do  
    
    before(:each) do
      login_as_admin
      @user = mock_model(User, :null_object => true)
      User.stub!(:find_by_id).and_return @user
    end
    
    context "when the user is successfully deleted" do
      before(:each) do
        User.stub!(:destroy).and_return true
      end
    
      it "should load the required user" do
        User.should_receive(:find_by_id).with("1")
        delete :destroy, :id => 1
      end
    
      it "should delete the user" do
        @user.should_receive(:destroy)
        delete :destroy
      end
      
      it "should set a flash[:notice] message" do
        delete :destroy
        flash[:notice].should == "The user was successfully destroyed"
      end
      
      it "should render the template admin/users/_list" do
        delete :destroy
        response.should render_template("admin/users/_list")
      end
    end
    
    context "when the user does not exist" do
      before(:each) do
        User.stub!(:find_by_id).and_return nil
      end
      
      it "should put a message in flash[:error]" do
        delete :destroy
        flash[:error].should == "User does not exist"
      end
      
      it "should render the template admin/users/_list" do
        delete :destroy
        response.should render_template("admin/users/_list")
      end  
    end
  
    context "when the user fails to delete" do
      before(:each) do
        User.stub!(:destroy).and_return false
      end
      
      it "should put a message in flash[:error]" do
        delete :destroy
        flash[:error].should == "A problem occured during the user destroy"
      end 
      
      it "should render the template admin/users/_list" do
        delete :destroy
        response.should render_template("admin/users/_list")
      end
    end
  end  
end

describe Admin::UsersController, "GET activate" do
  should_require_admin_login :get, :activate
  
  describe "admin" do  
    
    before(:each) do
      login_as_admin
      @user = mock_model(User, :null_object => true)
      User.stub!(:find_by_id).and_return @user
    end
    
    context "when the user is activated and he is successfully disactivate" do
      before(:each) do
        request.env["HTTP_REFERER"] = '/index'
        User.stub!(:activate).and_return true
        User.stub!(:active?).and_return true
        #User.stub!(:disactivate).and_return true
      end
      
      it "should load the required user" do
        User.should_receive(:find_by_id).with("1")
        get :activate, :id => 1
      end
    
      it "should disactivate the user" do
        @user.should_receive(:active?)
        @user.should_receive(:activate)
        get :activate
      end
      
      it "should set a flash[:notice] message" do
        get :activate
        flash[:notice].should == "The user was successfully disactivated"
      end
      
      it "should redirect to the previous page" do
        get :activate
        response.should redirect_to('index')
      end
    end
    
    context "when the user is disactivated and he is successfully activate" do
      before(:each) do
        request.env["HTTP_REFERER"] = '/index'
        User.stub!(:activate).and_return true
        User.stub!(:active?).and_return false
      end
      
      it "should load the required user" do
        User.should_receive(:find_by_id).with("1")
        get :activate, :id => 1
      end
      
      it "should activate the user" do
        @user.should_receive(:active?)
        get :activate
      end
      
      it "should set a flash[:notice] message" do
        @user.should_receive(:active?)
        @user.should_receive(:activate)
        get :activate
        flash[:notice].should == "The user was successfully activated"
      end
      
      it "should redirect to the previous page" do
        get :activate
        response.should redirect_to('index')
      end
    end
    
    context "when the user is disactivated and the activation fails" do
      before(:each) do
        request.env["HTTP_REFERER"] = '/index'
        User.stub!(:activate).and_return false
        User.stub!(:active?).and_return false
      end
      
      it "should load the required user" do
        User.should_receive(:find_by_id).with("1")
        get :activate, :id => 1
      end
      
      it "should activate the user" do
        @user.should_receive(:active?)
        get :activate
      end
      
      it "should set a flash[:error] message" do
        @user.should_receive(:active?)
        @user.should_receive(:activate)
        get :activate
        flash[:error].should == "A problem occured during the user activation"
      end
      
    end
    
  end
end