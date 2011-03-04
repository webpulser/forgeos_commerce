git :init
plugin 'engines', :git => 'git://github.com/lazyatom/engines.git'
append_file 'config/boot.rb', "require Rails.root.join('vendor','plugins','engines','boot')"

plugin 'attachment_fu', :git => 'git://github.com/technoweenie/attachment_fu.git'
plugin 'localized_dates', :git => 'git://github.com/clemens/localized_dates.git'
plugin 'open_flash_chart', :git => 'git://github.com/pullmonkey/open_flash_chart.git'
plugin 'forgeos_core', :git => '-b engines src.forgeos.com:forgeos/core', :submodule => true
plugin 'forgeos_cms', :git => '-b engines src.forgeos.com:forgeos/cms', :submodule => true
plugin 'forgeos_commerce', :git => '-b engines src.forgeos.com:forgeos/commerce', :submodule => true

environment "config.plugins = [:attachment_fu, :forgeos_core, :all]"
gem 'acts-as-taggable-on', :source => 'http://rubygems.org'
run 'cp vendor/plugins/forgeos_core/config/attachments.example.yml config/attachments.yml'

route "map.page '/*url', :controller => 'url_catcher', :action => 'page'"
route "map.connect ':controller/:action/:id.:format'"
route "map.connect ':controller/:action/:id'"

rake 'db:create'
run './script/generate plugin_migration'
rake 'db:migrate'
rake 'forgeos:commerce:install'

run 'rm -rf config/locales/* public/*.html'
