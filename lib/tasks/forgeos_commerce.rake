namespace :forgeos_commerce do
  task :sync => ['forgeos_cms:sync'] do
    system 'rsync -rvC vendor/plugins/forgeos_commerce/public .'
  end

  task :initialize => [ 'db:migrate' ] do
    system 'rake forgeos_commerce:fixtures:load FIXTURES=currencies_exchanges_rates,currencies'
    system 'rake forgeos_core:generate:acl vendor/plugins/forgeos_commerce'
  end

  task :install => [ 'gems:install', :initialize, :sync]
end
