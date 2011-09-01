git :init

gem 'rmagick'
gem 'forgeos_commerce', '>= 1.9.0'

say_status :warning, "If you get some errors from bundle (like missing gems) :", :red
say_status :warning, "  * run bundle install", :red
say_status :warning, "  * then rerun this template", :red

plugin 'attachment_fu', :git => 'git://github.com/technoweenie/attachment_fu.git'
plugin 'open_flash_chart', :git => 'git://github.com/pullmonkey/open_flash_chart.git'

route "mount Forgeos::Cms::Engine => '/', :as => 'forgeos_cms'"
route "mount Forgeos::Commerce::Engine => '/', :as => 'forgeos_commerce'"
route "mount Forgeos::Core::Engine => '/', :as => 'forgeos_core'"

rake 'db:create'
rake 'forgeos_core_engine:install:migrations'
rake 'forgeos_cms_engine:install:migrations'
rake 'forgeos_commerce_engine:install:migrations'
rake 'db:migrate'
rake 'forgeos:core:install'
rake 'forgeos:cms:install'
rake 'forgeos:commerce:install'

run 'rm -rf config/locales/* public/*.html'

say_status :warning, "If you get some errors from bundle (like missing gems) :", :red
say_status :warning, "  * run bundle install", :red
say_status :warning, "  * then rerun this template", :red
