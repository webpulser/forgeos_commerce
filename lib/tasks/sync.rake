namespace :rails_commerce do
  task :sync do
    system 'rsync -ruvC vendor/plugins/rails_commerce/public .'
  end
end
