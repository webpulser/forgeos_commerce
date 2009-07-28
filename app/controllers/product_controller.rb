class ProductController < ApplicationController
  before_filter :get_product, :only => [ :show, :update ]
  def show
    init_session_for_product(@product, true)
  end

  def update
    return redirect_to_home unless request.xhr?
    # Sauvegarde de l'attribut (supplémentaire) selectionné
    @tattribute_value = TattributeValue.find_by_id(params[:tattribute_value_id])
    return render(:nothing => true) unless @attribute
    session["product_#{@product.id}"][:tattribute_values][@tattribute_value.tattribute.id] = @tattribute_value

    # Recherche des correspondances avec les différents attributs selectionnés.
    @product_details = @product.product_details.reject do |product_detail|
      tmp = true
      session["product_#{@product.id}"][:tattribute_values].each do |key, tattribute_value|
        tmp &&= !product_detail.tattribute_values.find_by_id(tattribute_value.id).nil? unless tattribute_value.nil?
      end
      !tmp
    end

    # Selection des attributs par défaut si un seul résultat
    if @product_details.size == 1
      @product_detail = @product_details.first
      @product_detail.tattribute_values.each do |tattribute_value|
        session["product_#{@product.id}"][:tattribute_values][tattribute_value.tattribute.id] = tattribute_value
      end
    end

    # Mise à jour de la fiche produit
    render(:update) do |page|
      page.replace_html("product_attributes_groups_#{@product.id}", display_product_page_attributes(@product, session["product_#{@product.id}"][:attributes]))
      if @product_detail
        page.select('.product_show').attr('id',"product_#{@product_detail.id}")
        page.replace_html("display_product_pictures_#{@product.id}", image_tag(@product_detail.pictures.first.public_filename(:normal))) unless @product_detail.pictures.empty?
        page.replace_html("display_product_page_price_#{@product.id}", "#{@product_detail.price_to_s(true)}")
        page.replace_html("display_product_link_cart_#{@product.id.to_s}", link_to_add_cart(@product_detail))
        page.replace_html("display_product_page_name_#{@product.id}", @product_detail.name)
        page.visual_effect :highlight, "display_product_page_price_#{@product.id}"
        page.draggable("product_#{@product_detail.id}", :revert => true, :cursor => '"move"', :helper => "function(event) {
                                 return $('<div class=\"ui-widget-header\">#{escape_javascript(@product_detail.name)}</div>');
                                 }")
      else
        page.replace_html("display_product_page_price_#{@product.id}", @product.price_to_s(true))
        page.replace_html("display_product_link_cart_#{@product.id.to_s}", I18n.t('add_to_cart').capitalize)
      end
    end
  end

private
  def get_product
    @product = ProductParent.find_by_id(params[:id], :include => ['product_details'])
    return redirect_to_home if @product.nil?
    init_session_for_product(@product)
  end
end
