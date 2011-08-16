class CartItem < ActiveRecord::Base
  belongs_to :product
  validates_associated :product

  belongs_to :cart
  validates_associated :cart

  def total(options = {})
    product.price(options.update(:voucher_discount => false)) * quantity
  end

  def tax(options = {})
    options = { :currency => true }.update(options.symbolize_keys)

    ("%01.2f" % (total(options) - total)).to_f
  end

  def weight
    product.weight * quantity
  end
end
