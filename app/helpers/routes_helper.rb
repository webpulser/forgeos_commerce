module RoutesHelper

  def seo_product_type_path(product_type)
    product_type_path(:product_type_url=>product_type.url)
  end

  def seo_product_type_product_category_path(product_type,product_category)
    product_type_product_category_path(:product_type_url=>product_type.url,:category_url=>product_category.url)
  end

  def seo_product_path(*args)
    super(extract_product_options(args))
  end

  def seo_product_url(*args)
    super(extract_product_options(args))
  end

  def extract_product_options(args)
    options = args.dup.extract_options!
    object = args.first
    if object.kind_of?(Product)
      product_type_url = (object.product_type.nil?) ? 'articles' : object.product_type.url
      return options.merge( :url => object.url, :product_type => product_type_url )
    else
      return args
    end
  end

  def product_category_path(object)
    super(:id => nil, :category_name => object.name)
  end

end
