require 'forgeos/cms/engine'
module Forgeos
  module Commerce
    class Engine < Rails::Engine
      paths['config/locales'] << 'config/locales/**'
    end
  end
end
