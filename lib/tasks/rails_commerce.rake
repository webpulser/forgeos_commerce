namespace :rails_commerce do
  task :patch do
    system 'cp vendor/plugins/rails_commerce/config/initializers/*.rb ./config/initializers/'
  end

  task :sync do
    system 'rsync -rvC vendor/plugins/rails_commerce/public .'
  end

  task :initialize => [ 'db:migrate' ] do
    system 'rake rails_commerce:fixtures:load FIXTURES=countries,currencies_exchanges_rates,currencies,namables,people'
  end

  task :install => [ 'gems:install', :initialize, 'generate:rights_and_roles', :sync, :patch]
end
