namespace :rails_commerce do
  task :sync do
    system 'rsync -rvC vendor/plugins/rails_commerce/public .'
  end

  task :initialize => [ 'db:migrate' ] do
    system 'rake rails_commerce:fixtures:load FIXTURES=countries,currencies_exchanges_rates,currencies,namables,people'
  end

  task :install => [ 'gems:install', :initialize, :sync]
end
