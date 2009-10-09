namespace :forgeos_commerce do
  task :sync => ['forgeos_cms:sync'] do
    system 'rsync -rvC vendor/plugins/forgeos_commerce/public .'
  end

  task :initialize => [ 'db:migrate' ] do
    system 'rake forgeos_commerce:fixtures:load FIXTURES=geo_zones,currencies_exchanges_rates,currencies,namables,people'
  end

  task :install => [ 'gems:install', :initialize, :sync]
end
