load File.join(Gem.loaded_specs['forgeos_cms'].full_gem_path, 'app', 'controllers', 'admin', 'base_controller.rb')
Admin::BaseController.class_eval do
  skip_before_filter :set_currency, :only => [:notifications, :url]
  before_filter :forgeos_commece_javascripts_files

private

  def forgeos_commerce_javascripts_files
    @forgeos_js_functions_files += forgeos_javascripts_files('forgeos_commerce', 'forgeos/admin/functions')
    @forgeos_js_inits_files += forgeos_javascripts_files('forgeos_commerce', 'forgeos/admin/inits')
  end

end
