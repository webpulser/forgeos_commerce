require 'ruleby'
class Transporter < Ruleby::Rulebook

  attr_writer :transporter_ids
  
  def rules
    TransporterRule.find_all_by_active(true).each do |transporter|
      rule eval(transporter.conditions) do |context|
          @transporter_ids << transporter.id
      end
    end
    @transporter_ids
  end
end
