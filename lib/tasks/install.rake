namespace :forgeos do
  namespace :commerce do
    task :sync => ['forgeos:cms:sync'] do
      system "rsync -rvC #{File.join('vendor','plugins','forgeos_commerce','public')} ."
    end

    task :initialize => ['forgeos:cms:initialize'] do
      system 'rake forgeos:core:fixtures:load[forgeos_commerce,currencies_exchanges_rates currencies pages people product_types]'
      system "rake forgeos:core:generate:acl[#{File.join('vendor','plugins','forgeos_commerce')}]"
    end

    task :install => ['forgeos:cms:install', :initialize, :sync]
  end
end
