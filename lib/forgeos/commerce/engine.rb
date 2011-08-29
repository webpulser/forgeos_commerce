require 'forgeos/cms/engine'
require 'aasm'
require 'ruleby'

module Forgeos
  module Commerce
    class Engine < Rails::Engine
      paths['config/locales'] << 'config/locales/**'
    end
  end
end
