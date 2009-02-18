namespace :rails_commerce do
  task :sync do
    system 'rsync -rvC vendor/plugins/rails_commerce/public .'
  end
end
