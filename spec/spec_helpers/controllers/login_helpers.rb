module LoginHelpers
  def login_as_admin
    controller.stub(:current_user).and_return mock_model(Administrator, :null_object => true)
  end
  
  def login_as_user(user=nil)
    unless user
      user = mock_model(User, :null_object => true)
    end
    controller.stub(:current_user).and_return(user)
  end
end
