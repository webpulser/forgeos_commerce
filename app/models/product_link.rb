class ProductLink < MenuLink

  def url
    product = Product.find(self.target_id)
    #product_path product
    "/products/#{product.url}"
  end
end
