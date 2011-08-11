namespace :forgeos do
  namespace :commerce do
    desc "load fixtures and generate forgeos_commerce controllers ACLs"
    task :install do
      Rake::Task['forgeos:core:fixtures:load'].invoke('forgeos_commerce','currencies_exchanges_rates currencies pages page_translations people product_types product_type_translations')
      Rake::Task['forgeos:core:generate:acl'].invoke(Gem.loaded_specs['forgeos_commerce'].full_gem_path)
    end
  end
end
