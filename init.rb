I18n.load_path += Dir[File.join(RAILS_ROOT, 'vendor', 'plugins', 'forgeos_commerce', 'config', 'locales', '**', '*.{rb,yml}')]
config.gem "rubyist-aasm", :source => "http://gems.github.com", :lib => 'aasm'

require 'forgeos/commerce'
