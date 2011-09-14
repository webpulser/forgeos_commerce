load File.join(Gem.loaded_specs['forgeos_core'].full_gem_path, 'app', 'controllers', 'admin', 'base_controller.rb')
Admin::BaseController.class_eval do
  helper "admin/payment_fields"
  skip_before_filter :set_currency, :only => [:notifications, :url]
end
