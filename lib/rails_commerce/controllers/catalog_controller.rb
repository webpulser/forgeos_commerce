module RailsCommerce
  # ==== session's variables
  # * <tt>session[:keywords]</tt> - keyword's search are save in <i>session</i> (for pagination)
  module CatalogController
    # Show all <i>RailsCommerce::ProductDetail</i>
    def index
      @products = RailsCommerce::ProductDetail.paginate(:all, :per_page => 8, :page => params[:page])
    end

    # Show all <i>RailsCommerce::ProductDetail</i> by <i>RailsCommerce::Category</i>
    #
    # ==== Parameters
    # * <tt>:id</tt> - an id of a <i>RailsCommerce::Category</i>
    def category
      @category = RailsCommerce::Category.find_by_id(params[:id])
      return redirect_to_home unless @category
      @products = []
      @category.products.each { |products| @products += products.product_details }

      render :action => 'index'
    end

    # Search <i>RailsCommerce::ProductDetail</i>
    #
    # keywords is save in 
    #
    # ==== Parameters
    # * <tt>:keywords</tt> - an id of a <i>RailsCommerce::Category</i>    
    def search
      keywords = params[:keywords] || session[:keywords]
      session[:keywords] = keywords

      @products = RailsCommerce::ProductDetail.search_paginate(keywords, params[:page])

      render :action => 'index'
    end
  end
end