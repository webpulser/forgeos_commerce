class Voucher < ActiveRecord::Base
  validates_presence_of :code, :name, :value, :total_min, :date_start
  def is_valid?(total=nil)
    valid = date_start < Time.now.to_date && date_end > Time.now.to_date
    valid &&= total > total_min if total && total_min
    return valid
  end
end
