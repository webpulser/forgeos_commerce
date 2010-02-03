module Forgeos
  module Commerce
  end
end

require 'forgeos/commerce/float'
$currency = Currency.find_by_code('EUR') if Currency.table_exists?
