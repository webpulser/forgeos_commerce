require 'ruleby'
class Voucher < Ruleby::Rulebook
  
  attr_writer :code, :order

  def rules
    VoucherRule.find_all_by_active_and_code(true,@code).each do |voucher|
      rule eval(voucher.conditions) do |context|
         # NEED CODE
      end
    end
  end
end
