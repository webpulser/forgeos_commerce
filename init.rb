I18n.load_path += Dir[Rails.root.join('vendor', 'plugins', 'rails_commerce', 'config', 'locales', '*.{rb,yml}')]
config.gem "rubyist-aasm", :source => "http://gems.github.com", :lib => 'aasm'

require 'rails_commerce'
