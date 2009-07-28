class PriceCut < ActiveRecord::Base
  belongs_to :product
  validates_presence_of :old_price, :new_price, :date_start, :date_end
  
  protected
    def validate_on_create
      unless date_start < date_end
        errors.add(I18n.t('price_cut.date_error').capitalize)
      end
    end
    
    def validate_on_update
      unless date_start < date_end
        errors.add(I18n.t('price_cut.date_error').capitalize)
      end
    end
end