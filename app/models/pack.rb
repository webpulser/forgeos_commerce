class Pack < Product
  has_and_belongs_to_many :products, :list => true, :order => 'position'

  def clone
    pack = super
    pack.product_ids = product_ids
    pack
  end
end
