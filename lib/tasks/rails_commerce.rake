namespace :rails_commerce do
  task :sync => ['rails_content:sync'] do
    system 'rsync -rvC vendor/plugins/rails_commerce/public .'
  end

  task :initialize => [ 'db:migrate' ] do
    system 'rake rails_commerce:fixtures:load FIXTURES=geo_zones,currencies_exchanges_rates,currencies,namables,people'
  end

  task :install => [ 'gems:install', :initialize, :sync]
end
