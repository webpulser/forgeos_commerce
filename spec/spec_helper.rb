ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'spec'
require 'spec/rails'

Dir[File.dirname(__FILE__) + "/views/shared_examples/**/*_spec.rb"].each {|file| require(file)}
Dir[File.dirname(__FILE__) + "/spec_helpers/**/*.rb"].each {|file| require(file) }

Spec::Runner.configure do |config|
  config.fixture_path = "#{File.dirname(__FILE__)}/../spec/fixtures"
  
  config.include ControllerHelpers::Uploader, :type => :controller
  config.include LoginHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller
end
