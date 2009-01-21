ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../../../config/environment')
require 'logger'
require 'test_help'
require 'stringio'

plugin_path = File.expand_path(File.dirname(__FILE__)+"/../")
config_location = RAILS_ROOT + "/config/database.yml"

log_file = plugin_path + "/test/log/test.log"
FileUtils.touch(log_file) unless File.exist?(log_file)
ActiveRecord::Base.logger = Logger.new(log_file)
config = YAML::load(ERB.new(IO.read(config_location)).result)
ActiveRecord::Base.establish_connection(config['test'])

schema_file = plugin_path + "/test/db/schema.rb"
load(schema_file) if File.exist?(schema_file)

Test::Unit::TestCase.fixture_path = plugin_path + "/test/fixtures/"

$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

# Configuration standart for RailsCommerce's tests
class Test::Unit::TestCase
  self.use_instantiated_fixtures = true

  set_fixture_class :rails_commerce_shipping_method_details => RailsCommerce::ShippingMethodDetail
  set_fixture_class :rails_commerce_products                => RailsCommerce::Product
  set_fixture_class :rails_commerce_categories              => RailsCommerce::Category
  set_fixture_class :rails_commerce_attributes              => RailsCommerce::Attribute
  set_fixture_class :rails_commerce_addresses               => RailsCommerce::Address
  set_fixture_class :rails_commerce_namables                => RailsCommerce::Namable

  fixtures :all #:rails_commerce_carts, :rails_commerce_products, :rails_commerce_currencies, :rails_commerce_currencies_exchanges_rates
end
