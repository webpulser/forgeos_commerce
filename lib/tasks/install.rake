namespace :forgeos do
  namespace :commerce do
    task :sync => ['forgeos:cms:sync'] do
      system 'rsync -rvC vendor/plugins/forgeos_commerce/public .'
    end

    task :initialize => ['forgeos:cms:initialize'] do
      system 'rake forgeos:core:fixtures:load forgeos_commerce currencies_exchanges_rates,currencies,pages,people'
      system 'rake forgeos:core:generate:acl vendor/plugins/forgeos_commerce'
    end

    task :install => ['forgeos:cms:install', :initialize, :sync]
  end
end