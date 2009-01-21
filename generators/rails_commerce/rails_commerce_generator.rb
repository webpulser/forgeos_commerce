require 'restful_authentication/rails_commands'
class RailsCommerceGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false,
                  :include_activation => false
                  
  attr_reader   :type_controller,
                :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name,
                :controller_file_name

  def initialize(runtime_args, runtime_options = {})
    super

    action = runtime_args.first

    case action
    when "controller"
      @type_controller = runtime_args[1]
      case @type_controller
      when 'cart'
        @controller_name = runtime_args[1] || 'cart'
      else
        puts "stop"
        raise new Exception
      end

      # sessions controller
      base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
      @controller_class_name_without_nesting, @controller_file_name, @controller_plural_name = inflect_names(base_name)
      @controller_singular_name = @controller_file_name.singularize

      if @controller_class_nesting.empty?
        @controller_class_name = @controller_class_name_without_nesting
      else
        @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
      end
      puts "Generate #{@controller_class_name} controller"
    end
  end

  def manifest
    recorded_session = record do |m|
      # Check for class naming collisions.
      m.class_collisions controller_class_path,       "#{controller_class_name}Controller", # Sessions Controller
                                                      "#{controller_class_name}Helper"
#      m.class_collisions [], 'AuthenticatedSystem', 'AuthenticatedTestHelper'

      # Controller, helper, views, and test directories.
      m.directory File.join('app/controllers', controller_class_path)
      m.directory File.join('app/helpers', controller_class_path)
      m.directory File.join('app/views', controller_class_path, controller_file_name)

      m.directory File.join('test/functional', controller_class_path)
      m.directory File.join('test/unit', class_path)

      m.template "#{type_controller}_controller.rb",
                  File.join('app/controllers',
                            controller_class_path,
                            "#{controller_file_name}_controller.rb")
      
#      m.route_resource  controller_singular_name
#      m.route_resources model_controller_plural_name
    end

    action = nil
    action = $0.split("/")[1]
    case action
      when "generate" 
        puts
        puts ("-" * 70)
        puts "Don't forget to:"
        puts
        if options[:include_activation]
          puts "    map.activate '/activate/:activation_code', :controller => '#{model_controller_file_name}', :action => 'activate'"
          puts
          puts "  - add an observer to config/environment.rb"
          puts "    config.active_record.observers = :#{file_name}_observer"
          puts
        end
        if options[:stateful]
          puts "Also, don't forget to install the acts_as_state_machine plugin and set your resource:"
          puts
          puts "  svn export http://elitists.textdriven.com/svn/plugins/acts_as_state_machine/trunk vendor/plugins/acts_as_state_machine"
          puts
          puts "In config/routes.rb:"
          puts "  map.resources :#{model_controller_file_name}, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete }"
          puts
        end
        puts "Try these for some familiar login URLs if you like:"
        puts
        puts %(map.activate '/activate/:activation_code', :controller => '#{model_controller_file_name}', :action => 'activate', :activation_code => nil)
        puts %(map.signup '/signup', :controller => '#{model_controller_file_name}', :action => 'new')
        puts %(map.login '/login', :controller => '#{controller_file_name}', :action => 'new')
        puts %(map.logout '/logout', :controller => '#{controller_file_name}', :action => 'destroy')
        puts
        puts ("-" * 70)
        puts
      when "destroy" 
        puts
        puts ("-" * 70)
        puts
        puts "Thanks for using restful_authentication"
        puts
        puts "Don't forget to comment out the observer line in environment.rb"
        puts "  (This was optional so it may not even be there)"
        puts "  # config.active_record.observers = :#{file_name}_observer"
        puts
        puts ("-" * 70)
        puts
      else
        puts
    end

    recorded_session
  end
  
  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} rails_commerce [ControllerName]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
      opt.on("--include-activation", 
             "Generate signup 'activation code' confirmation via email") { |v| options[:include_activation] = true }
      opt.on("--stateful", 
             "Use acts_as_state_machine.  Assumes --include-activation") { |v| options[:include_activation] = options[:stateful] = true }
    end
end
