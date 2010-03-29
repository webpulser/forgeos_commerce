# Installation of ForgeosCommerce plugin by Webpulser©
log 'Welcome to ForgeosCommerce Beta 0.9.0 install'

plugin 'attachment_fu', :git => 'git://github.com/technoweenie/attachment_fu.git'
plugin 'localized_dates', :git => 'git://github.com/clemens/localized_dates.git'
plugin 'open_flash_chart', :git => 'git://github.com/pullmonkey/open_flash_chart.git'


plugin 'forgeos_core', :git => 'git://github.com/webpulser/forgeos_core.git'
plugin 'forgeos_cms', :git => 'git://github.com/webpulser/forgeos_cms.git'
plugin 'forgeos_commerce', :git => 'git://github.com/webpulser/forgeos_commerce.git'

environment "config.plugins = [ :forgeos_core, :all ]"
gem 'acts-as-taggable-on', :source => 'http://gemcutter.org'
append_file 'config/boot.rb', "require File.join(File.dirname(__FILE__), '..','vendor','plugins','engines','boot')"
run 'cp vendor/plugins/forgeos_core/config/attachments.example.yml config/attachments.yml'

route "map.connect ':controller/:action/:id'"
route "map.connect ':controller/:action/:id.:format'"
route "map.page '*url', :controller => 'url_catcher', :action => 'page'"

rake 'db:create'
rake 'gems:install', :sudo => true
rake 'forgeos:commerce:install'

run 'rm -rf config/locales/* public/index.html'
log 'Now you can happily run ./script/server and got with you favorite browser to http://localhost:3000/'
