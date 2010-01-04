# Installation of ForgeosCommerce plugin by Webpulser©
log 'Welcome to ForgeosCommerce Beta 0.9.0-rc1 install'
log 'To proceed install you need a Forgeos Beta access (if you have not one yet go on http://www.forgeos.com).'

login = ask('enter your Forgeos Beta login :')
password = ask('enter your Forgeos Beta password :')

inside('vendor/plugins') do
  run "svn co https://src.forgeos.com/forgeos_core/tags/0.9.0-rc1 --username #{login} --password #{password} forgeos_core"
  run "svn co https://src.forgeos.com/forgeos_cms/tags/0.9.0-rc1 --username #{login} --password #{password} forgeos_cms"
  run "svn co https://src.forgeos.com/forgeos_commerce/tags/0.9.0-rc1 --username #{login} --password #{password} forgeos_commerce"
end

plugin 'attachment_fu', :git => 'git://github.com/technoweenie/attachment_fu.git'
plugin 'localized_dates', :git => 'git://github.com/clemens/localized_dates.git'
plugin 'open_flash_chart', :git => 'git://github.com/pullmonkey/open_flash_chart.git'

file 'db/migrate/001_install_forgeos_core.rb', <<-END
class InstallForgeosCore < ActiveRecord::Migration
  def self.up
    migrate_plugin :forgeos_core, 20091106163507
  end
                            
  def self.down
    migrate_plugin :forgeos_core, 0
  end
end
END

file 'db/migrate/002_install_forgeos_cms.rb', <<-END
class InstallForgeosCms < ActiveRecord::Migration
  def self.up
    migrate_plugin :forgeos_cms, 20091009134736
  end
                            
  def self.down
    migrate_plugin :forgeos_cms, 0
  end
end                         
END

file 'db/migrate/003_install_forgeos_commerce.rb', <<-END
class InstallForgeosCommerce < ActiveRecord::Migration
  def self.up
    migrate_plugin :forgeos_commerce, 20091009134947
  end
                            
  def self.down
    migrate_plugin :forgeos_commerce, 0
  end
end
END


environment "config.plugins = [ :forgeos_core, :forgeos_cms, :all ]"
gem 'acts-as-taggable-on', :source => 'http://gemcutter.org'
gem 'desert' 
append_file 'Rakefile', "require 'desert'"

route 'map.routes_from_plugin(:forgeos_cms)'
route 'map.routes_from_plugin(:forgeos_core)'
route 'map.routes_from_plugin(:forgeos_commerce)'
route "map.root :controller => 'url_catcher', :action => 'page', :url => 'home'"

rake 'db:create'
rake 'gems:install'
rake 'forgeos:commerce:install'

run 'rm -rf config/locales/* public/index.html'
run 'cp vendor/plugins/forgeos_core/config/attachments.example.yml config/attachments.yml'
log 'Now you can happily run ./script/server and got with you favorite browser to http://localhost:3000/'
