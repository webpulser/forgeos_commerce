module ControllerMacros
  def should_load_company(request_method, action)
    describe "a client domain" do
      before(:each) do
        @client = mock_model(Client, :null_object => true)
        Client.stub!(:find_by_id).and_return(@client)
      end
      
      it "should load company" do
        Client.should_receive(:find_by_id).with("1").and_return(@client)
        send request_method, action, {:client_id => "1"}
      end
      
      it "should assign @company" do
        send request_method, action
        assigns[:company].should == @client
      end
    end
    describe "a competitor domain" do
      before(:each) do
        @competitor = mock_model(Competitor, :null_object => true)
        Competitor.stub!(:find_by_id).and_return(@competitor)
      end
      
      it "should load competitor" do
        Competitor.should_receive(:find_by_id).with("1").and_return(@competitor)
        send request_method, action, {:competitor_id => "1"}
      end
      
      it "should assign @company" do
        send request_method, action, {:competitor_id => "1"}
        assigns[:company].should == @competitor
      end
    end
  end

  def should_load_client_and_report(request_method, action)
    before(:each) do
      @client = mock_model(Client, :null_object => true)
      @client_reports = mock_model(Report, :null_object => true)
      Client.stub!(:find_by_id).and_return(@client)
      @client.stub!(:reports).and_return(@client_reports)
      @client_reports.stub!(:find_by_id).and_return(@report)
    end
    
    it "should load client" do
      Client.should_receive(:find_by_id).with("1").and_return(@client)
      send request_method, action, {:client_id => "1", :report_data => {:keyword => {:name => "Forgeos"}}}
    end
    
    it "should load report" do
      @client.should_receive(:reports).and_return(@client_reports)
      @client_reports.should_receive(:find_by_id).with("1").and_return(@report)
      send request_method, action, {:report_id => "1", :report_data => {:keyword => {:name => "Forgeos"}}}
    end
    
    it "should assign @client" do
      send request_method, action, :report_data => {:keyword => {:name => "Forgeos"}}
      assigns[:client].should == @client
    end
    
    it "should assign @report" do
      send request_method, action, :report_data => {:keyword => {:name => "Forgeos"}}
      assigns[:report].should == @report
    end
  end
	
	def should_require_login(request_method, action)
    describe "unauthorized user" do
      it "should redirect to the login page" do
        send request_method, action
        response.should redirect_to(login_path)
      end
  
      it "should not call the #{action} action" do
        controller.should_not_receive(action)
        send request_method, action
      end
    end
  end
end
