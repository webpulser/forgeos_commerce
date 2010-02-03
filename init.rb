I18n.load_path += Dir[File.join(RAILS_ROOT, 'vendor', 'plugins', 'forgeos_commerce', 'config', 'locales', '**', '*.{rb,yml}')]
config.gem 'aasm', :source => 'http://gems.github.com', :version => '2.1.5'

if RAILS_ENV == 'development'
  ActiveSupport::Dependencies.load_once_paths.reject!{|x| x =~ /^#{Regexp.escape(File.dirname(__FILE__))}/}
end

require 'forgeos/commerce'
