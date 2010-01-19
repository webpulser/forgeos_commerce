I18n.load_path += Dir[File.join(RAILS_ROOT, 'vendor', 'plugins', 'forgeos_commerce', 'config', 'locales', '**', '*.{rb,yml}')]
config.gem 'aasm', :source => 'http://gems.github.com', :version => '2.1.3'

require 'forgeos/commerce'
