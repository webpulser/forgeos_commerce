I18n.load_path += Dir[File.join(RAILS_ROOT, 'vendor', 'plugins', 'forgeos_commerce', 'config', 'locales', '**', '*.{rb,yml}')]
config.gem 'aasm', :version => '>=2.1.5'

require 'forgeos/commerce'
puts 'Forgeos Commerce loaded'
