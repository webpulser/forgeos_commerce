class Pack < Product
  has_and_belongs_to_many :products, :list => true, :order => 'position'
end
