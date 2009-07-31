require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Comment do
  
  describe 'one comment' do
    before :each do
      @comment = Comment.create!({:title => "Webpulser", :comment => "my comment"})
    end

    it "should have a title" do
      @comment.title.should == 'Webpulser'
    end
    
    it "should have a comment body" do
      @comment.comment.should == 'my comment'
    end

    it "should find a comment with find_by_id" do
      Comment.find_by_id(@comment.id).should == @comment
    end

    it "should have a user" do
      user = User.create!(:email => "test@webpulser.com", :firstname => "test", :lastname => "test", :password => "password", :password_confirmation => "password")
      @comment.user = user
      @comment.user.should == user
    end
  end
  
  describe 'all comments' do
    it "should list all comments" do
      expected_comments = []
      3.times do |i|
        expected_comments << Comment.create!(:title => "Webpulser", :comment => "my comment")
      end

      @comments = Comment.all
      @comments.length.should == 3
      @comments.should == expected_comments
    end
  end
  
  describe 'new comment' do
    before(:each) do
      @comment = Comment.new :title => "Webpulser", :comment => "my comment"
    end
    
    it "should be valid" do
      @comment.valid?.should == true
      @comment.title.should == "Webpulser"
      @comment.comment.should == "my comment"
    end

    it "should save" do
      @comment.save
      Comment.last.should == @comment
    end
    
    it "must have a title" do
      @comment = Comment.new :comment => "my comment"
      @comment.valid?.should_not == true
    end
    
    it "must have a comment" do
      @comment = Comment.new :title => "Webpulser"
      @comment.valid?.should_not == true
    end
  end

  describe 'edit/delete comment' do
    before :each do
      @comment = Comment.create :title => "Webpulser", :comment => "my comment"
    end
    
    # update
    it 'should update attributes' do
      @comment.update_attributes(:title => 'new_webpulser', :comment => "hello").should == true

      @new_comment = Comment.find_by_id(@comment.id)
      @new_comment.should_not == nil
      @comment.title.should == "new_webpulser"
      @comment.comment.should == "hello"
    end

    # delete
    it 'should destroy the comment' do
      @comment.destroy
      Comment.last.should_not == @comment
    end
  end
end
