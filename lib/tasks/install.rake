namespace :forgeos do
  namespace :commerce do
    task :sync => ['forgeos:cms:sync'] do
      system "rsync -r#{'v' unless Rails.env == 'production'}C #{File.join(Rails.plugins['forgeos_commerce'].directory,'public')} ."
    end

    task :initialize => ['forgeos:cms:initialize'] do
      system 'rake "forgeos:core:fixtures:load[forgeos_commerce,currencies_exchanges_rates currencies pages page_translations people product_types product_type_translations]"'
      system "rake 'forgeos:core:generate:acl[#{Rails.plugins['forgeos_commerce'].directory}]'"
    end

    task :install => ['forgeos:cms:install', :initialize, :sync]
  end
end
