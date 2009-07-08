$currency = Currency.find_by_name('euro') if Currency.table_exists?

locale_path = File.join(directory, 'config/locales')
if File.exists?(locale_path)
  locale_files = Dir[File.join(locale_path, '*.{rb,yml}')]
  unless locale_files.blank?
    first_app_element = 
      I18n.load_path.select{ |e| e =~ /^#{ RAILS_ROOT }/ }.reject{ |e| e =~ /^#{ RAILS_ROOT }\/vendor\/plugins/ }.first
    app_index = I18n.load_path.index(first_app_element) || - 1
    I18n.load_path.insert(app_index, *locale_files)
  end
end
config.gem 'mime-types', :lib => 'mime/types'
config.gem "mbleigh-acts-as-taggable-on", :source => "http://gems.github.com", :lib => "acts-as-taggable-on"
config.gem "acts_as_ferret", :lib => "acts_as_ferret"
config.gem "rubyist-aasm", :source => "http://gems.github.com", :lib => 'aasm'
config.gem 'mislav-will_paginate', :source => "http://gems.github.com", :lib => "will_paginate"
config.gem 'coupa-acts_as_list', :source => "http://gems.github.com"
config.gem 'coupa-acts_as_tree', :source => "http://gems.github.com"
config.gem 'jimiray-acts_as_commentable', :source => "http://gems.github.com", :lib => 'acts_as_commentable'
config.gem 'haml'
# Load Haml and Sass
require 'haml'
Haml.init_rails(binding)
