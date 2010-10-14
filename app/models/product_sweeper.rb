class ProductSweeper < ActionController::Caching::Sweeper
  observe Product, Pack

  def after_save(record)
    expire_cache_for(record)
  end

  def after_create(record)
    expire_cache_for(record)
  end

  def before_destroy(record)
    expire_cache_for(record)
  end

  private
  def expire_cache_for(record)
    expire_cache_for_product(record)
  end

  def expire_cache_for_product(product)
    expire_page seo_product_path(product) if respond_to?('seo_product_path')
    expire_page product_path(product) if respond_to?('product_path')
    expire_fragment("products/#{product.id}") if product.id

    home_page = Page.find_by_single_key('home')
    expire_page page_path(home_page.url) if home_page
  end

end
