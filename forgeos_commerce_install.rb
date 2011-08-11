git :init

gem 'rmagick'
gem 'globalize3', '>= 0.1.0'
gem 'acts-as-taggable-on', '>= 2.0.6'
gem 'acts_as_list', '>= 0.1.3'
gem 'acts_as_tree', '>= 0.1.1'
gem 'bcrypt-ruby', '>= 2.1.4'
gem 'fastercsv', '>= 1.5.4'
gem 'haml', '>= 3.1.2'
gem 'sass', '>= 3.1.4'
gem 'mime-types', '>= 1.16'
gem 'thinking-sphinx', '>= 2.0.5'
gem 'webpulser-habtm_list', '>= 0.1.2'
gem 'will_paginate', '~> 3.0.pre4'
gem 'authlogic', '>= 3.0.3'
gem 'forgeos_core', '>= 1.9.4'
gem 'acts_as_commentable', '>= 3.0.1'
gem 'forgeos_cms', '>= 1.9.4'
gem 'aasm', '>= 2.2.0'
gem 'ruleby', '>= 0.6'
gem 'forgeos_commerce', '>= 1.9.0'

say_status :warning, "If you get some errors from bundle (like missing gems) :", :red
say_status :warning, "  * run bundle install", :red
say_status :warning, "  * then rerun this template", :red

plugin 'attachment_fu', :git => 'git://github.com/technoweenie/attachment_fu.git'
gsub_file 'vendor/plugins/attachment_fu/lib/technoweenie/attachment_fu.rb', 'RAILS_ROOT', 'Rails.root'

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
