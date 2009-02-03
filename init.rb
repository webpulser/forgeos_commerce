require 'will_paginate'
require 'acts_as_state_machine'
require_plugin 'acts_as_tree'
require_plugin 'restful_authentication'
require_plugin 'sortable_pictures'
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
