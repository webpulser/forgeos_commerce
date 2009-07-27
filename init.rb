
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
config.gem "acts_as_ferret", :lib => "acts_as_ferret"
config.gem "rubyist-aasm", :source => "http://gems.github.com", :lib => 'aasm'

require 'rails_commerce'
