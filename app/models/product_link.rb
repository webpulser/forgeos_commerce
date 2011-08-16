class ProductLink < MenuLink
  def url
    if product = Product.find(self.target_id)
      product.url
    else
      ''
    end
  end
end
